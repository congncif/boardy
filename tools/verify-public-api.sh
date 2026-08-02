#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Usage: [DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer] $0 <baseline-interface> <baseline-api-json> <candidate-interface> <candidate-api-json> <report-output>" >&2
}

if [ "$#" -ne 5 ]; then
    usage
    exit 64
fi

BASELINE_INTERFACE="$1"
BASELINE_API="$2"
CANDIDATE_INTERFACE="$3"
CANDIDATE_API="$4"
REPORT_OUTPUT="$5"

LOCAL_TEMP_ROOT="${BOARDY_LOCAL_TMPDIR:-$REPO_ROOT/.build-local/tmp}"
mkdir -p "$(dirname "$REPORT_OUTPUT")" "$LOCAL_TEMP_ROOT"
TEMP_ROOT="$(mktemp -d "$LOCAL_TEMP_ROOT/boardy-api-verification.XXXXXX")"
trap 'rm -rf "$TEMP_ROOT"' EXIT

REPORT_TEMP="$TEMP_ROOT/report.md"
DIAGNOSIS_OUTPUT="$TEMP_ROOT/diagnosis.txt"
INTERFACE_DIFF="$TEMP_ROOT/interface.diff"
ACTOR_FINDINGS="$TEMP_ROOT/global-actor-findings.txt"

cat > "$REPORT_TEMP" <<'REPORT_HEADER'
# Boardy Public API Verification Report

REPORT_HEADER

finish_failure() {
    local reason="$1"
    {
        echo "## Verification failure"
        echo
        echo "$reason"
        echo
        echo "## Result"
        echo
        echo "FAIL"
    } >> "$REPORT_TEMP"
    mv "$REPORT_TEMP" "$REPORT_OUTPUT"
    exit 1
}

DEVELOPER_DIR="${DEVELOPER_DIR:-$(xcode-select -p)}"

if [ ! -d "$DEVELOPER_DIR" ]; then
    finish_failure "DEVELOPER_DIR does not exist: $DEVELOPER_DIR"
fi

if ! XCODE_VERSION_OUTPUT="$(DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild -version 2>&1)"; then
    finish_failure "Unable to read the configured Xcode version: $XCODE_VERSION_OUTPUT"
fi
XCODE_VERSION_LINE="$(printf '%s\n' "$XCODE_VERSION_OUTPUT" | sed -n '1p')"
MIN_XCODE_VERSION="${BOARDY_MIN_XCODE_VERSION:-Xcode 26.4.1}"
if [ "${BOARDY_ALLOW_XCODE_MISMATCH:-0}" != "1" ]; then
    if ! printf '%s\n' "$XCODE_VERSION_LINE" "$MIN_XCODE_VERSION" | sort -V | tail -n1 | grep -qx "$XCODE_VERSION_LINE"; then
        finish_failure "Need at least $MIN_XCODE_VERSION, found: $XCODE_VERSION_LINE. Set BOARDY_ALLOW_XCODE_MISMATCH=1 to override."
    fi
fi

HOST_ARCH="$(uname -m)"
case "$HOST_ARCH" in
    arm64)
        DIGESTER_TARGET="arm64-apple-ios14.0-simulator"
        ;;
    x86_64)
        DIGESTER_TARGET="x86_64-apple-ios14.0-simulator"
        ;;
    *)
        finish_failure "Unsupported host architecture: $HOST_ARCH"
        ;;
esac

if ! SDK_PATH="$(DEVELOPER_DIR="$DEVELOPER_DIR" xcrun --sdk iphonesimulator --show-sdk-path 2>&1)"; then
    finish_failure "Unable to resolve the iPhone Simulator SDK: $SDK_PATH"
fi
if [ ! -d "$SDK_PATH" ]; then
    finish_failure "iPhone Simulator SDK does not exist: $SDK_PATH"
fi

for input in \
    "$BASELINE_INTERFACE" \
    "$BASELINE_API" \
    "$CANDIDATE_INTERFACE" \
    "$CANDIDATE_API"; do
    if [ ! -s "$input" ]; then
        finish_failure "Required input is missing or empty: $input"
    fi
done

if ! ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0))); JSON.parse(File.read(ARGV.fetch(1)))' \
    "$BASELINE_API" "$CANDIDATE_API"; then
    finish_failure "One or both API graph inputs are not parseable JSON."
fi

