Pod::Spec.new do |s|
    s.name             = 'Boardy'
    s.version          = '1.18.0'
    s.swift_versions    = ['5.0', '5.1', '5.2', '5.3', '5.4']
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
        co.dependency 'Boardy/Attachable'
    end
    
    s.subspec 'Core' do |co|
        co.source_files = 'Boardy/Core/**/*.swift'
    end
    
    s.subspec 'DeepLink' do |co|
        co.source_files = 'Boardy/DeepLink/**/*.swift'
        
        co.dependency 'Boardy/Core'
    end
    
    s.subspec 'RxStoreRef' do |co|
        co.source_files = 'Boardy/RxStoreRef/**/*.swift'
        
        co.dependency 'Boardy/Core'
        co.dependency 'Boardy/DeepLink'
        
        co.dependency 'ReferenceStoreManager'
    end
    
    s.subspec 'Runtime' do |co|
        co.source_files = 'Boardy/Runtime/**/*.swift'
        
        co.dependency 'Boardy/Core'
        co.dependency 'Boardy/DeepLink'
        co.dependency 'Boardy/Composable'
    end
    
    s.subspec 'Attachable' do |co|
        co.source_files = 'Boardy/Attachable/**/*.swift'
        
        co.dependency 'Boardy/Core'
        co.dependency 'Boardy/DeepLink'
    end
    
    s.subspec 'Composable' do |co|
        co.source_files = 'Boardy/Composable/**/*.swift'
        
        co.dependency 'Boardy/Core'
        co.dependency 'UIComposable'
    end
    
    s.subspec 'ComponentKit' do |co|
        co.source_files = 'Boardy/ComponentKit/**/*.swift'
        
        co.dependency 'Boardy/Core'
    end
end
