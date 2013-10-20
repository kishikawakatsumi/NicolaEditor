platform :ios, "5.0"

pod 'SVProgressHUD'
pod 'NLCoreData'
pod 'Evernote-SDK-iOS'
pod 'Dropbox-iOS-SDK'
pod 'Helpshift'
pod 'BugSense'
pod 'TestFlightSDK'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'NicolaEditor/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
