platform :ios, '10.0'

inhibit_all_warnings!

target 'NicolaEditor' do
  pod 'SVProgressHUD'
  pod 'FFCircularProgressView'
  pod 'JLRoutes'
  pod 'NLCoreData'
  pod 'EvernoteSDK'
  pod 'ObjectiveDropboxOfficial'
  pod 'uservoice-iphone-sdk'

  post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-NicolaEditor/Pods-NicolaEditor-acknowledgements.plist', 'NicolaEditor/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end
end
