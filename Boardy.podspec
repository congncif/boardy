Pod::Spec.new do |s|
  s.name = "Boardy"
  s.version = "1.57.3"
  s.swift_version = "5"
  s.summary = "A mediator interface to integrate multiple mobile architectures."

  s.description = <<-DESC
  Integrate components which was developed using different architectures.
  DESC

  s.homepage = "https://github.com/congncif"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "congncif" => "congnc.if@gmail.com" }
  s.source = { :git => "https://github.com/congncif/boardy.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/congncif"

  s.ios.deployment_target = "10.0"

  s.default_subspec = "Default"

  s.preserve_path = 'tools/*'

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
    
    co.dependency "UIComposable"
  end

  s.subspec "ModulePlugin" do |co|
    co.source_files = "Boardy/ModulePlugin/**/*.swift"

    co.dependency "Boardy/Attachable"
  end
end
