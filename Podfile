platform :ios, '5.0'

pod 'SVProgressHUD'
pod 'FFCircularProgressView'
pod 'JLRoutes'
pod 'NLCoreData'
pod 'Evernote-SDK-iOS'
pod 'Dropbox-iOS-SDK'
pod 'UrbanAirship-iOS-SDK'
pod 'Helpshift'
pod 'CrittercismSDK'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'NicolaEditor/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
