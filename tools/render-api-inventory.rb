#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "optparse"

ELIGIBLE_KINDS = %w[TypeDecl Function Var Constructor Subscript OperatorDecl AssociatedType].freeze
EXCLUDED_DECL_KINDS = %w[Root Import ImportDecl].freeze
CLASSIFICATIONS = %w[Supported Deprecated Legacy-compatible Experimental/deferred].freeze
HEADER = [
  "Declaration key", "USR", "Graph kind", "Decl kind", "Printed declaration", "Area",
  "Classification", "Change from 1.60.1", "Replacement/deprecation window"
].freeze

def parse_options
  options = {}
  parser = OptionParser.new do |p|
    p.banner = "Usage: render-api-inventory.rb generate|verify --api PATH --output/--inventory PATH [--baseline-api PATH]"
    p.on("--api PATH", "API-digester JSON") { |value| options[:api] = value }
    p.on("--baseline-api PATH", "Optional 1.60.1 API-digester JSON") { |value| options[:baseline] = value }
    p.on("--output PATH", "Markdown output for generate") { |value| options[:output] = value }
    p.on("--inventory PATH", "Markdown input for verify") { |value| options[:inventory] = value }
  end
  mode = ARGV.shift
  parser.parse!(ARGV)
  abort parser.to_s unless %w[generate verify].include?(mode) && options[:api]
  options[:mode] = mode
  options
end

def load_json(path)
  JSON.parse(File.read(path))
rescue Errno::ENOENT, JSON::ParserError => e
  abort "Unable to read API graph #{path}: #{e.message}"
end

def eligible?(node, module_name)
  decl_kind = node["declKind"].to_s
  kind = node["kind"].to_s
  return false if decl_kind.empty? || EXCLUDED_DECL_KINDS.include?(decl_kind)
  return false unless ELIGIBLE_KINDS.include?(kind)
  return false unless module_name == "Boardy"

  true
end

def declaration_record(node, ancestors, module_name)
  printed = node["printedName"].to_s
  name = node["name"].to_s
  path = (ancestors + [printed.empty? ? name : printed]).reject(&:empty?)
  canonical = {
    "module" => module_name,
    "ancestor_path" => path,
    "declKind" => node["declKind"],
    "printedName" => node["printedName"],
    "name" => node["name"],
    "interfaceType" => node["interfaceType"] || node["genericSig"],
    "declAttributes" => node["declAttributes"]
  }
  usr = node["usr"].to_s
  key = if usr.empty?
          "synthetic:#{Digest::SHA256.hexdigest(JSON.generate(canonical))}"
        else
          "usr:#{usr}"
        end
  {
    key: key,
    usr: usr,
    kind: node["kind"].to_s,
    decl_kind: node["declKind"].to_s,
    printed: printed.empty? ? name : printed,
    area: path.first || "Boardy",
    deprecated: Array(node["declAttributes"]).any? { |attribute| attribute.to_s.downcase.include?("deprecated") }
  }
end

def walk(node, ancestors = [], inherited_module = nil, output = [])
  return output unless node.is_a?(Hash)

  module_name = node["moduleName"] || inherited_module
  if eligible?(node, module_name)
    output << declaration_record(node, ancestors, module_name)
  end

  next_ancestors = if node["kind"] == "TypeDecl" && module_name == "Boardy"
                     printed = node["printedName"].to_s
                     ancestors + [printed.empty? ? node["name"].to_s : printed]
                   else
                     ancestors
                   end
  Array(node["children"]).each { |child| walk(child, next_ancestors, module_name, output) }
  output
end

def records(graph)
  rows = walk(graph.fetch("ABIRoot"))
  keys = rows.map { |row| row[:key] }
  duplicates = keys.group_by(&:itself).select { |_key, values| values.length > 1 }.keys
  abort "Declaration key collision: #{duplicates.join(", ")}" unless duplicates.empty?
  rows.sort_by { |row| row[:key] }
end

def escape(value)
  value.to_s.gsub("|", "\\|").gsub("\n", " ")
end

def baseline_keys(path)
  return nil unless path

  records(load_json(path)).to_h { |row| [row[:key], true] }
end

def generate(options)
  abort "--output is required for generate" unless options[:output]
  rows = records(load_json(options[:api]))
  baseline = baseline_keys(options[:baseline])
  lines = [
    "# Boardy 1.61 public API inventory",
    "",
    "Generated from the Swift API Digester graph. Structural, reference/type and import nodes are excluded.",
    "Every eligible declaration has exactly one `usr:` or deterministic `synthetic:` key.",
    "",
    "| #{HEADER.join(" | ")} |",
    "| #{HEADER.map { "---" }.join(" | ")} |"
  ]
  rows.each do |row|
    classification = row[:deprecated] ? "Deprecated" : "Supported"
    change = baseline && !baseline.key?(row[:key]) ? "Added in candidate" : "Present/compatible"
    replacement = row[:deprecated] ? "Keep through the next supported major migration window" : "N/A"
    values = [row[:key], row[:usr], row[:kind], row[:decl_kind], row[:printed], row[:area], classification, change, replacement]
    lines << "| #{values.map { |value| escape(value) }.join(" | ")} |"
  end
  File.write(options[:output], lines.join("\n") + "\n")
end

def parse_inventory(path)
  lines = File.readlines(path, chomp: true)
  table = lines.drop_while { |line| !line.start_with?("| Declaration key |") }
  abort "Inventory table not found: #{path}" if table.empty?
  rows = table.drop(2).take_while { |line| line.start_with?("|") }
  rows.map do |line|
    fields = line.split("|", -1)[1...-1].map(&:strip).map { |value| value.gsub("\\|", "|") }
    abort "Inventory row has #{fields.length} columns, expected #{HEADER.length}" unless fields.length == HEADER.length
    HEADER.zip(fields).to_h
  end
end

def verify(options)
  abort "--inventory is required for verify" unless options[:inventory]
  expected = records(load_json(options[:api]))
  expected_by_key = expected.to_h { |row| [row[:key], row] }
  actual = parse_inventory(options[:inventory])
  actual_keys = actual.map { |row| row.fetch("Declaration key") }
  duplicates = actual_keys.group_by(&:itself).select { |_key, values| values.length > 1 }.keys
  abort "Duplicate inventory keys: #{duplicates.join(", ")}" unless duplicates.empty?
  unknown = actual_keys - expected_by_key.keys
  missing = expected_by_key.keys - actual_keys
  abort "Unknown inventory keys: #{unknown.join(", ")}" unless unknown.empty?
  abort "Missing inventory keys: #{missing.join(", ")}" unless missing.empty?
  actual.each do |row|
    abort "Unclassified declaration: #{row["Declaration key"]}" unless CLASSIFICATIONS.include?(row["Classification"])
    abort "Empty declaration area: #{row["Declaration key"]}" if row["Area"].to_s.empty?
  end
  operators = actual.select { |row| row["Graph kind"] == "OperatorDecl" && row["Decl kind"] == "InfixOperator" && row["Printed declaration"] == "->>" }
  abort "Expected exactly one ->> operator sentinel" unless operators.length == 1
  abort "->> must use a synthetic key" unless operators.first["Declaration key"].start_with?("synthetic:") && operators.first["USR"].empty?
  puts "API inventory verified: #{actual.length} declarations"
end

options = parse_options
options[:mode] == "generate" ? generate(options) : verify(options)
