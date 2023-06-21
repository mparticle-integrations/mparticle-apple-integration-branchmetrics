//
//  AppDelegate.swift
//  Fortune
//
//  Created by Edward Smith on 10/3/17.
//  Copyright © 2017 Branch. All rights reserved.
//

import UIKit
import mParticle_Apple_SDK
import mParticle_BranchMetrics
import BranchSDK

@UIApplicationMain
class APAppDelegate: UIResponder, UIApplicationDelegate {

    @IBOutlet var window: UIWindow?
    @IBOutlet var fortuneViewController: APFortuneViewController?
    static var shared: APAppDelegate?

    func application(_ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        APAppDelegate.shared = self
        
        // Initialize our app data source:
        APAppData.shared.initialize()

        // Turn on all the debug output for testing:
        Branch.getInstance().enableLogging()
        
        // Start mParticle
        let mParticle = MParticle.sharedInstance()
        mParticle.logLevel = .debug
        let options = MParticleOptions.init(
            key: "REPLACE WITH YOUR KEY",
            secret: "REPLACE WITH YOUR SECRET"
        )
        let request = MPIdentityApiRequest.withEmptyUser()
        request.email = "foo@example.com"
        request.customerId = "cust_123456"
        options.identifyRequest = request
        options.environment = .production
        options.onAttributionComplete = {
        (attributionResult: MPAttributionResult?, error: Error?) -> Void in
            self.attribution(result: attributionResult, error: error)
        }
        mParticle.start(with: options)

        return true
    }

    func attribution(result: MPAttributionResult?, error: Error?) {
        if  let error = error {
            self.window?.rootViewController?.showAlert(
                title: "Attribution Error",
                message: error.localizedDescription
            )
            return
        }
        if  let result = result,
            let linkWasClicked = result.linkInfo[BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] as? Bool,
            linkWasClicked,
            let name = result.linkInfo["name"] as! String?,
            let message = result.linkInfo["message"] as! String? {
            self.fortuneViewController?.showFortune(name: name, message: message)
        }
    }
}
