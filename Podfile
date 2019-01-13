# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'My_Accounting_Book' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'RealmSwift'
  
  pod "Fuse"

  #source 'https://github.com/CocoaPods/Specs.git'
  #platform :ios, '9.0'
  #use_frameworks!
  
  pod 'DropDown'

  pod 'SideMenu'

  pod 'iOSDropDown'

  pod "FuzzyMatchingSwift"

  pod 'TesseractOCRiOS', :git => 'https://github.com/gali8/Tesseract-OCR-iOS.git'

  pod 'OpenCV'

  pod 'DatePickerDialog'

  pod "SearchTextField"

  pod "Dropper"
  
  pod 'TransitionableTab', '~> 0.2.0'

  pod 'SwiftEntryKit', '0.8.7'

  pod 'QuickLayout', '2.1.1'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

  # Pods for My_Accounting_Book

  target 'My_Accounting_BookTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'My_Accounting_BookUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
