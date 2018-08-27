Pod::Spec.new do |s|

  s.name         = "Keldeo"
  s.version      = "0.0.1"
  s.summary      = "A lightweight logging library written in Swift."

  s.description  = <<-DESC
                   Log.i("A lightweight logging library written in Swift.")
                   DESC

  s.homepage     = "https://github.com/xspyhack/Keldeo"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "xspyhack" => "xspyhack@gmail.com" }
  s.social_media_url   = "http://twitter.com/xspyhack"

  s.platform     = :ios
  s.ios.deployment_target    = "10.0"

  s.source       = { :git => "https://github.com/xspyhack/Keldeo.git", :tag => "#{s.version}" }

  s.source_files  = "Keldeo/*.swift"

end