#
# Be sure to run `pod lib lint TensorIO.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TensorIO'
  s.version          = '0.3.3'
  s.summary          = 'An Objective-C wrapper for TensorFlow Lite.'
  s.description      = 'Perform inference with TensorFlow Lite models using all the conveniences of Objective-C'
  s.homepage         = 'https://github.com/doc-ai/tensorio-ios'
  s.license          = { :type => 'Apache 2', :file => 'LICENSE' }
  s.authors          = { 'Philip Dow' => 'philip@doc.ai' }
  s.source           = { :git => 'https://github.com/doc-ai/tensorio-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'
  s.static_framework = true
  s.library = 'c++'
  
  s.frameworks = 'Foundation', 'AVFoundation', 'CoreMedia', 'Accelerate', 'VideoToolbox'
  s.dependency 'TensorFlowLite'
  
  s.source_files = 'TensorIO/Classes/**/*'
  s.private_header_files = [
    'TensorIO/Classes/TIO Model/TIOPixelBufferToTensorHelpers.h'
  ]
  
  s.xcconfig = {
    'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/TensorFlowLite/Frameworks/tensorflow_lite.framework/Headers"',
  }
end
