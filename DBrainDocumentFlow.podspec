#
# Be sure to run `pod lib lint DBrainDocumentFlow.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DBrainDocumentFlow'
  s.version          = '1.0.2'
  s.summary          = 'Lib for scaning documents for Dbrain'
  s.swift_version = '5.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DeadHipo/DBrainDocumentFlow'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DeadHipo' => '561298@gmail.com' }
  s.source           = { :git => 'https://github.com/DeadHipo/DBrainDocumentFlow.git', :tag => s.version.to_s }
  s.social_media_url = 'https://t.me/nearlydeadhipo'

  s.ios.deployment_target = '9.0'

  s.source_files = 'DBrainDocumentFlow/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DBrainDocumentFlow' => ['DBrainDocumentFlow/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'Accelerate'
  # s.dependency 'AFNetworking', '~> 2.3'
end
