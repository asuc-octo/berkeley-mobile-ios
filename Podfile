# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'berkeley-mobile' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for berkeley-mobile
  pod 'Firebase/Analytics'
  pod 'Firebase/Firestore'
  pod 'IQKeyboardManagerSwift'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  pod "SearchTextField"
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end

  xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`

    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            # For xcode 15+ only
             if config.base_configuration_reference && Integer(xcode_base_version) >= 15
                xcconfig_path = config.base_configuration_reference.real_path
                xcconfig = File.read(xcconfig_path)
                xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
                File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
            end
        end
    end
end
