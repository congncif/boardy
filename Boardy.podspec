Pod::Spec.new do |s|
  s.name = "Boardy"
  s.version = "1.61.0"
  s.swift_version = "5.0"
  s.summary = "A modular orchestration framework for flow-driven iOS applications."

  s.description = <<-DESC
  Integrate components which was developed using different architectures.
  DESC

  s.homepage = "https://github.com/congncif/boardy"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "congncif" => "congnc.if@gmail.com" }
  s.source = { :git => "https://github.com/congncif/boardy.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/congncif"

  s.ios.deployment_target = "14.0"

  s.default_subspec = "Default"

  s.preserve_path = "tools/*"

  s.subspec "Default" do |co|
    co.dependency "Boardy/Core"
    co.dependency "Boardy/Attachable"
    co.dependency "Boardy/ModulePlugin"
    co.dependency "Boardy/ComponentKit"
  end

  s.subspec "Core" do |co|
    co.source_files = "Boardy/Core/**/*.swift"
  end

  s.subspec "ComponentKit" do |co|
    co.source_files = "Boardy/ComponentKit/**/*.swift"

    co.dependency "Boardy/Core"
  end

  s.subspec "Attachable" do |co|
    co.source_files = "Boardy/Attachable/**/*.swift"

    co.dependency "Boardy/Core"
  end

  s.subspec "Composable" do |co|
    co.source_files = "Boardy/Composable/**/*.swift"

    co.dependency "Boardy/Attachable"

    co.dependency "UIComposable", "~> 1.0.1"
  end

  s.subspec "ModulePlugin" do |co|
    co.source_files = "Boardy/ModulePlugin/**/*.swift"

    co.dependency "Boardy/Attachable"
  end
end
