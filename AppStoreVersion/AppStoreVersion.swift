//
//  AppStoreVersion.swift
//  AppStoreVersion
//
//  Created by Jérémy Peltier on 25/10/2018.
//  Copyright © 2018 Jérémy Peltier. All rights reserved.
//

import Foundation

open class AppStoreVersion {

    private static var appStoreVersionBundle: Bundle {
        let path = Bundle(for: AppStoreVersion.self).path(forResource: "Localizable", ofType: "bundle")!
        let bundle = Bundle(path: path) ?? Bundle.main
        return bundle
    }

    private class var version: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    private static var cache: [String: Any]? = nil

    private struct Keys {
        static let kAppStoreResultsKey = "results"
        static let kAppStoreVersionKey = "version"
        static let kAppStoreURLKey = "trackViewUrl"
    }

    public struct Config {
        public static var optional: Bool = true
        public struct Alert {
            public static var title: String = NSLocalizedString("AppStoreVersion.NewVersionTitle", tableName: nil, bundle: appStoreVersionBundle, value: "", comment: "")
            public static var message: String = NSLocalizedString("AppStoreVersion.NewVersionMessage", tableName: nil, bundle: appStoreVersionBundle, value: "", comment: "")
            public static var downloadActionTitle: String = NSLocalizedString("AppStoreVersion.Download", tableName: nil, bundle: appStoreVersionBundle, value: "", comment: "")
            public static var laterActionTitle: String = NSLocalizedString("AppStoreVersion.Later", tableName: nil, bundle: appStoreVersionBundle, value: "", comment: "")
        }
    }

    public static var latestVersionAvailable: String = ""
    
    private class func endpoint(for bundle: Bundle) -> URL? {
        if let identifier = bundle.bundleIdentifier {
            let base = "https://itunes.apple.com/%@/lookup?bundleId=%@"
            let locale = Locale.current.regionCode ?? "US"
            let endpoint = String(format: base, locale, identifier)
            if let url = URL(string: endpoint) {
                return url
            }
        }
        return nil
    }
    
    /**
     The `AppStoreVersionEnum` holds all error cases of the framework.
     */
    public enum AppStoreVersionError: Error {
        // This error will be returned if the request to the App Store lookup API returns an invalid response code.
        case invalidAppStoreResponseCode
        
        // This error will be returned if the framework is unable to read the JSON returned from the App Store lookup API.
        case unableToReadAppStoreResponse
        
        // This error will be returned if the framework is not able to find the mandatory keys in the JSON returned from the App Store lookup API.
        case mandatoryKeysNotFound
        
        // This error will be returned if the framework is not able to find the App Store version of your app in the JSON returned from the App Store lookup API.
        case appStoreVersionNotFound
    }

    /**
     This method can be used to check if the param bundle version is the latest version available on the AppStore corresponding to the param bundle identifier. It will manage the display of an `UIAlertController` with an `UIAlertAction` to download the latest version if needed.

     - Important: The given bundle must have the `CFBundleShortVersionString` in the `Info.plist` file.
     - Parameter bundle: The bundle of the application to check. Can be retrieve with `Bundle.main`.
     */
    open class func check(bundle: Bundle) {
        AppStoreVersion.check(bundle: bundle) { (upToDate, error) in
            if error != nil {
                NSLog("AppStoreVersion (%@): %@", AppStoreVersion.version, error!.localizedDescription)
            } else if !upToDate {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: Config.Alert.title, message: String(format: Config.Alert.message, AppStoreVersion.latestVersionAvailable), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: Config.Alert.downloadActionTitle, style: .default, handler: { (_) in
                        guard let storeURLString = cache?[Keys.kAppStoreURLKey] as? String, let storeURL = URL(string: storeURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(storeURL) {
                            UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
                        }
                    }))
                    if Config.optional {
                        alertController.addAction(UIAlertAction(title: Config.Alert.laterActionTitle, style: .cancel, handler: { (_) in
                            alertController.dismiss(animated: true, completion: nil)
                        }))
                    }
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    /**
     This method can be used to check if the param bundle version is the latest version available on the AppStore corresponding to the param bundle identifier. If will call a completion handle with an two parameters. This first one is a `Bool` value which specify if the bundle is up to date. The second one is an optional `Error` during the process.

     - Important: The given bundle must have the `CFBundleShortVersionString` in the `Info.plist` file.
     - Parameter bundle: The bundle of the application to check. Can be retrieve with `Bundle.main`.
     - Parameter completion: A completion handler which will be call when the checking is completed.
     - Parameter upToDate: If `true`, the given bundle version is the latest version available on the AppStore. If `false`, a new version is available.
     - Parameter error: An optional `AppStoreVersionError` which will help you to understand why it doesn't work.
    */
    open class func check(bundle: Bundle, _ completion: @escaping (_ upToDate: Bool, _ error: Error?) -> Void) {
        guard let url = endpoint(for: bundle), let currentVersion = bundle.infoDictionary!["CFBundleShortVersionString"] as? String else {
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(false, AppStoreVersionError.unableToReadAppStoreResponse)
                return
            }
            
            guard (200...299) ~= response.statusCode else {
                completion(false, AppStoreVersionError.invalidAppStoreResponseCode)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(false, AppStoreVersionError.unableToReadAppStoreResponse)
                    return
                }

                guard let results = json[Keys.kAppStoreResultsKey] as? NSArray, let result = results.firstObject as? [String: Any] else {
                    completion(false, AppStoreVersionError.mandatoryKeysNotFound)
                    return
                }
                
                guard let appStoreVersion = result[Keys.kAppStoreVersionKey] as? String else {
                    completion(false, AppStoreVersionError.appStoreVersionNotFound)
                    return
                }
                
                if currentVersion >= appStoreVersion {
                    completion(true, nil)
                } else {
                    completion(false, nil)
                }
            } catch {
                completion(false, AppStoreVersionError.unableToReadAppStoreResponse)
            }
        }
        task.resume()
    }

}
