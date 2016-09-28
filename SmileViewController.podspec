Pod::Spec.new do |s|

  s.name         = "SmileViewController"
  s.version      = "1.0.0"
  s.summary      = "UIViewController that allows to detect smile in real time."
  s.description  = <<-DESC
 UIViewController that allows to detect smile in real time (AVFoundation and CoreImage). There are additional features like photo sharing (Facebook, Twitter). It's also possible to take new selfie by pressing re-take button.
                   DESC
  s.homepage     = "https://github.com/MaximAlien/SmileViewController"
  s.screenshots  = "https://raw.githubusercontent.com/MaximAlien/SmileViewController/master/resources/example.png"
  s.license      = "MIT"
  s.author       = { "MaximAlien" => "maxim.makhun@gmail.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/MaximAlien/SmileViewController", :tag => "0.0.1" }
  s.source_files  = "SmileViewController", "SmileViewController/**/*.{h,m}"
  s.frameworks = "AVFoundation", "CoreImage", "UIKit", "Foundation", "Social"
  s.requires_arc = true

end
