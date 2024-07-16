platform :ios, '12.0'

# ignore all warnings from all pods
inhibit_all_warnings!
use_frameworks!

target 'CoronaContact' do
  # Pods for CoronaContact
  pod 'NearbyMessages'
  pod 'SwiftLint'
  pod 'Resolver'
  pod 'Moya', '~> 14.0.0'
  pod 'SwiftRichString'
  pod 'Reusable'
  pod 'SQLite.swift', '~> 0.12.0'
  pod 'M13Checkbox'
  pod 'Carte'
  pod 'Firebase/Messaging'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'lottie-ios'
  pod 'SwiftyBeaver'
  pod 'SQLiteMigrationManager.swift'

  target 'CoronaContactTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
  end

  # Integration of licenses generation (see https://github.com/devxoul/Carte)
  pods_dir = File.dirname(installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end
