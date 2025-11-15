import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    // App is about to enter background - request background execution time
    print("[AppDelegate] App will resign active - requesting background task")

    backgroundTaskIdentifier = application.beginBackgroundTask { [weak self] in
      // Called when background time is about to expire
      print("[AppDelegate] Background task expiring - cleaning up")
      self?.endBackgroundTask()
    }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    // App returned to foreground - end background task if still running
    print("[AppDelegate] App became active - ending background task")
    endBackgroundTask()
  }

  private func endBackgroundTask() {
    if backgroundTaskIdentifier != .invalid {
      print("[AppDelegate] Ending background task: \(backgroundTaskIdentifier)")
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
      backgroundTaskIdentifier = .invalid
    }
  }
}
