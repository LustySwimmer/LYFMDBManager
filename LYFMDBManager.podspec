#
# Be sure to run `pod lib lint LYFMDBManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LYFMDBManager'
  s.version          = '1.0.0'
  s.summary          = 'An easy way to use FMDB without writing any SQL code by yourself'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Tool that make it easy to use FMDB without writing any SQL code by yourself
                       DESC

  s.homepage         = 'https://github.com/LustySwimmer/LYFMDBManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lusty' => 'LustySwimmer@gmail.com' }
  s.source           = { :git => 'https://github.com/LustySwimmer/LYFMDBManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LYFMDBManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LYFMDBManager' => ['LYFMDBManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MJExtension'
  s.dependency 'FMDB'
end
