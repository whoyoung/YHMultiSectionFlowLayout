#
#  Be sure to run `pod spec lint YHFlowLayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "YHFlowLayout"
  spec.version      = "0.0.1"
  spec.summary      = "YHFlowLayout support UICollectionView waterfall flow layout and multiple section."

  spec.description  = <<-DESC
      YHFlowLayout support UICollectionView waterfall flow layout and multiple section.
                   DESC

  spec.homepage     = "https://github.com/whoyoung/YHMultiSectionFlowLayout"

  spec.license      = "MIT"

  spec.author       = { "yanghu" => "mr_yanghu@163.com" }
  
  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "git@github.com:whoyoung/YHMultiSectionFlowLayout.git", :tag => "#{spec.version}" }

  spec.source_files  = "Classes", "Classes/YHFlowLayout.swift"

end
