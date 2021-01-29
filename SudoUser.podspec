Pod::Spec.new do |spec|
  spec.name                  = 'SudoUser'
  spec.version               = '10.1.0'
  spec.author                = { 'Sudo Platform Engineering' => 'sudoplatform-engineering@anonyome.com' }
  spec.homepage              = 'https://sudoplatform.com'
  spec.summary               = 'User SDK for the Sudo Platform by Anonyome Labs.'
  spec.license               = { :type => 'Apache License, Version 2.0',  :file => 'LICENSE' }
  spec.source                = { :git => 'https://github.com/sudoplatform/sudo-user-ios.git', :tag => "v#{spec.version}" }
  spec.source_files          = 'SudoUser/*.swift'
  spec.ios.deployment_target = '13.0'
  spec.requires_arc          = true
  spec.swift_version         = '5.0'

  spec.dependency 'SudoKeyManager', '~> 1.2'
  spec.dependency 'SudoLogging', '~> 0.3'
  spec.dependency 'SudoConfigManager', '~> 1.3'
  spec.dependency 'AWSCognitoIdentityProvider', '~> 2.22.0'
  spec.dependency 'AWSAppSync', '~> 3.1.14'
  spec.dependency 'AWSMobileClient', '~> 2.22.0'
  spec.dependency 'AWSCore', '~> 2.22.0'
  spec.dependency 'AWSS3', '~> 2.22.0'
end
