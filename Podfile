platform :ios, '5.0'

inhibit_all_warnings!

pod 'SVProgressHUD', :head
pod 'FFCircularProgressView'
pod 'JLRoutes'
pod 'NLCoreData'
pod 'Evernote-SDK-iOS'
pod 'Dropbox-iOS-SDK'
pod 'uservoice-iphone-sdk', '~> 2.0'
pod 'CrittercismSDK'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'NicolaEditor/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
