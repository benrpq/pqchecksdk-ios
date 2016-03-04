PQCheck is a video signature system which ties individuals and organisations to an agreement, creating binding contracts at a distance.

There are three actors in the PQCheck system :-

1. The PQCheck server or engine;
2. Your application server;
3. An app on the end-user's smart phone or computer.

The end-user's app can only communicate with your application server, which in turn interacts with the PQCheck server. The end-user's app does not interact directly with the PQCheck server. Instead, your application server must provide a URI to the end-user's app in order for it to perform a specific function with the PQCheck server.

This PQCheck SDK sits on the app on an end-user's iOS device. The core functionalities of PQCheck are encapsulated in `PQCheckManager` class. 

> **Note** [PQCheck in Retail Banking](./example/html/index.html) shows an example of how PQCheck and its iOS SDK are used in retail-banking.

The SDK requires iOS 8 or later and it depends on the following frameworks :-

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) ([MIT licence](https://github.com/AFNetworking/AFNetworking/blob/master/LICENSE))
- [RestKit](https://github.com/RestKit/RestKit) ([Apache licence version 2.0](https://github.com/RestKit/RestKit/blob/development/LICENSE))
- [MBProgressHUD](https://github.com/jdg/MBProgressHUD) ([MIT licence](https://github.com/jdg/MBProgressHUD/blob/master/LICENSE))
- [SimpleKeychain](https://github.com/auth0/SimpleKeychain) ([MIT licence](https://github.com/auth0/SimpleKeychain/blob/master/LICENSE))
- [SDAVAssetExportSession](https://github.com/rs/SDAVAssetExportSession) ([MIT licence](https://github.com/rs/SDAVAssetExportSession/blob/master/LICENSE))
--- Included in PQCheck SDK

The unit test of PQCheck SDK depends on the following frameworks :-

- [Kiwi](https://github.com/kiwi-bdd/Kiwi) (See the [licence](https://github.com/kiwi-bdd/Kiwi/blob/master/License.txt) file)
- [OCHamrest](https://github.com/hamcrest/OCHamcrest) ([BSD licence](https://github.com/hamcrest/OCHamcrest/blob/master/LICENSE.txt))
- [ILTesting](https://github.com/InfiniteLoopDK/ILTesting) (Unspecified licence type)
--- Included in PQCheck SDK unit test

