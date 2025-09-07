//
//  AdManager.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 1/7/25.
//

import GoogleMobileAds
import Foundation

class AdManager: NSObject { // Inherit from NSObject
    static let shared = AdManager()

    private var interstitialAd: GADInterstitialAd?
    var onAdDismissed: (() -> Void)? // Callback for ad dismissal

    func loadInterstitialAd() async {
        print("Atempting to add interstitial ad.")
        do {
            interstitialAd = try await GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-3584358903688856/3469622120",  //this is the real ad id to be used when live
                request: GADRequest()
            )
            print("Interstitial ad loaded successfully.")
        } catch {
            print("Failed to load interstitial ad: \(error.localizedDescription)")
        }
    }
    
    func isAdReady() -> Bool {
           return interstitialAd != nil
       }
    
    
    func showInterstitialAd(from rootViewController: UIViewController) {
        guard let ad = interstitialAd else {
            print("Ad is not ready yet.")
            return
        }
        // 🔹 Ensure root view controller is valid
               guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
                   print("❌ Root view controller not found. Cannot presetn ad.")
                   return
               }
        
        ad.fullScreenContentDelegate = self // Set delegate to handle dismissal
        
        print("Presenting interstitial ad...")
        ad.present(fromRootViewController: rootViewController)
        
       
    }
}

extension AdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad was dismissed. Loading a new one")
        interstitialAd = nil // Reset the ad after it's shown
        Task {
                    await loadInterstitialAd() // Preload the next ad after dismissal
                }
        
        onAdDismissed?() // Call the callback when the ad is dismissed
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
    }

    // Removed `adDidPresentFullScreenContent` since it's unavailable
}

         
