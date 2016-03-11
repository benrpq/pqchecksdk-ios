#
# Be sure to run `pod lib lint PQCheckSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PQCheckSDK"
  s.version          = "0.1.1"
  s.summary          = "PQCheck SDK for iOS (Objective C)"

  s.description      = <<-DESC
                       PQCheck is a video signature system that ties individuals and organisations to an agreement, creating binding contracts at a distance. Together with PQCheck backend engine, this SDK allows you to create an iOS application that enforces sign-what-you-see principle.  
                       DESC

  s.homepage         = "https://github.com/post-quantum/pqchecksdk-ios"
  s.license          = 'Apache Licence, Version 2.0'
  s.author           = { "Post-Quantum" => "info@post-quantum.com" }
  s.source           = { :git => "https://github.com/post-quantum/pqchecksdk-ios.git", :branch => "develop", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/post_quantum'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.compiler_flags = ''

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PQCheckSDK' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.frameworks = 'SystemConfiguration', 'MobileCoreServices'
  s.dependency 'AFNetworking', '1.3.4'
  s.dependency 'RestKit', '0.26.0'
  s.dependency 'SimpleKeychain', '0.7.0'
  s.dependency 'MBProgressHUD', '0.9.2'
end
