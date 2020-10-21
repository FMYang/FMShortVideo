Pod::Spec.new do |s|

  s.name         = "FMHttpRequest"  # 名字
  s.version      = "0.0.4"         # 版本号
  s.summary      = "简单的网络抽象层" # 简介
  s.description  = "简单的网络抽象层，方便使用，支持自定义JSON解析，链式调用" # 介绍
  s.homepage     = "http://fmyang.github.io/" # 主页
  s.license      = 'MIT' # 开源协议
  s.author       = { 'yangfangming' => 'yangfangming@tuandai.com' } # 作者
  s.source       = { :git => 'FMShortVideo/', :tag => s.version.to_s } # 远端地址和版本号
  
  s.platforms    = { :ios => "10.0", } # 指定ios系统，=>8.0表示8.0及以上系统
  s.requires_arc = true # 是否使用arc
  
  s.source_files = 'FMHttpRequest/*.{h,m,swift,bundle,json}' # 指定使用的源文件
  s.dependency 'AFNetworking'
  
end
