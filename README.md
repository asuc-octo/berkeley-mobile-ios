# Berkeley-Mobile-iOS

This is the official repository for the Berkeley Mobile iOS application.

## What is Berkeley Mobile?

Created in 2012, Berkeley Mobile has acculumated over 20,000 downloads on iOS and Android and currently has about 2,000 Monthly Active Users (MAUs). It has Bear Transit routes, library and gym information, dining hall menus, and campus resources, all in one place for the busy Berkeley student. The mission of Berkeley Mobile is to use cool technology to help students navigate Berkeley. You can download Berkeley Mobile on [the Google Play Store](https://play.google.com/store/apps/details?id=com.asuc.asucmobile&hl=en_US) or [the App Store](https://itunes.apple.com/us/app/berkeley-mobile/id912243518?mt=8).

<p align="center">
  <img src="/app_preview_images/screen1.png" width="200"/>
  <img src="/app_preview_images/screen2.png" width="200"/>
  <img src="/app_preview_images/screen3.png" width="200"/>
  <img src="/app_preview_images/screen4.png" width="200"/>
</p>

*Berkeley Mobile is a product of the Associated Students of University of California (ASUC) Office of the Chief Technology Officer (OCTO) and is not affiliated with the University of California, Berkeley or the Regents of the University of California.*

## Documentation

For documentation, check out our [wiki](https://github.com/asuc-octo/berkeley-mobile-ios/wiki). The wiki is a work in progress and should be completed soon.

The application consists of eight modules:
* [Academics](berkeleyMobileiOS/Classes/Academics): for Libraries and Campus Resources features 
* [Dining](berkeleyMobileiOS/Classes/Dining): for dining hall and cafe features 
* [Favorites](berkeleyMobileiOS/Classes/Favorites): favoriting feature 
* [Recreation](berkeleyMobileiOS/Classes/Recreation): for gyms and gym classes features 
* [Resource](berkeleyMobileiOS/Classes/Resource): acts as the base for features 
* [Search](berkeleyMobileiOS/Classes/Search): search functionality, currently not being used 
* [Transit](berkeleyMobileiOS/Classes/Transit): for Bear Transit feature
* [Util](berkeleyMobileiOS/Classes/Util): some misc. utilities


## Getting set up

It is recommended you use XCode 9.2 or higher and Swift 3. Install [Cocoapods](https://guides.cocoapods.org/using/getting-started.html) and be sure to run pod install in the berkeley-mobile-ios directory. 

### APIs

* Create a new project in the [Google Cloud Console](https://console.cloud.google.com)
  * Under the APIs and Services tab, enable the Google Places API for iOS, Google Maps SDK for iOS, Google Maps Directions API, and Google Maps Geocoding API
  * Under the Credentials tab, create an API key
  * Paste your API key into [secret.xml](app/src/main/res/values/secret.xml)
* We've configured this repository so that the application pulls from our sandbox backend, which just returns test data. If you would like access to our production backend API, please [contact us](#contact). 

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## <a name="todo"></a> TODO

The following is a summary of open tasks and issues. For new contributors, we recommend focusing on Improvements. **Before starting to work on new features or large changes not listed below, especially ones that involve UI changes or new APIs, please [contact us](#contact)!**

### What the Berkeley Mobile team is working on

* Crowd sourcing water fountain, microwave, and nap pod locations


### Feature Ideas

* Favoriting items such as libraries, food items 
* We might be open to partnerships with student orgs

## <a name="contact"></a> Contact

You can contact the Berkeley Mobile team at octo.berkeleymobile@asuc.org with any questions.

## License

This project uses the Educational Community License (ECL) 2.0. See [LICENSE.md](LICENSE.md) for more information.
