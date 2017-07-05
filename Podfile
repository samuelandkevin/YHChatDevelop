platform :ios, '9.0'
target 'YHChatDevelop' do
    use_frameworks!
    pod 'Masonry'
    pod 'MJRefresh'
    pod 'HYBMasonryAutoCellHeight'
    pod 'YYKit'
    pod 'SDWebImage'
    pod 'AFNetworking'
    pod 'SocketRocket'
    pod 'FMDB'
    pod 'TZImagePickerController'
    pod 'FDFullscreenPopGesture'
    pod 'SnapKit'
    pod 'Kingfisher'
    post_install do |installer|
        puts("Update debug pod settings to speed up build time")
        Dir.glob(File.join("Pods", "**", "Pods*{debug,Private}.xcconfig")).each do |file|
            File.open(file, 'a') { |f| f.puts "\nDEBUG_INFORMATION_FORMAT = dwarf" }
        end
    end
end
