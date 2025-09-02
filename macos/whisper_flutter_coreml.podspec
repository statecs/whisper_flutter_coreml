#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint whisper_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'whisper_flutter_coreml'
  s.version          = '1.0.2'
  s.summary          = 'A Flutter FFI plugin for Whisper.cpp.'
  s.description      = <<-DESC
A Flutter FFI plugin for Whisper.cpp.
                       DESC
  s.homepage         = 'https://cstate.se'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'statecs' => 'hello@cstate.se' }
  s.source           = { :path => '.' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes**/*.h'
  s.dependency 'FlutterMacOS'
  s.framework = 'CoreML'
  s.platform = :osx, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.xcconfig = {
      'CLANG_CXX_LANGUAGE_STANDARD' => 'c++20',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'WHISPER_USE_COREML=1 WHISPER_COREML_ALLOW_FALLBACK=1 NDEBUG=1',
      'CLANG_ENABLE_OBJC_ARC' => 'YES',
  }
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }
  s.swift_version = '5.0'
end
