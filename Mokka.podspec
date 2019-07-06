Pod::Spec.new do |spec|
  spec.name                      = "Mokka"
  spec.version                   = "1.0.0"
  spec.summary                   = "A collection of helpers to make it easier to write testing mocks in Swift."
  spec.homepage                  = "https://github.com/danielr/Mokka"
  spec.license                   = { :type => "MIT", :file => "LICENSE" }
  spec.author                    = "Daniel Rinser"
  spec.social_media_url          = "https://twitter.com/@danielrinser"
  spec.source                    = { :git => "https://github.com/danielr/Mokka.git", :tag => "#{spec.version}" }
  spec.source_files              = "Mokka/Sources/**/*.swift"
  spec.framework                 = "Foundation"
  spec.swift_version             = "5.0"
  spec.ios.deployment_target     = "9.0"
  spec.osx.deployment_target     = "10.9"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target    = "9.0"
end
