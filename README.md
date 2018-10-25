<p align="center">
  <img width="256" height="256" src="https://www.jeremy-peltier.com/wp-content/uploads/2018/10/AppStoreVersion.png">
</p>

# AppStoreVersion

Because it is not always easy to maintain some features depending on the versions installed, especially if you have a REST API that is evolving with the app you are developing, I decide to create this framework to check if the users have the latest version available.

[![Version](https://img.shields.io/cocoapods/v/AppStoreVersion.svg?style=flat)](http://cocoadocs.org/docsets/AppStoreVersion)
[![Build Status](https://travis-ci.com/iMac0de/AppStoreVersion.svg?branch=master)](https://travis-ci.com/iMac0de/AppStoreVersion)
[![License](https://img.shields.io/cocoapods/l/AppStoreVersion.svg?style=flat)](http://cocoadocs.org/docsets/AppStoreVersion)
[![Platform](https://img.shields.io/cocoapods/p/AppStoreVersion.svg?style=flat)](http://cocoadocs.org/docsets/AppStoreVersion)
![Swift](https://img.shields.io/badge/%20in-swift%204.2-blue.svg)

## Install

**AppStoreVersion** is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'AppStoreVersion'
```

## Usage

The usage of this framework is very simple. You have two ways to check if the installed version is the latest available.

#### The easiest way :sunglasses:

If you want to let the framework manage the prompt alert to your users, just call in your code where you want to check the version:

```swift
AppStoreVersion.check(bundle: Bundle.main)
```
If the installed version of your app is the latest, it will do nothing. If it is not the latest, it will prompt an UIAlertViewController with an UIAlertAction to redirect yours users to the page of your app in the AppStore.

#### The freedom way :rocket:

If you want to manage the display to your users, it is also very simple, you just need to call:

```swift
AppStoreVersion.check(bundle: Bundle.main) { (upToDate, error) in
    if error != nil {
        print(error!.localizedDescription)
    } else if !upToDate {
	    //TODO: Display to the users that their not using the latest version.
    }
}
```

## Localization

This framework is based on the current device localization and will display, if there is no localization translations for the current locale, the english version will be used.

#### Available

:uk: :fr:

#### Add a localization

*Looking for a translation? Create a pull request or open an issue.*

| Key | Example |
|-----|---------|
| AppStoreVersion.NewVersionTitle | New Version Available ! |
| AppStoreVersion.NewVersionMessage | The version %@ is available on the AppStore. |
| AppStoreVersion.Download | Download |
| AppStoreVersion.Later | Later |

## Config

In order to be a very flexible framework, you can configure some features and data directly from your code.

For example, by default, the prompt alert displayed by the framework give to the users a "Later" button which will hide the `UIAlertViewController`. If you want to force your users to download the latest version, just say it:

```swift
AppStoreVersion.Config.optional = false
```

You can also configure the localization yourself:

```swift
AppStoreVersion.Config.Alert.title = "New version!"
AppStoreVersion.Config.Alert.message = "Find out our new features."
AppStoreVersion.Config.Alert.downloadActionTitle = "Let's do it!"
AppStoreVersion.Config.Alert.laterActionTitle = "No, thanks."
```

#### Default values

| Config | Default |
|--------|---------|
| `AppStoreVersion.Config.optional` | `true` |
| `AppStoreVersion.Config.Alert.title` | `NSLocalizedString("AppStoreVersion.NewVersionTitle", comment: "")` |
| `AppStoreVersion.Config.Alert.message` | `NSLocalizedString("AppStoreVersion.NewVersionMessage", comment: "")` |
| `AppStoreVersion.Config.Alert.downloadActionTitle` | `NSLocalizedString("AppStoreVersion.Download", comment: "")` |
| `AppStoreVersion.Config.Alert.laterActionTitle` | `NSLocalizedString("AppStoreVersion.Later", comment: "")` |

## Contribute

This framework is very simple, and I want it to stay like this. But any new features or suggestions are always welcome, so feel free to create a pull request or open an issue.

## Author

Made with :heart: by [iMac0de](https://github.com/iMac0de) from Bordeaux, France :fr::wine_glass:

## Apps using this framework

[![Elyot](https://is1-ssl.mzstatic.com/image/thumb/Purple118/v4/38/54/54/385454a5-d2de-2fd6-5087-9de9ee0c7131/source/100x100bb.jpg)](https://itunes.apple.com/fr/app/elyot/id1350122672?mt=8&uo=4)
