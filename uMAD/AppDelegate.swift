import UIKit
import Parse
import Fabric
import TwitterKit


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var currentUMAD: UMAD?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Twitter.self])
        registerParseSubclasses()
        Parse.setApplicationId(Config.parseAppID, clientKey: Config.parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        PFConfig.getConfigInBackgroundWithBlock(nil)
        let umadQuery = UMAD.query()
        umadQuery?.orderByDescending("year")
        umadQuery?.limit = 1
        do {
             // A large amount of the code depends on knowing the latest conference.
             // Making this synchronous makes it easier to ensure that the app is showing
             // the latest information.
            let results = try umadQuery?.findObjects()
            if let resultUMADs = results as? [UMAD],
                let umad = resultUMADs.first {
                    AppDelegate.currentUMAD = umad
            }
        } catch {
            print("Configure a UMAD class to represent the current conference")
        }


        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        UINavigationBar.appearance().barTintColor = Config.tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        let tabBarController = configureTabBarController()

        window = UIWindow()
        window?.rootViewController = tabBarController

        window?.makeKeyAndVisible()
        window?.tintColor = Config.tintColor

        return true
    }

    func registerParseSubclasses() {
        Session.registerSubclass()
        Company.registerSubclass()
        User.registerSubclass()
        UMAD.registerSubclass()
        UMADSponsor.registerSubclass()
        UMADApplication.registerSubclass()
        UMADApplicationStatus.registerSubclass()
    }

    func configureTabBarController() -> UITabBarController {
        let sessionsViewController = UINavigationController(rootViewController: SessionsViewController())
        let twitterViewController = UINavigationController(rootViewController: TimelineViewController())
        let sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        let aboutViewController = UINavigationController(rootViewController: AboutViewController())

        let tabBarController = SelectionHookTabBarController()
        tabBarController.viewControllers = [sessionsViewController, twitterViewController, sponsorsViewController, aboutViewController]

        sessionsViewController.tabBarItem.title = "Sessions"
        sessionsViewController.tabBarItem.image = UIImage(named: "calendar.png")
        sessionsViewController.tabBarItem.selectedImage = UIImage(named: "calendar-filled.png")

        twitterViewController.tabBarItem.title = "Twitter"
        twitterViewController.tabBarItem.image = UIImage(named: "twitter.png")
        twitterViewController.tabBarItem.selectedImage = UIImage(named: "twitter-filled.png")

        sponsorsViewController.tabBarItem.title = "Partners"
        sponsorsViewController.tabBarItem.image = UIImage(named: "sponsors.png")
        sponsorsViewController.tabBarItem.selectedImage = UIImage(named: "sponsors-filled.png")

        aboutViewController.tabBarItem.title = "About"
        aboutViewController.tabBarItem.image = UIImage(named: "aboutus.png")
        aboutViewController.tabBarItem.selectedImage = UIImage(named: "aboutus-filled.png")
        return tabBarController
    }

}
