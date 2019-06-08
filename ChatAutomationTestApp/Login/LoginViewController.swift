//
//  LoginViewController.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/15/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import UIKit
import WebKit
import CommonCrypto
import Alamofire
import SwiftyJSON

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
        let verifier = Data(bytes: buffer)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        UserDefaults.standard.set(verifier, forKey: MyUserDefaultKeys.codeVerifier)
    }
    
    func transformRandomStringToCodeChallenge() {
        let codeVerifier = UserDefaults.standard.value(forKey: MyUserDefaultKeys.codeVerifier) as! String
        guard let data = codeVerifier.data(using: .utf8) else { return }
        var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
        }
        let hash = Data(bytes: buffer)
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





extension LoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    //    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    //        print("didReceiveServerRedirectForProvisionalNavigation url = \(webView.url?.absoluteString ?? "it's nil")\n")
    //    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        let redirectedUrlString = webView.url?.absoluteString
        let myArray = redirectedUrlString?.components(separatedBy: "code=")
        if let array = myArray {
            for (index, item) in array.enumerated() {
                print("item \(index) = \(item)")
            }
            if array.count > 1 {
                code = array.last!
                getToken()
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation erro = \(error)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail error = \(error)")
    }
    
}



extension LoginViewController {
    
    func getToken() {
        guard let code_verifier = UserDefaults.standard.value(forKey: MyUserDefaultKeys.codeVerifier) else { return }
        
        let url = URL(string: SERVICE_ADDRESSES_ENUM.GET_TOKEN_URL.rawValue)!
        let method: HTTPMethod = HTTPMethod.post
        let params: Parameters = ["grant_type": GetTokenRequestInput.grant_type,
                                  "client_id": GetTokenRequestInput.client_id,
                                  "redirect_uri": GetTokenRequestInput.redirect_uri,
                                  "code": code,
                                  "code_verifier": code_verifier]
        Alamofire.request(url, method: method, parameters: params, headers: nil).responseJSON { (myResponse) in
            
            if myResponse.result.isSuccess {
                if let jsonValue = myResponse.result.value {
                    let jsonResponse: JSON = JSON(jsonValue)
                    if let token = jsonResponse["access_token"].string {
                        UserDefaults.standard.setValue(token, forKey: MyUserDefaultKeys.token)
                    }
                    if let expires_in = jsonResponse["expires_in"].int {
                        let expiresTime = Date().secondsSince1970 + 7100
                        UserDefaults.standard.setValue(expires_in, forKey: MyUserDefaultKeys.expires_in)
                        UserDefaults.standard.setValue(expiresTime, forKey: MyUserDefaultKeys.expireTokenTime)
                    }
                    if let id_token = jsonResponse["id_token"].string {
                        print("id_token = \(id_token)")
                    }
                    if let refresh_token = jsonResponse["refresh_token"].string {
                        UserDefaults.standard.setValue(refresh_token, forKey: MyUserDefaultKeys.refreshToken)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.present(MyChatViewController(), animated: true, completion: nil)
            }
            
        }
    }
    
}
