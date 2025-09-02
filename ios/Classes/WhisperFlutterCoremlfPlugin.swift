import Flutter
import UIKit

public class WhisperFlutterCoremlfPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Register the memory handler
    WhisperMemoryHandler.register(with: registrar)
  }
}