# Refuse to verify against a truncated or wrong-module capture: parseable JSON is not enough.
# The render-inventory inventory currently reports ~820 public declarations on the umbrella
# module, so 100 is a conservative lower bound that still leaves headroom for future pruning.
MIN_TOP_LEVEL_NODES=100
for input in "$BASELINE_API" "$CANDIDATE_API"; do
    node_count="$(ruby -rjson -e 'n = JSON.parse(File.read(ARGV.fetch(0))).dig("ABIRoot", "children")&.size.to_i; puts n' "$input")"
    if [ "$node_count" -lt "$MIN_TOP_LEVEL_NODES" ]; then
        finish_failure "API graph $input has only $node_count top-level nodes; expected >= $MIN_TOP_LEVEL_NODES. Capture likely failed."
    fi
done

if ! BASELINE_INTERFACE_SHA="$(shasum -a 256 "$BASELINE_INTERFACE" | awk '{print $1}')" ||
    ! BASELINE_API_SHA="$(shasum -a 256 "$BASELINE_API" | awk '{print $1}')" ||
    ! CANDIDATE_INTERFACE_SHA="$(shasum -a 256 "$CANDIDATE_INTERFACE" | awk '{print $1}')" ||
    ! CANDIDATE_API_SHA="$(shasum -a 256 "$CANDIDATE_API" | awk '{print $1}')"; then
    finish_failure "Unable to calculate one or more input SHA-256 values."
fi
if ! SWIFT_DIGESTER_PATH="$(DEVELOPER_DIR="$DEVELOPER_DIR" xcrun --find swift-api-digester 2>&1)"; then
    finish_failure "Unable to resolve swift-api-digester: $SWIFT_DIGESTER_PATH"
fi

{
    echo "## Toolchain"
    echo
    echo '```text'
    printf '%s\n' "$XCODE_VERSION_OUTPUT"
    echo "DEVELOPER_DIR=$DEVELOPER_DIR"
    echo "swift-api-digester=$SWIFT_DIGESTER_PATH"
    echo "host-architecture=$HOST_ARCH"
    echo "target=$DIGESTER_TARGET"
    echo "sdk=$SDK_PATH"
    echo '```'
    echo
    echo "## Inputs"
    echo
    echo "| Artifact | SHA-256 |"
    echo "| --- | --- |"
    echo "| Baseline interface: \`$BASELINE_INTERFACE\` | \`$BASELINE_INTERFACE_SHA\` |"
    echo "| Baseline API graph: \`$BASELINE_API\` | \`$BASELINE_API_SHA\` |"
    echo "| Candidate interface: \`$CANDIDATE_INTERFACE\` | \`$CANDIDATE_INTERFACE_SHA\` |"
    echo "| Candidate API graph: \`$CANDIDATE_API\` | \`$CANDIDATE_API_SHA\` |"
    echo
} >> "$REPORT_TEMP"

set +e
DEVELOPER_DIR="$DEVELOPER_DIR" xcrun swift-api-digester \
    -diagnose-sdk \
    -input-paths "$BASELINE_API" \
    -input-paths "$CANDIDATE_API" \
    -module Boardy \
    -swift-only \
    -swift-version 5 \
    -sdk "$SDK_PATH" \
    -target "$DIGESTER_TARGET" \
    > "$DIAGNOSIS_OUTPUT" 2>&1
DIGESTER_STATUS=$?
set -e

if [ "$DIGESTER_STATUS" -ne 0 ]; then
    {
        echo "## API digester diagnosis"
        echo
        echo '```text'
        cat "$DIAGNOSIS_OUTPUT"
        echo '```'
        echo
    } >> "$REPORT_TEMP"
    finish_failure "swift-api-digester failed with exit status $DIGESTER_STATUS."
fi

if ! DIAGNOSIS_FINDINGS="$(awk 'NF && $0 !~ /^\/\*.*\*\/$/ { print }' "$DIAGNOSIS_OUTPUT")"; then
    finish_failure "Unable to parse the API digester diagnosis."
fi

set +e
diff -u "$BASELINE_INTERFACE" "$CANDIDATE_INTERFACE" > "$INTERFACE_DIFF"
DIFF_STATUS=$?
set -e
if [ "$DIFF_STATUS" -gt 1 ]; then
    finish_failure "Public-interface diff failed with exit status $DIFF_STATUS."
fi

if ! ruby - "$BASELINE_INTERFACE" "$CANDIDATE_INTERFACE" > "$ACTOR_FINDINGS" <<'RUBY'
require "set"

ATTRIBUTE = /@(?:(?:[A-Za-z_]\w*)\.)*([A-Za-z_]\w*)(?:\([^\n)]*\))?/
GLOBAL_ACTOR_MARKER = /@(?:(?:[A-Za-z_]\w*)\.)*globalActor\b/

