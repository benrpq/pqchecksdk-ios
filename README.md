# PQCheckSDK for iOS (Objective C)

[![Build Status](https://travis-ci.org/post-quantum/pqchecksdk-ios.svg?branch=develop)](https://travis-ci.org/post-quantum/pqchecksdk-ios)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

PQCheckSDK for iOS requires iOS 8.0 and above.

The following third-party open source libraries/frameworks are used :-

1. [AFNetworking](https://github.com/AFNetworking/AFNetworking) ([MIT licence](https://github.com/AFNetworking/AFNetworking/blob/master/LICENSE))
2. [RestKit](https://github.com/RestKit/RestKit) ([Apache licence version 2.0](https://github.com/RestKit/RestKit/blob/development/LICENSE))
3. [MBProgressHUD](https://github.com/jdg/MBProgressHUD) ([MIT licence](https://github.com/jdg/MBProgressHUD/blob/master/LICENSE))
4. [SimpleKeychain](https://github.com/auth0/SimpleKeychain) ([MIT licence](https://github.com/auth0/SimpleKeychain/blob/master/LICENSE))
5. [SDAVAssetExportSession](https://github.com/rs/SDAVAssetExportSession) ([MIT licence](https://github.com/rs/SDAVAssetExportSession/blob/master/LICENSE))

All the above libraries/frameworks, except `SDAVAssetExportSession` which is included in the SDK, will be automatically fetched via [CocoaPods](http://cocoapods.org).

The unit test of PQCheck SDK depends on the following frameworks :-

1. [Kiwi](https://github.com/kiwi-bdd/Kiwi) (See the [licence](https://github.com/kiwi-bdd/Kiwi/blob/master/License.txt) file)
2. [OCHamrest](https://github.com/hamcrest/OCHamcrest) ([BSD licence](https://github.com/hamcrest/OCHamcrest/blob/master/LICENSE.txt))
3. [ILTesting](https://github.com/InfiniteLoopDK/ILTesting) (Unspecified licence type)

The `ILTesting` library is included in the SDK, the other two will be fetched automatically by CocoaPods.

Due to `RestKit`, PQCheck SDK requires CocoaPods version 0.38.0, it does not work with a higher version of CocoaPods. Once `RestKit` is updated, this restriction may be lifted. In order to use multiple versions of CocoaPods, please install [Bundler](http://bundler.io).

## Installation

PQCheckSDK is available through CocoaPods. To install it, simply add the following line to your Podfile:

```ruby
pod PQCheckSDK
```
 
You can also clone the repository to build the example code, as shown below:

```
git clone https://github.com/post-quantum/pqchecksdk-ios.git
cd pqchecksdk-ios
pod install --project-directory=Example
```

In order to create a framework of PQCheck SDK for iOS, you can use [CocoaPods Packager](https://github.com/CocoaPods/cocoapods-packager).

```
pod package PQCheckSDK.podspec
```

## Reference

[PQCheck in Retail Banking](http://post-quantum.github.io/pqchecksdk-ios/example/html/index.html) shows an example of how PQCheck and its iOS SDK are used in retail banking.

## Author

Post-Quantum, https://post-quantum.com

## License

PQCheckSDK is available under the Apache license version 2.0. See the [LICENSE](LICENSE) file for more info.
