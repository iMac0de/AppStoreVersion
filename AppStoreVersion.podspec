Pod::Spec.new do |s|
  s.name         = "AppStoreVersion"
  s.version      = "1.0.1"
  s.summary      = "An easy Swift framework to check your latest app version available on the AppStore and compare it to the installed version"
  s.description  = <<-DESC
			An easy Swift framework to check your latest app version available on the AppStore and compare it to the installed version.
                   DESC
  s.homepage     = "https://github.com/iMac0de/AppStoreVersion/blob/master/README.md"
  s.license      = "MIT"
  s.author             = { "iMac0de" => "contact@jeremy-peltier.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/iMac0de/AppStoreVersion.git", :tag => "#{s.version}" }
  s.source_files  = "AppStoreVersion", "AppStoreVersion/*.{h,m,swift}"
  s.resource_bundle = { "Localizable" => "AppStoreVersion/*.lproj/*.strings" }
  s.dependency "Alamofire"
end
