Pod::Spec.new do |s|

  s.name         = "SmileViewController"
  s.version      = "1.0.4"
  s.summary      = "UIViewController which allows to detect smile in real time."
  s.description  = <<-DESC
 UIViewController which allows to detect smile in real time by using AVFoundation and CoreImage frameworks.
                   DESC
  s.homepage     = "https://github.com/MaximAlien/SmileViewController"
  s.screenshots  = "https://raw.githubusercontent.com/MaximAlien/SmileViewController/master/resources/example.png"
  s.license      = "MIT"
  s.author       = { "MaximAlien" => "maxim.makhun@gmail.com" }
  s.platform     = :ios, "11.0"
  s.ios.deployment_target = '11.0'
  s.source       = { :git => "https://github.com/MaximAlien/SmileViewController.git", :tag => "1.0.4" }
  s.source_files  = "SmileViewController", "SmileViewController/**/*.{h,m}"
  s.resources    = "SmileViewController/**/*.{xib}"
  s.frameworks   = "AVFoundation", "CoreImage", "UIKit", "Foundation"
  s.requires_arc = true

end
