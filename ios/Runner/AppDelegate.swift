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

    // Many backends wrap custom data under `data` or `callkit`.
    let root = toStringKeyed(raw) ?? [:]
    let nested =
      toStringKeyed(root["data"] as Any) ??
      toStringKeyed(root["callkit"] as Any) ??
      root

    var args = nested

    // Normalize common key variants to plugin expected keys.
    if args["id"] == nil, let uuid = args["uuid"] as? String {
      args["id"] = uuid
    }
    if args["id"] == nil {
      if let appointmentId = args["appointmentId"] as? String {
        args["id"] = appointmentId
      } else if let appointmentId = args["_id"] as? String {
        args["id"] = appointmentId
      } else if let callId = args["callId"] as? String {
        args["id"] = callId
      }
    }
    if args["nameCaller"] == nil, let name = args["name"] as? String {
      args["nameCaller"] = name
    }
    if args["nameCaller"] == nil {
      if let callerName = args["callerName"] as? String {
        args["nameCaller"] = callerName
      } else if let doctorName = args["doctorName"] as? String {
        args["nameCaller"] = doctorName
      } else if let doctor = toStringKeyed(args["doctor"] as Any),
                let doctorName = doctor["name"] as? String {
        args["nameCaller"] = doctorName
      }
    }
    if args["handle"] == nil {
      if let appointmentType = (args["appointmentType"] as? String) ?? (args["typeLabel"] as? String) {
        args["handle"] = appointmentType
      }
    }
    if args["handle"] == nil {
      if let type = args["type"] as? String, !type.isEmpty {
        args["handle"] = type
      } else if let title = args["title"] as? String, !title.isEmpty {
        args["handle"] = title
      } else {
        args["handle"] = "Appointment"
      }
    }

    // Hard-require minimal fields for CallKit UI.
    let id = (args["id"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    let nameCaller = (args["nameCaller"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    let handle = (args["handle"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    if id.isEmpty || nameCaller.isEmpty || handle.isEmpty {
      NSLog("PushKit: missing required CallKit fields id=\(id) name=\(nameCaller) handle=\(handle)")
      return [:]
    }

    if !_looksLikeUuid(id) {
      let newId = UUID().uuidString
      let originalId = id
      args["id"] = newId
      args["uuid"] = newId
      var extra = toStringKeyed(args["extra"] as Any) ?? [:]
      if extra["appointmentId"] == nil && !originalId.isEmpty {
        extra["appointmentId"] = originalId
      }
      args["extra"] = extra
    }
    return args
  }
}
