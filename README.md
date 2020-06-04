<h1 align="center">
  <br>
  Stopp Corona
  <br>
</h1>

<p align="center">
  <a href="#about">About</a> •
  <a href="#aim-and-function">Aim and function</a> •
  <a href="#reporting-corona-infections">Reporting Corona infections</a> •
  <a href="#your-data-is-safe">Your data is safe</a> •
  <a href="#requirements">Requirements</a> •
  <a href="#installation">Installation</a> •
  <a href="#license">License</a>
</p>

# About

This Corona-Tracing-App is an Open-Source-Project to track and trace contacts. It is based on the model of the "Stopp Corona"-App by the Austrian Red Cross. This App has been adapted for use in Germany by digital marketing agency Mandarin Medien G.f.d.L mbh.

# Aim and function

This Corona-Tracing-App can contribute largely in the fight against the Covid-19 virus. It documents the digital handshake of two or more mobile phones. People who have come in contact with an infected person can be informed swiftly. Speedy exchange of information is essential when trying to break the Covid-19 transmission chain.
Using a virtual handshake the App registers all persons in the vicinity. The handshake has to be executed manually to register the contact on the device anonymously. Encrypted contact information is stored on the device for up to 72 hours.

# Reporting Corona infections

In case of a confirmed case of Corona the infected user can voluntarily and anonymously inform everybody they came into contact with during the last 72 hours. The encrypted IDs of the infected individual are then made available to all mobile phones running the Corona-Tracing-App. Subsequently the devices then check, if contact with the infected person has occured. The App then informs the user anonymously and they are able to self-isolate before becoming infectious.

# Your data is safe

The Corona-Tracing-App is completely voluntary. The App generates IDs for all contacts stored on the phone which are then encrypted and stored separately. Notifications are always processed anonymously.

# Requirements

* Xcode 11
* CocoaPods (v1.9.1 or higher)

# Installation

1. Clone this repository.
2. `cd` to the project's directory and run `pod install` to install the third party dependencies. In case your spec sources are out of date, run `pod install --repo-update` instead.
3. Open `CoronaContact.xcworkspace`
4. You will need to provide your own app secrets in order to run the app. **The app will not build when you do not provide these values**. They can be set in the following places:
    1. There is a template for a `Secrets.xcconfig` file in the `Configuration` folder. It contains keys for defining the API base URL, the API authorization key and the Google Nearby API key for the staging and production environment.
    2. Copy the Firebase config file `GoogleService-Info.plist` in the folder `Configuration` to enable firebase push notifications.
    3. Copy the public server certificate as `Configuration/server.der` into the project. If you don't want to use certificate pinning you have to disable it in `Services/Network/Networksession.swift`
5. You can choose between three different build schemes:
    1. *CoronaContact (Development)*: used for development, uses staging environment
    2. *CoronaContact (Staging)*: uses staging environment
    3. *CoronaContact (Production)*: uses production environment

# License

This code is distributed under the Apache License 2.0. See the [LICENSE.txt](LICENSE.txt) file for more info.
Notices for third party libraries in this repository are contained in [NOTICE.txt](NOTICE.txt).
