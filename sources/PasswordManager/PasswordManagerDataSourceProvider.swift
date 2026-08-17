//
//  PasswordManagerDataSourceProvider.swift
//  iTerm2SharedARC
//
//  Created by George Nachman on 3/19/22.
//

import Foundation
import LocalAuthentication

@objc(iTermPasswordManagerDataSourceProvider)
class PasswordManagerDataSourceProvider: NSObject {
    @objc static let forTerminal = PasswordManagerDataSourceProvider(browser: false)
    @objc static let forBrowser = PasswordManagerDataSourceProvider(browser: true)
    @objc private(set) var authenticated = false
    private var _dataSource: PasswordManagerDataSource? = nil
    private var dataSourceType: DataSource!
    private let _keychain: KeychainPasswordDataSource
    private var _onePassword: OnePasswordDataSource
    private var _lastPass: LastPassDataSource
    private var _keePassXC: AdapterPasswordDataSource
    private var _bitwarden: AdapterPasswordDataSource
    private var _keeper: AdapterPasswordDataSource
    #if ITERM_DEBUG
    private var _testAdapter: AdapterPasswordDataSource
    #endif
    private let browser: Bool
    private var dataSourceNameUserDefaultsKey: String {
        "NoSyncPasswordManagerDataSourceName" + (browser ? "Browser" : "")
    }

    enum DataSource: String {
        case keychain = "Keychain"
        case onePassword = "OnePassword"
        case lastPass = "LastPass"
        case keePassXC = "KeePassXC"
        case bitwarden = "Bitwarden"
        case keeper = "Keeper"
        #if ITERM_DEBUG
        case testAdapter = "TestAdapter"
        #endif

        static let defaultValue = DataSource.keychain
    }

    init(browser: Bool) {
        _keychain = KeychainPasswordDataSource(browser: browser)
        _onePassword = OnePasswordDataSource(browser: browser)
        _lastPass = LastPassDataSource(browser: browser)

        let keepassPath = Bundle(for: Self.self).path(forAuxiliaryExecutable: "iterm2-keepassxc-adapter")!
        _keePassXC = AdapterPasswordDataSource(browser: browser,
                                               adapterPath: keepassPath,
                                               identifier: "KeePassXC")

        let bitwardenPath = Bundle(for: Self.self).path(forAuxiliaryExecutable: "iterm2-bitwarden-adapter")!
        _bitwarden = AdapterPasswordDataSource(browser: browser,
                                               adapterPath: bitwardenPath,
                                               identifier: "Bitwarden")

        let keeperPath = Bundle(for: Self.self).path(forAuxiliaryExecutable: "iterm2-keeper-adapter")!
        _keeper = AdapterPasswordDataSource(browser: browser,
                                            adapterPath: keeperPath,
                                            identifier: "Keeper Security")
        #if ITERM_DEBUG
        let testAdapterPath = Bundle(for: Self.self).path(forAuxiliaryExecutable: "iterm2-test-adapter")!
        _testAdapter = AdapterPasswordDataSource(browser: browser,
                                                 adapterPath: testAdapterPath,
                                                 identifier: "Test Adapter")
        #endif

        self.browser = browser

        super.init()

        dataSourceType = preferredDataSource
    }

    var preferredDataSource: DataSource {
        get {
            let rawValue = iTermUserDefaults.userDefaults().string(forKey: dataSourceNameUserDefaultsKey) ?? ""
            return DataSource(rawValue: rawValue) ?? DataSource.defaultValue
        }
        set {
            iTermUserDefaults.userDefaults().set(newValue.rawValue, forKey: dataSourceNameUserDefaultsKey)
            _dataSource = nil
        }
    }

    @objc var dataSource: PasswordManagerDataSource? {
        guard authenticated else {
            return nil
        }
        guard let existing = _dataSource else {
            let fresh = { () -> PasswordManagerDataSource in
                switch preferredDataSource {
                case .keychain:
                    return keychain!
                case .onePassword:
                    return onePassword!
                case .lastPass:
                    return lastPass!
                case .keePassXC:
                    return keePassXC!
                case .bitwarden:
                    return bitwarden!
                case .keeper:
                    return keeper!
                #if ITERM_DEBUG
                case .testAdapter:
                    return testAdapter!
                #endif
                }
            }()
            _dataSource = fresh
            return fresh
        }
        return existing
    }

    @objc func enableKeePassXC() {
        preferredDataSource = .keePassXC
    }

    @objc var keePassXCEnabled: Bool {
        return preferredDataSource == .keePassXC
    }

    @objc func enableBitwarden() {
        preferredDataSource = .bitwarden
    }

    @objc var bitwardenEnabled: Bool {
        return preferredDataSource == .bitwarden
    }

    @objc func enableKeychain() {
        preferredDataSource = .keychain
    }

    @objc var keychainEnabled: Bool {
        return preferredDataSource == .keychain
    }

    @objc func enable1Password() {
        preferredDataSource = .onePassword
    }

    @objc var onePasswordEnabled: Bool {
        return preferredDataSource == .onePassword
    }

    @objc func enableLastPass() {
        preferredDataSource = .lastPass
    }

    @objc var lastPassEnabled: Bool {
        return preferredDataSource == .lastPass
    }

