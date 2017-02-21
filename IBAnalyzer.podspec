Pod::Spec.new do |s|

  s.name         = "IBAnalyzer"
  s.version      = "0.2.1"
  s.summary      = "Tool for finding xib and storyboard-related issues at the build time."

  s.homepage     = "https://github.com/fastred/IBAnalyzer"
  s.license      = "MIT"
  s.author       = { "Arkadiusz Holko" => "fastred@fastred.org" }
  s.social_media_url = "https://twitter.com/arekholko"

  s.source       = { :http => "https://github.com/fastred/IBAnalyzer/releases/download/#{s.version}/ibanalyzer-#{s.version}.zip" }
  s.preserve_paths = '*'

end
