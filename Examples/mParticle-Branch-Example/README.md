# mParticle-Branch Example

## Overview

This sample app demonstrates:

• How to use the mParticle and Branch in a simple Swift 4 application.

• How to create and share Branch links in your app.

• How to create a QR code from a Branch link.

• How to Branch deep links are handled in an app.

• How event tracking is handled in mParticle and Branch.

## Share your Super Secret Fortune!  

This app creates Branch deep links that have a 'secret' message associated with them. You can send the link to your friend, and when your friend clicks the link (or scans the QR code), the app will open and reveal the message. If your friend doesn't have the app they'll be directed to the app store to get the app, and because the link is a Branch deferred deep link, when they open the app, the message will still appear.

The other tab in the app tests the mParticle / Branch integration. In the app you can send mParticle events and confirm that these events appear in both the mParticle and Branch dashboards.

## Building & Running the Code

To build the code, install the Cocopods from the command line:
```
cd mParticle-Branch-Example
pod install 
pod update
```

Open the project wrokspace `mParticle.xcworkspace` in Xcode and choose "Product > Run" from the main menu.
The project will build and run.
