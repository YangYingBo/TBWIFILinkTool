#
# Be sure to run `pod lib lint TBWIFILinkTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TBWIFILinkTool'
  s.version          = '0.1.1'
  s.summary          = 'TBWIFILinkTool 给WiFi模块配置WiFi的工具类.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 使用EasyLink和ESPTouch给不同的WiFi模块配置WiFi的工具类.
                       DESC

  s.homepage         = 'https://github.com/YangYingBo/TBWIFILinkTool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YangYingBo' => '946076292@qq.com' }
  s.source           = { :git => 'https://github.com/YangYingBo/TBWIFILinkTool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TBWIFILinkTool/Classes/**/*'
  # 引用非系统静态库
  s.ios.vendored_libraries  = 'TBWIFILinkTool/Classes/**/*.a'
  # 引用系统静态库
  # s.ios.libraries
  # s.resource_bundles = {
  #   'TBWIFILinkTool' => ['TBWIFILinkTool/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # 配置依赖的系统框架
  s.frameworks = 'UIKit', 'Foundation'
  # 配置需要引用的非系统框架
  # s.vendored_frameworks：
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.subspec 'EasyLink' do |ss|
      ss.source_files = 'TBWIFILinkTool/Classes/EasyLink/*.{h,m}'
  end
  
  s.subspec 'ESPTouch' do |ss|
      ss.source_files = 'TBWIFILinkTool/Classes/ESPTouch/**/*.{h,m}'
      
  end
  
end
