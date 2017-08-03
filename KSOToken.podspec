#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KSOToken'
  s.version          = '0.2.0'
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
  s.screenshots     = ['https://github.com/Kosoku/KSOToken/raw/master/screenshots/iOS.gif']
  s.license          = { :type => 'BSD', :file => 'license.txt' }
  s.author           = { 'William Towe' => 'willbur1984@gmail.com' }
  s.source           = { :git => 'https://github.com/Kosoku/KSOToken.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  
  s.requires_arc = true

  s.source_files = 'KSOToken/**/*.{h,m}'
  
  s.frameworks = 'UIKit'
  
  s.dependency 'Ditko'
end
