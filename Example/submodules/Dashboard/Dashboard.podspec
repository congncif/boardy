Pod::Spec.new do |s|
  s.name = "Dashboard"
  s.version = "0.1.0"
  s.summary = "A short description of DashboardIO."

  s.description = <<-DESC
  TODO: Add long description of the pod here.
                  DESC

  s.homepage = "https://github.com/ifsolution"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "[iF] Solution" => "solution.if@gmail.com" }
  s.source = { :git => "https://github.com/ifsolution/Dashboard.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/congncif"

  s.ios.deployment_target = "11.0"
  s.swift_version = "5"

  s.source_files = "IO/**/*.swift"

  s.dependency "Boardy"
end
