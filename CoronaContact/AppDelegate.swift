//
//  AppDelegate.swift
//  CoronaContact
//

import UIKit
import Resolver
import UserNotifications
import Firebase
import Lottie

enum ScreenSize {
    case small, medium, large
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: ApplicationCoordinator!

    private var serivcesInitialized: Bool = false

    @Injected private var configService: ConfigurationService
    @Injected private var cryptoService: CryptoService
    @Injected private var nearbyService: NearbyService
    @Injected private var msgUpdateService: MessageUpdateService
    @Injected private var appUpdateService: AppUpdateService
    @Injected private var notificationService: NotificationService
    @Injected private var messageUpdateService: MessageUpdateService
    @Injected private var databaseService: DatabaseService
    @Injected private var healthRepository: HealthRepository

    var isBroadcastActive: Bool { nearbyService.isSharing }

    lazy var screenSize: ScreenSize = {
        let width = UIScreen.main.bounds.size.width
        if width >= 414 { return .large } else if width >= 375 { return .medium }
        return .small
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        registerFontStyles()
        styleNavigationBar()

        LoggingService.info("Application starting with launchOptions: \(String(describing: launchOptions))",
                            context: .application)

        databaseService.migrate()
        cryptoService.createKeysIfNeeded()
        healthRepository.cleanupOldHealthReportsAndContacts()

        UNUserNotificationCenter.current().delegate = self

        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = ApplicationCoordinator(window: window)
        appCoordinator.start()

        if UserDefaults.standard.hasSeenOnboarding {
            initializeExternalServices(application)
            checkPermissions()
        }

        return true
    }

    func initializeExternalServices(_ application: UIApplication) {
        guard serivcesInitialized == false else { return }

        FirebaseApp.configure()

        configService.update()
        msgUpdateService.update()

        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        subscribeToAddressPrefixTopic()

        serivcesInitialized = true
    }

    func startNearbySharing() {
        if isBroadcastActive { return }
        guard var data = self.cryptoService.generatedName.data(using: .utf8) else { return }
        let pubKey = self.cryptoService.getPublicKey()
        guard let pubkey = pubKey else { return }
        data.append(pubkey)
        self.nearbyService.startSharing(data)
    }

    @objc func checkPermissions() {
        let errors = nearbyService.getPermissionErrors()
        if errors.nearby {
            DispatchQueue.main.async {
                self.nearbyService.grantPermission() // approved by Sven / Sebastian in teams call 26.03. 19:25
            }
            return
        }

        if !errors.any {
            startNearbySharing()
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        msgUpdateService.update()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LoggingService.error("Unable to register for remote notifications: \(error.localizedDescription)",
                             context: .application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appUpdateService.showUpdateAlertIfNecessary()
        if serivcesInitialized {
            msgUpdateService.update()
            startNearbySharing()
        }
    }
}

// MARK: Messaging

extension AppDelegate: MessagingDelegate {
    private func subscribeToAddressPrefixTopic() {
        guard let addressPrefix = cryptoService.getMyPublicKeyPrefix() else {
            return
        }
        Messaging.messaging().subscribe(toTopic: addressPrefix)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        subscribeToAddressPrefixTopic()
    }
}

// MARK: Styling

extension AppDelegate {
    func styleNavigationBar() {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = .white
        navigationBarAppearace.isTranslucent = false
        navigationBarAppearace.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler
                                completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == NotificationServiceKeys.selfTestPush {
            appCoordinator?.startSelfTestExternally()
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler
                                completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        msgUpdateService.update()
        completionHandler([.alert, .sound])
    }
}
