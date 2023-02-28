Pod::Spec.new do |spec|
  spec.name                  = 'SudoUser'
  spec.version               = '14.1.1'
  spec.author                = { 'Sudo Platform Engineering' => 'sudoplatform-engineering@anonyome.com' }
  spec.homepage              = 'https://sudoplatform.com'
  spec.summary               = 'User SDK for the Sudo Platform by Anonyome Labs.'
  spec.license               = { :type => 'Apache License, Version 2.0',  :file => 'LICENSE' }
  spec.source                = { :git => 'https://github.com/sudoplatform/sudo-user-ios.git', :tag => "v#{spec.version}" }
  spec.source_files          = 'SudoUser/*.swift'
  spec.ios.deployment_target = '15.0'
  spec.requires_arc          = true
  spec.swift_version         = '5.0'

  spec.dependency 'SudoKeyManager', '~> 2.0'
  spec.dependency 'SudoLogging', '~> 1.0'
  spec.dependency 'SudoConfigManager', '~> 3.0'
  spec.dependency 'AWSCognitoIdentityProvider', '~> 2.27.15'
  spec.dependency 'AWSAppSync', '~> 3.6.1'
  spec.dependency 'AWSMobileClient', '~> 2.27.15'
  spec.dependency 'AWSCore', '~> 2.27.15'
  spec.dependency 'AWSS3', '~> 2.27.15'
end
