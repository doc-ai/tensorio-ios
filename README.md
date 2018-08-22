# TensorIO

[![CI Status](https://img.shields.io/travis/phil@phildow.net/TensorIO.svg?style=flat)](https://travis-ci.org/phil@phildow.net/TensorIO)
[![Version](https://img.shields.io/cocoapods/v/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![License](https://img.shields.io/cocoapods/l/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![Platform](https://img.shields.io/cocoapods/p/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)

TensorIO is ...

TensorIO is machine learning on iOS in four lines of code:

```objc
UIImage *image = [UIImage imageNamed:@"example-image"];
TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];

id<TIOModel> model = [TIOModelBundleManager.sharedManager bundleWithId:@"mobilenet-v2-100-224-unquantized"].newModel;
NSDictionary *inference = (NSDictionary*)[model runOn:buffer];

```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TensorIO is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TensorIO'
```

## Author

philip@doc.ai

## License

TensorIO is available under the Apache 2 license. See the LICENSE file for more info.
