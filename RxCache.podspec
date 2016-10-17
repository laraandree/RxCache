Pod::Spec.new do |s|
  s.name             = "RxCache"
  s.version          = "1.0.0"
  s.summary          = "Reactive caching library for Swift"

  s.homepage         = "https://github.com/FuckBoilerplate/RxCache"
  s.license          = 'MIT'
  s.author           = { "Victor Albertos" => "me@victoralbertos.com" } 
  s.source           = { :git => "https://github.com/FuckBoilerplate/RxCache.git", :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/FuckBoilerplate'

  s.watchos.deployment_target = '2.0'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = 'Sources/Core/**/*'
    ss.dependency "RxSwift", ">= 3.0.0-beta.1"
  end

  s.subspec "ObjectMapper" do |ss|
    ss.source_files = 'Sources/Cacheabe/ObjectMapper/*.swift'
    ss.dependency "RxCache/Core"
  end

  s.subspec "Gloss" do |ss|
    ss.source_files = 'Sources/Cacheabe/Gloss/*.swift'
    ss.dependency "RxCache/Core"
  end

end
