# Uncomment this line to define a global platform for your project
platform :ios, "15.0"
use_frameworks!
use_modular_headers!

# Ignore all warnings from pods.
inhibit_all_warnings!

source 'https://cdn.cocoapods.org/'

project 'SudoUser.xcodeproj'

target "SudoUser" do
  podspec :name => 'SudoUser'
end

target "SudoUserTests" do
  podspec :name => 'SudoUser'
end

target "SudoUserIntegrationTests" do
  podspec :name => 'SudoUser'
end

target "TestApp" do
  podspec :name => 'SudoUser'
end

# Fix Xcode nagging warning on pod install/update
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED'] = 'YES'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end