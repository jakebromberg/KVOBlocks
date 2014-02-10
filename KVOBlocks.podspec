Pod::Spec.new do |s|
  s.name         = "KVOBlocks"
  s.version      = "0.0.1"
  s.summary      = "A blocks-based interface over Apple's KVO API"
  s.description  = <<-DESC
                   KVO is one of Cocoa's best weapons. Unfortunately, it's also
                   its worst APIs. KVOBlocks combines KVO with Objective-Cs most
                   powerful recent language addition, blocks.
                   DESC
  s.homepage     = "https://github.com/jakebromberg/KVOBlocks"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Jake Bromberg" => "jake.bromberg@gmail.com" }
  s.social_media_url = "http://twitter.com/JakeBromberg"
  s.platform     = :ios
  s.platform     = :ios, '5.0'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.source       = { :git => "https://github.com/jakebromberg/KVOBlocks.git", :commit => "8fc8d5fc5a12df12f361e810d566f3cd6b50654e" }
  s.source_files  = 'Classes', 'JBKVOBlocks/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.public_header_files = 'JBKVOBlocks/**/*.h'
  s.requires_arc = true
end
