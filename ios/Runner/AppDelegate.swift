// import Flutter
// import UIKit
// import FirebaseCore

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     FirebaseApp.configure()
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }



import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import PushKit
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
  private var voipRegistry: PKPushRegistry?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    // ✅ Add these lines for APNs registration
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    // ✅ Register PushKit (VoIP) token for reliable CallKit on lock screen/terminated state.
    _setupVoipPushRegistry()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }

  // override func application(
  //   _ application: UIApplication,
  //   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  // ) {
  //   // Ensure Firebase gets the APNs token and log it for debugging.
  //   Messaging.messaging().apnsToken = deviceToken
  //   let token = deviceToken.map { String(format: "%02x", $0) }.joined()
  //   NSLog("APNs device token: \(token)")
  //   super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  // }
override func application(
  _ application: UIApplication,
  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Foundation.Data
) {
  Messaging.messaging().apnsToken = deviceToken
  let token = deviceToken.map { String(format: "%02x", $0) }.joined()
  NSLog("APNs device token: \(token)")
  super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
}

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("APNs registration failed: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  private func _setupVoipPushRegistry() {
    let registry = PKPushRegistry(queue: DispatchQueue.main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
    voipRegistry = registry
  }

  private func _looksLikeUuid(_ value: String) -> Bool {
    return UUID(uuidString: value) != nil
  }

  // MARK: - PushKit (VoIP)

  func pushRegistry(
    _ registry: PKPushRegistry,
    didUpdate pushCredentials: PKPushCredentials,
    for type: PKPushType
  ) {
    guard type == .voIP else { return }
    let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token)
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didInvalidatePushTokenFor type: PKPushType
  ) {
    guard type == .voIP else { return }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()

      return
    }

    NSLog("PushKit: received VoIP push payload=\(payload.dictionaryPayload)")
    let args = _extractCallkitArgs(from: payload.dictionaryPayload)
    guard !args.isEmpty else {
      NSLog("PushKit: invalid payload for CallKit: \(payload.dictionaryPayload)")
      completion()
      return
    }

    let callData = flutter_callkit_incoming.Data(args: args)
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(
      callData,
      fromPushKit: true,
      completion: completion
    )
    NSLog("PushKit: CallKit showCallkitIncoming invoked id=\(args["id"] ?? "")")
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType
  ) {
    pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) {}
  }

private func _extractCallkitArgs(from raw: [AnyHashable: Any]) -> [String: Any] {
    func toStringKeyed(_ any: Any) -> [String: Any]? {
        if let dict = any as? [String: Any] { return dict }
        if let dict = any as? [AnyHashable: Any] {
            var out: [String: Any] = [:]
            for (k, v) in dict {
                if let ks = k as? String { out[ks] = v }
            }
            return out
        }
        return nil
    }

    let root = toStringKeyed(raw) ?? [:]
    
    // 1. Check if "meta" exists and decode the JSON string
    var appointmentData: [String: Any] = [:]
    if let metaString = root["meta"] as? String,
       let data = metaString.data(using: .utf8) {
        do {
            if let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                appointmentData = decoded
            }
        } catch {
            print("Error decoding meta JSON: \(error)")
        }
    } else {
        // Fallback to existing logic if meta isn't a string
        appointmentData = toStringKeyed(root["data"] as Any) ?? root
    }

    var args = appointmentData
    print("Decoded Call Data:", args)

    // 2. Normalize ID (Handle Mongo _id or appointmentId)
    if args["id"] == nil {
        if let oid = args["_id"] as? String {
            args["id"] = oid
        } else if let aid = args["appointmentId"] as? String {
            args["id"] = aid
        }
    }

    // 3. Normalize Caller Name from the doctor object
    if args["nameCaller"] == nil {
        if let doctor = toStringKeyed(args["doctor"] as Any),
           let doctorName = doctor["name"] as? String {
            args["nameCaller"] = doctorName
        } else {
            args["nameCaller"] = "Doctor"
        }
    }

    // 4. Normalize Handle (Subtitle)
    if args["handle"] == nil {
        args["handle"] = args["appointmentType"] as? String ?? "Regular Appointment"
    }

    // 5. Mandatory UUID Validation for CallKit
    let id = (args["id"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    
    // ✅ Ensure we pass the WHOLE decoded appointment as 'extra'
    // This makes the tokens and other data available to Flutter on accept
    args["extra"] = appointmentData

    if !_looksLikeUuid(id) {
        let newUuid = UUID().uuidString
        args["id"] = newUuid
        // Store the original Mongo ID in extra so Flutter can use it later
        var extra = args["extra"] as? [String: Any] ?? [:]
        extra["originalId"] = id
        args["extra"] = extra
    }

    return args
}
}
