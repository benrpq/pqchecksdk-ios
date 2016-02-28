PQCheck is a video signature system which ties individuals and organisations to an agreement, creating binding contracts at a distance.

There are three actors in the PQCheck system :-

1. The PQCheck server or engine;
2. Your application server;
3. An app on the end-user's smart phone or computer.

The end-user's app can only communicate with your application server, which in turn, interacts the PQCheck server. The end-user's app does not interact directly with the PQCheck server. Instead, your application server must provide a URI to the end-user's app in order for it to perform a specific function with the PQCheck server.

This PQCheck SDK sits on the app on an end-user's iOS device. The core functionalities of PQCheck are encapsulated in `PQCheckManager` class.