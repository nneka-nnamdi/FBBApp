import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyCHiedOxWSdmw8JgLFTbTVEJTdjM1PQ4p0")
    let controller = window.rootViewController as! FlutterViewController

        let flavorChannel = FlutterMethodChannel(
            name: "flavor",
            binaryMessenger: controller.binaryMessenger)

        flavorChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread
            let flavor = Bundle.main.infoDictionary?["App - Flavor"]
            result(flavor)
        })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
