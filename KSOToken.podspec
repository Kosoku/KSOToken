#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KSOToken'
  s.version          = '2.0.1'
  s.summary          = 'KSOToken is a UITextView subclass that provides functionality similar to NSTokenField on macOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
KSOToken is a `UITextView` subclass that provides functionality similar to `NSTokenField` on macOS. It displays token using the `NSTextAttachment` class. It provides completion support and the appearance of various components (UITextView, UITableViewCell, NSTextAttachment) can be customized.
                       DESC

  s.homepage         = 'https://github.com/Kosoku/KSOToken'
  s.screenshots     = ['https://github.com/Kosoku/KSOToken/raw/master/screenshots/iOS-1.png','https://github.com/Kosoku/KSOToken/raw/master/screenshots/iOS-2.png']
  s.license          = { :type => 'Apache 2.0', :file => 'license.txt' }
  s.author           = { 'William Towe' => 'willbur1984@gmail.com' }
  s.source           = { :git => 'https://github.com/Kosoku/KSOToken.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  
  s.requires_arc = true

  s.source_files = 'KSOToken/**/*.{h,m}'
  s.private_header_files = 'KSOToken/Private/*.h'
  
  s.frameworks = 'UIKit'
  
  s.dependency 'Ditko'
  s.dependency 'Stanley'
end
