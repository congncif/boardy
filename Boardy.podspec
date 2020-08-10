Pod::Spec.new do |s|
    s.name             = 'Boardy'
    s.version          = '0.9.1'
    s.swift_versions    = ['5.0', '5.1', '5.2', '5.3']
    s.summary          = 'A mediator interface to integrate multiple mobile architectures.'
    s.description      = <<-DESC
  Integrate components which was developed using different architecures.
                         DESC
    s.homepage         = 'https://github.com/congncif'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'congncif' => 'congnc.if@gmail.com' }
    s.source           = { :git => 'https://github.com/congncif/boardy.git', :tag => s.version.to_s }
    s.ios.deployment_target = '9.3'
    s.source_files = 'Boardy/**/*'
    s.dependency 'RxDataSources'
    s.dependency 'SnapKit'
end
