## Branch Metrics Example

This project shows the recommended approach to implement the Branch Metrics kit, including listening for deferred and deep links. See `AppDelegate.m` for the annotated implementation. 

Follow the steps below to get the project working in your environment:

1. Run `pod install` to get the latest mParticle and Branch SDKs, then open the created Xcode workspace.
2. Update `AppDelegate.m` with an mParticle key/secret that has Branch Metrics enabled.
3. Update the bundle ID to one that you can provision for and have input into the Branch Metrics Dashboard.
4. [Update the URL scheme](https://dev.branch.io/getting-started/sdk-integration-guide/guide/ios/#register-a-uri-scheme) in the Info.plist
5. [Update the Associated Domains entitlement](https://dev.branch.io/getting-started/universal-app-links/guide/ios/) to be configured with your Branch Metrics app link domain. 
