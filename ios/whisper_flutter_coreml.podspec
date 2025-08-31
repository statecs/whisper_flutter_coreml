#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint whisper_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'whisper_flutter_coreml'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter FFI plugin for Whisper.cpp.'
  s.description      = <<-DESC
A Flutter FFI plugin for Whisper.cpp.
                       DESC
  s.homepage         = 'https://www.xcl.ink'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '田梓萱' => 'zixuanxcl@gmail.com' }
  s.source           = { :path => '.' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes**/*.h'
  s.dependency 'Flutter'
  s.framework = 'CoreML'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.xcconfig = {
      'CLANG_CXX_LANGUAGE_STANDARD' => 'c++20',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'WHISPER_USE_COREML=1 NDEBUG=1',
      'CLANG_ENABLE_OBJC_ARC' => 'YES',
  }
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  s.swift_version = '5.0'
end