def locally_declared_global_actors(path)
  lines = File.readlines(path, chomp: true)
  names = Set.new
  lines.each_with_index do |line, index|
    next unless line.match?(GLOBAL_ACTOR_MARKER)

    declaration = lines[index, 3].join(" ")
    match = declaration.match(/\b(?:actor|class|enum|struct)\s+([A-Za-z_]\w*)/)
    names << match[1] if match
  end
  names
end

def actor_attribute?(short_name, declared_names)
  return false if short_name == "globalActor"
  short_name == "MainActor" || short_name.end_with?("Actor") || declared_names.include?(short_name)
end

def records(path, declared_names)
  scopes = []
  pending_actors = []
  result = Hash.new { |hash, key| hash[key] = [] }

  File.foreach(path) do |raw_line|
    line = raw_line.chomp
    stripped = line.strip
    next if stripped.empty? || stripped.start_with?("//") || stripped.start_with?("import ")

    leading_closures = stripped[/\A\}+/].to_s.length
    leading_closures.times { scopes.pop }

    actor_names = line.scan(ATTRIBUTE).flatten.select do |name|
      actor_attribute?(name, declared_names)
    end
    normalized = line.gsub(ATTRIBUTE) do |attribute|
      name = attribute.match(ATTRIBUTE)[1]
      actor_attribute?(name, declared_names) ? "" : attribute
    end.gsub(/\s+/, " ").strip

    if normalized.empty?
      pending_actors.concat(actor_names)
      next
    end

    unless normalized.match?(/\A\}+\z/)
      all_actors = pending_actors + actor_names
      key = "#{scopes.join(' > ')} :: #{normalized}"
      result[key] << { actors: all_actors, source: stripped }
      pending_actors = []
    end

    opens = normalized.count("{")
    closes = normalized.count("}") - leading_closures
    opens.times { scopes << normalized }
    [closes, 0].max.times { scopes.pop }
  end

  result
end

baseline_path, candidate_path = ARGV
declared_names = Set["MainActor"]
declared_names.merge(locally_declared_global_actors(baseline_path))
declared_names.merge(locally_declared_global_actors(candidate_path))

baseline = records(baseline_path, declared_names)
candidate = records(candidate_path, declared_names)
findings = []

candidate.each do |key, candidate_entries|
  next unless baseline.key?(key)

  baseline_counts = Hash.new(0)
  candidate_counts = Hash.new(0)
  baseline[key].each { |entry| entry[:actors].each { |name| baseline_counts[name] += 1 } }
  candidate_entries.each { |entry| entry[:actors].each { |name| candidate_counts[name] += 1 } }

  candidate_counts.each do |name, count|
    next unless count > baseline_counts[name]

    source = candidate_entries.find { |entry| entry[:actors].include?(name) }[:source]
    findings << "Added @#{name} to existing declaration: #{key} [candidate: #{source}]"
  end
end

puts findings.sort.uniq
RUBY
then
    finish_failure "Global-actor annotation analysis failed."
fi

{
    echo "## API digester diagnosis"
    echo
    if [ -z "$DIAGNOSIS_FINDINGS" ]; then
        echo "No source/API break diagnosed."
    else
        echo "Source/API breakage was diagnosed:"
    fi
    echo
    echo '```text'
    cat "$DIAGNOSIS_OUTPUT"
    echo '```'
    echo
    echo "## Textual public-interface diff"
    echo
    if [ "$DIFF_STATUS" -eq 0 ]; then
        echo "No textual public-interface differences."
    else
        echo '```diff'
        cat "$INTERFACE_DIFF"
        echo '```'
    fi
    echo
    echo "## Global-actor annotation check"
    echo
    if [ ! -s "$ACTOR_FINDINGS" ]; then
        echo "No newly added qualified or unqualified global-actor annotation was found on an existing declaration."
    else
        echo '```text'
        cat "$ACTOR_FINDINGS"
        echo '```'
    fi
    echo
} >> "$REPORT_TEMP"

if [ -n "$DIAGNOSIS_FINDINGS" ] || [ -s "$ACTOR_FINDINGS" ]; then
    {
        echo "## Result"
        echo
        echo "FAIL"
    } >> "$REPORT_TEMP"
    mv "$REPORT_TEMP" "$REPORT_OUTPUT"
    exit 1
fi

{
    echo "## Result"
    echo
    echo "PASS"
} >> "$REPORT_TEMP"

mv "$REPORT_TEMP" "$REPORT_OUTPUT"
test -s "$REPORT_OUTPUT"
echo "Public API verification passed: $REPORT_OUTPUT" >&2
