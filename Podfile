platform :ios, '15.0'

target 'berkeley-mobile' do
  platform :ios, '18.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for berkeley-mobile
  pod 'Firebase/Analytics'
  pod 'Firebase'
  pod 'FirebaseMessaging'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
end

target 'BerkeleyMobileWidgetExtension' do
  platform :ios, '17.0'
  use_frameworks!

  pod 'Firebase/Firestore'
end

# Raise outdated Pod and resource bundle targets to Xcode's supported minimum.
post_install do |installer|
  configurations = installer.pods_project.build_configurations +
    installer.pods_project.targets.flat_map(&:build_configurations)

  configurations.each do |config|
    deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
    if deployment_target && Gem::Version.new(deployment_target) < Gem::Version.new('15.0')
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

