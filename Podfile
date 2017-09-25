platform :ios, '8.0'

inhibit_all_warnings!

target 'NicolaEditor' do
  pod 'SVProgressHUD'
  pod 'FFCircularProgressView'
  pod 'JLRoutes'
  pod 'NLCoreData'
  pod 'Evernote-SDK-iOS'
  pod 'ObjectiveDropboxOfficial'
  pod 'uservoice-iphone-sdk'
  pod 'CrittercismSDK'

  post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-NicolaEditor/Pods-NicolaEditor-acknowledgements.plist', 'NicolaEditor/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end
end
