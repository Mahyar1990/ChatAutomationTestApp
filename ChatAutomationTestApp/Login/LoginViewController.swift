//
//  LoginViewController.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/15/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import WebKit
import UIKit
import CommonCrypto


class LoginViewController: UIViewController {
    
    var codeChallengeUrl:   String  = ""
    var code_challenge:     String  = ""
    var code:               String  = ""
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tryToLogin()
    }
    
    func tryToLogin() {
        generateRandomString()
        transformRandomStringToCodeChallenge()
        generateCodeChallengeUrl()
        
        let url = URL(string: codeChallengeUrl)!
        webView.load(URLRequest(url: url))
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false
    }
    
    func generateRandomString() {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        let verifier = Data(buffer)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        UserDefaults.standard.set(verifier, forKey: MyUserDefaultKeys.codeVerifier)
        let defaults = UserDefaults(suiteName: "group.CY-8227ADCA-EA5E-11E8-8AF6-93415DA6B906.com.cydia.Extender")
        defaults?.setValue(verifier, forKey: "codeVerifier")
    }
    
    func transformRandomStringToCodeChallenge() {
        let codeVerifier = UserDefaults.standard.value(forKey: MyUserDefaultKeys.codeVerifier) as! String
        guard let data = codeVerifier.data(using: .utf8) else { return }
        var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
        }
        let hash = Data(buffer)
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        code_challenge = challenge
    }
    
    func generateCodeChallengeUrl() {
        codeChallengeUrl = "\(SERVICE_ADDRESSES_ENUM.GET_Code_CHALLENGE_URL.rawValue)?client_id=\(GetTokenRequestInput.client_id)&response_type=\(GetTokenRequestInput.response_type)&redirect_uri=\(GetTokenRequestInput.redirect_uri)&code_challenge=\(code_challenge)&code_challenge_method=\(GetTokenRequestInput.code_challenge_method)"
    }
    
}
