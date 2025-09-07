//
//  AppDelegate.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 1/7/25.
//

import UIKit
import GoogleMobileAds


class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // Preload the interstitial ad
        Task {
            await AdManager.shared.loadInterstitialAd()
        }

        return true
    }
}
