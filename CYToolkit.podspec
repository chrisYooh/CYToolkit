Pod::Spec.new do |s|

  s.name         = "CYToolkit"
  s.version      = "1.0.0"
  s.summary      = "CYToolkit"
  s.description  = "Used for APP based support, Based on YYCategories（But no relay on）"
  s.homepage     = "https://github.com/chrisYooh/CYToolkit.git"
  s.license      = "MIT"
  s.author       = { "Chris" => "340019109@qq.com" }

  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/chrisYooh/CYToolkit.git", :tag => s.version }

  s.source_files = "CYToolkit/Classes/*"
  s.public_header_files = "CYToolkit/Classes/*.h"

  s.subspec 'CAAnimation' do |ss|
   ss.source_files = "CYToolkit/Classes/CAAnimation/*"
   ss.public_header_files = "CYToolkit/Classes/CAAnimation/*.h"
  end

  s.subspec 'CLLocation' do |ss|
   ss.source_files = "CYToolkit/Classes/CLLocation/*"
   ss.public_header_files = "CYToolkit/Classes/CLLocation/*.h"
  end

  s.subspec 'Compatible' do |ss|
   ss.source_files = "CYToolkit/Classes/Compatible/*"
   ss.public_header_files = "CYToolkit/Classes/Compatible/*.h"
  end

  s.subspec 'NSDate' do |ss|
    ss.source_files = "CYToolkit/Classes/NSDate/*"
    ss.public_header_files = "CYToolkit/Classes/NSDate/*.h"
  end

  s.subspec 'NSDecimalNumber' do |ss|
    ss.source_files = "CYToolkit/Classes/NSDecimalNumber/*"
    ss.public_header_files = "CYToolkit/Classes/NSDecimalNumber/*.h"
  end

  s.subspec 'NSString' do |ss|
    ss.source_files = "CYToolkit/Classes/NSString/*"
    ss.public_header_files = "CYToolkit/Classes/NSString/*.h"
    ss.dependency "CYToolkit/NSDecimalNumber"
  end

  s.subspec 'UIButton' do |ss|
    ss.source_files = "CYToolkit/Classes/UIButton/*"
    ss.public_header_files = "CYToolkit/Classes/UIButton/*.h"
  end

  s.subspec 'UIColor' do |ss|
    ss.source_files = "CYToolkit/Classes/UIColor/*"
    ss.public_header_files = "CYToolkit/Classes/UIColor/*.h"
  end

  s.subspec 'UIDevice' do |ss|
    ss.source_files = "CYToolkit/Classes/UIDevice/*"
    ss.public_header_files = "CYToolkit/Classes/UIDevice/*.h"
  end

  s.subspec 'UIFont' do |ss|
    ss.source_files = "CYToolkit/Classes/UIFont/*"
    ss.public_header_files = "CYToolkit/Classes/UIFont/*.h"
  end

  s.subspec 'UIView' do |ss|
    ss.source_files = "CYToolkit/Classes/UIView/*"
    ss.public_header_files = "CYToolkit/Classes/UIView/*.h"
  end

  s.subspec 'UIViewController' do |ss|
    ss.source_files = "CYToolkit/Classes/UIViewController/*"
    ss.public_header_files = "CYToolkit/Classes/UIViewController/*.h"
  end

  s.subspec 'UIWebView' do |ss|
    ss.source_files = "CYToolkit/Classes/UIWebView/*"
    ss.public_header_files = "CYToolkit/Classes/UIWebView/*.h"
  end

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  # s.library   = "z"
  # s.libraries = "iconv", "xml2"
  
  s.requires_arc = true
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
