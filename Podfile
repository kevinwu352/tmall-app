source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
inhibit_all_warnings!
use_frameworks!


def all_pods
pod 'Cache'
pod 'Alamofire'
pod 'SwiftEntryKit', :git => 'https://github.com/kevinwu352/SwiftEntryKit.git', :branch => 'dev'
pod 'MJRefresh'
pod 'SnapKit'
pod 'R.swift'
pod 'SwiftyJSON'
pod 'Atributika'
pod 'AtributikaViews'
pod 'Kingfisher'
end


workspace 'TmallApp.xcworkspace'

target 'TmallApp' do
  all_pods
end

target 'ModCommon' do
  project 'Modules/ModCommon/ModCommon'
  all_pods
end

target 'ModHomePage' do
  project 'Modules/ModHomePage/ModHomePage'
  all_pods
end

target 'ModHuaSuan' do
  project 'Modules/ModHuaSuan/ModHuaSuan'
  all_pods
end

target 'ModShopCar' do
  project 'Modules/ModShopCar/ModShopCar'
  all_pods
end

target 'ModUserCenter' do
  project 'Modules/ModUserCenter/ModUserCenter'
  all_pods
end


post_install do |installer|
  installer.pods_project.targets.each do |target|

    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end

    next if !target.name.start_with?('Pods-')
    target.build_configurations.each do |config|
      path = config.base_configuration_reference.real_path
      File.open(path, 'a') do |file|
        file.puts "#include \"../../../Support/#{target.name.sub('Pods-', '')}.#{config.name.downcase}.xcconfig\""
      end
    end

  end
end
