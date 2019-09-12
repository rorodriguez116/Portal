#
# Be sure to run `pod lib lint Portal.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Portal'
  s.version          = '0.1.6'
  s.summary          = 'Portal is a easy gateway to all youre Firestore operations given a collection'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                    Portal is a simple abstraction layer of FirebaseFirestore and FirebaseAuth, it saves you a lot of work by automatycally parsing  document snapshots into your data layer model by using generics at its core. Portal also allows you to use FirebaseAuth with a very easy to use API to sign-in & sign-up new users into FirebaseAuth and create its mirror representation into your  database all done by PortalAuth while respecting your specified data layer model.
                       DESC

  s.homepage         = 'https://github.com/rorodriguez116/Portal'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rorodriguez116' => 'rorodriguez116@icloud.com' }
  s.source           = { :git => 'https://github.com/rorodriguez116/Portal.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.swift_version = '5.0'
  s.source_files = 'Portal/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Portal' => ['Portal/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.static_framework = true
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Firestore'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase/Storage'
  s.dependency 'Firebase/Analytics'
  s.dependency 'DeepDiff'

  end
