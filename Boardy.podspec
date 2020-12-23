Pod::Spec.new do |s|
    s.name             = 'Boardy'
    s.version          = '1.4.1'
    s.swift_versions    = ['5.0', '5.1', '5.2', '5.3']
    s.summary          = 'A mediator interface to integrate multiple mobile architectures.'
    s.description      = <<-DESC
  Integrate components which was developed using different architecures.
                         DESC
    s.homepage         = 'https://github.com/congncif'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'congncif' => 'congnc.if@gmail.com' }
    s.source           = { :git => 'https://github.com/congncif/boardy.git', :tag => s.version.to_s }
    s.ios.deployment_target = '10.0'
    
    s.default_subspec = 'Default'
    
    s.subspec 'Default' do |co|
        co.dependency 'Boardy/Core'
    end
    
    s.subspec 'Core' do |co|
        co.source_files = 'Boardy/Core/**/*'
    end
    
    s.subspec 'DeepLink' do |co|
        co.source_files = 'Boardy/DeepLink/**/*'
        
        co.dependency 'Boardy/Core'
    end
    
    s.subspec 'RxStoreRef' do |co|
        co.source_files = 'Boardy/RxStoreRef/**/*'
        
        co.dependency 'Boardy/Core'
        co.dependency 'Boardy/DeepLink'
        
        co.dependency 'ReferenceStoreManager'
    end
    
    s.subspec 'Composable' do |co|
        co.source_files = 'Boardy/Composable/**/*'
        
        co.dependency 'Boardy/Core'
        co.dependency 'UIComposable'
    end
end
