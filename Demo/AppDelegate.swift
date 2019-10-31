//
//  AppDelegate.swift
//  Demo
//
//  Created by Joky on 2019/10/26.
//  Copyright © 2019 eyee. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
       PayPalMobile .initializeWithClientIds(forEnvironments: [
            PayPalEnvironmentProduction: "AVVqWao33LPDnCVywKW9sSOGuc6sXmEAZBp9gBaxQuILzpdxyKaMGsq3ftTI1YuBl2OwIX9zr8uwhA-e",
            PayPalEnvironmentSandbox: "AUYB8RF_Odr7wdlmCtsnYqP_inP00ERWV6rqmncIo7333k8TPjeyRlHuvZwI2aZsxtdttzIlfmDNTOKg"])
       window = UIWindow(frame: UIScreen.main.bounds)
       window?.rootViewController = TabbarVC()
       window?.backgroundColor = UIColor.white
       window?.makeKeyAndVisible()
        return true
    }

    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return ApplicationDelegate.shared.application(
        application,
        open: url,
        sourceApplication: sourceApplication,
        annotation: annotation
      )
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
      return ApplicationDelegate.shared.application(application, open: url, options: options)
    }


}

