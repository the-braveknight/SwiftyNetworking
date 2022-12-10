#
# Be sure to run `pod lib lint SwiftyNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TBKNetworking'
  s.version          = '0.2.1'
  s.summary          = 'A lightweight generic networking API written purely in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SwiftyNetworking library is a generic networking library written in Swift that provides a protocol-oriented approach to load requests. It provides a protocol Endpoint to parse networking requests in a generic and type-safe way.
                       DESC

  s.homepage         = 'https://github.com/the-braveknight/SwiftyNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'the-braveknight' => 'zaid.riadh@gmail.com' }
  s.source           = { :git => 'https://github.com/the-braveknight/SwiftyNetworking.git', :tag => s.version.to_s }
  s.swift_version = '5.0' 
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'

  s.source_files = 'Sources/**/*'
  
  # s.resource_bundles = {
  #   'SwiftyNetworking' => ['SwiftyNetworking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
