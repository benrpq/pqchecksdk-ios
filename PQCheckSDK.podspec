#
# Be sure to run `pod lib lint PQCheckSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PQCheckSDK"
  s.version          = "0.1.0"
  s.summary          = "A short description of PQCheckSDK."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                       PQCheckSDK for iOS
                       DESC

  s.homepage         = "https://github.com/post-quantum/pqchecksdk-ios.git"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "CJ Tjhai" => "cjt@post-quantum.com" }
  s.source           = { :git => "https://github.com/post-quantum/pqchecksdk-ios.git", :branch => "thin.sdk", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.compiler_flags = '-DTHINSDK'

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PQCheckSDK' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.frameworks = 'SystemConfiguration', 'MobileCoreServices'
  s.dependency 'AFNetworking'
  s.dependency 'RestKit'
  s.dependency 'RestKit/Testing'
  s.dependency 'SimpleKeychain'
  s.dependency 'MBProgressHUD'
end