    @objc func enableKeeper() {
        preferredDataSource = .keeper
    }

    @objc var keeperEnabled: Bool {
        return preferredDataSource == .keeper
    }

    @objc var keychain: PasswordManagerDataSource? {
        if !authenticated {
            return nil
        }
        return _keychain
    }

    private var onePassword: OnePasswordDataSource? {
        if !authenticated {
            return nil
        }
        return _onePassword
    }

    private var lastPass: LastPassDataSource? {
        if !authenticated {
            return nil
        }
        return _lastPass
    }

    private var keePassXC: AdapterPasswordDataSource? {
        if !authenticated {
            return nil
        }
        return _keePassXC
    }

    private var bitwarden: AdapterPasswordDataSource? {
        if !authenticated {
            return nil
        }
        return _bitwarden
    }

    private var keeper: AdapterPasswordDataSource? {
        if !authenticated {
            return nil
        }
        return _keeper
    }
    #if ITERM_DEBUG
    private var testAdapter: AdapterPasswordDataSource? {
        if !authenticated {
            return nil
        }
        return _testAdapter
    }

    @objc func enableTestAdapter() {
        preferredDataSource = .testAdapter
    }

    @objc var testAdapterEnabled: Bool {
        return preferredDataSource == .testAdapter
    }
    #endif
    @objc func revokeAuthentication() {
        authenticated = false
    }

    @objc func requestAuthenticationIfNeeded(_ completion: @escaping (Bool) -> ()) {
        if authenticated {
            completion(true)
            return
        }
        if !SecureUserDefaults.instance.requireAuthToOpenPasswordmanager.value {
            authenticated = true
            completion(true)
            return
        }
        let context = LAContext()
        let policy = LAPolicy.deviceOwnerAuthentication
        var error: NSError? = nil
        if !context.canEvaluatePolicy(policy, error: &error) {
            RLog("Can't evaluate \(policy): \(error?.localizedDescription ?? "(nil)")")
            return
        }
        iTermApplication.shared().localAuthenticationDialogOpen = true
        let reason = NSLocalizedString("open the password manager", comment: "UI")
        context.evaluatePolicy(policy, localizedReason: reason) { success, error in
            RLog("Policy evaluation success=\(success) error=\(String(describing: error))")
            DispatchQueue.main.async {
                iTermApplication.shared().localAuthenticationDialogOpen = false
                if success {
                    self.authenticated = true
                    completion(true)
                } else {
                    self.authenticated = false
                    if let error = error as NSError?, (error.code != LAError.systemCancel.rawValue &&
                                                       error.code != LAError.appCancel.rawValue) {
                        self.showError(error)
                    }
                    completion(false)
                }
            }
        }
    }

    @objc func consolidateAvailabilityChecks(_ block: () -> ()) {
        if let dataSource = dataSource {
            dataSource.consolidateAvailabilityChecks(block)
            return
        }
        block()
    }

    private func showError(_ error: NSError) {
        let alert = NSAlert()
        let reason: String
        switch LAError.Code(rawValue: error.code) {
        case .authenticationFailed:
            reason = NSLocalizedString("valid credentials weren't supplied.", comment: "UI");

        case .userCancel:
            reason = NSLocalizedString("password entry was cancelled.", comment: "UI");

        case .userFallback:
            reason = NSLocalizedString("password authentication was requested.", comment: "UI");

        case .systemCancel:
            reason = NSLocalizedString("the system cancelled the authentication request.", comment: "UI");

        case .passcodeNotSet:
            reason = NSLocalizedString("no passcode is set.", comment: "UI");

        case .touchIDNotAvailable:
            reason = NSLocalizedString("touch ID is not available.", comment: "UI");

        case .biometryNotEnrolled:
            reason = NSLocalizedString("touch ID doesn't have any fingers enrolled.", comment: "UI");

        case .biometryLockout:
            reason = NSLocalizedString("there were too many failed Touch ID attempts.", comment: "UI");

        case .appCancel:
            reason = NSLocalizedString("authentication was cancelled by iTerm2.", comment: "UI");

        case .invalidContext:
            reason = NSLocalizedString("the context is invalid. This is a bug in iTerm2. Please report it.", comment: "UI");

        case .none:
            reason = error.localizedDescription

        case .touchIDNotEnrolled:
            reason = NSLocalizedString("touch ID is not enrolled.", comment: "UI")

        case .touchIDLockout:
            reason = NSLocalizedString("touch ID is locked out.", comment: "UI")

        case .notInteractive:
            reason = NSLocalizedString("the required user interface could not be displayed.", comment: "UI")

        case .watchNotAvailable:
            reason = NSLocalizedString("watch is not available.", comment: "UI")

        case .biometryNotPaired:
            reason = NSLocalizedString("biometry is not paired.", comment: "UI")

        case .biometryDisconnected:
            reason = NSLocalizedString("biometry is disconnected.", comment: "UI")

        case .invalidDimensions:
            reason = NSLocalizedString("invalid dimensions given.", comment: "UI")

        @unknown default:
            reason = error.localizedDescription
        }
        alert.messageText = NSLocalizedString("Authentication Failed", comment: "UI")
        alert.informativeText = String(format: NSLocalizedString("Authentication failed because %@", comment: "UI"), reason)
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "UI"))
        alert.runModal()
    }
}

