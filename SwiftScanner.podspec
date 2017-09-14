Pod::Spec.new do |spec|
  spec.name = 'SwiftScanner'
  spec.version = '1.0.3'
  spec.summary = 'Pure native Swift implementation of a string scanner; with no dependecies and full unicode support.'
  spec.homepage = 'https://github.com/malcommac/SwiftScanner'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'Daniele Margutti' => 'me@danielemargutti.com' }
  spec.social_media_url = 'http://twitter.com/danielemargutti'
  spec.source = { :git => 'https://github.com/malcommac/SwiftScanner.git', :tag => "#{spec.version}" }
  spec.source_files = 'Sources/**/*.swift'
  spec.ios.deployment_target = '8.0'
  spec.watchos.deployment_target = '2.0'
  spec.osx.deployment_target = '10.10'
  spec.tvos.deployment_target = '9.0'
  spec.requires_arc = true
  spec.module_name = 'SwiftScanner'
end
