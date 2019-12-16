//
//  GetTokenWithRefreshToken.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/15/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


extension LoginViewController {
    
    func getToken() {
        guard let code_verifier = UserDefaults.standard.value(forKey: MyUserDefaultKeys.codeVerifier) as? String else { return }
        
        let url = URL(string: SERVICE_ADDRESSES_ENUM.GET_TOKEN_URL.rawValue)!
        let method: HTTPMethod = HTTPMethod.post
        let params: Parameters = ["grant_type":     GetTokenRequestInput.grant_type,
                                  "client_id":      GetTokenRequestInput.client_id,
                                  "redirect_uri":   GetTokenRequestInput.redirect_uri,
                                  "code":           code,
                                  "code_verifier":  code_verifier]
        Alamofire.request(url, method: method, parameters: params, headers: nil).responseJSON { (myResponse) in
            
            if myResponse.result.isSuccess {
                if let jsonValue = myResponse.result.value {
                    
                    let defaults = UserDefaults(suiteName: "group.CY-8227ADCA-EA5E-11E8-8AF6-93415DA6B906.com.cydia.Extender")
                    
                    defaults?.setValue(code_verifier, forKey: "codeVerifier")
                    
                    let jsonResponse: JSON = JSON(jsonValue)
                    
                    if (jsonResponse["hasError"].boolValue == true) {
                        self.logOut()
                    } else {
                        if let token = jsonResponse["access_token"].string {
                            UserDefaults.standard.setValue(token, forKey: MyUserDefaultKeys.token)
                            defaults?.setValue(token, forKey: "token")
                        }
                        if let expires_in = jsonResponse["expires_in"].int {
                            let expiresTime = Date().secondsSince1970 + 7100
                            UserDefaults.standard.setValue(expires_in, forKey: MyUserDefaultKeys.expires_in)
                            UserDefaults.standard.setValue(expiresTime, forKey: MyUserDefaultKeys.expireTokenTime)
                            defaults?.setValue(expiresTime, forKey: "tokenExTime")
                        }
                        if let refresh_token = jsonResponse["refresh_token"].string {
                            UserDefaults.standard.setValue(refresh_token, forKey: MyUserDefaultKeys.refreshToken)
                            defaults?.setValue(refresh_token, forKey: "refreshToken")
                        }
                    }
                    
                }
            }
            
            DispatchQueue.main.async {
                
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.window?.rootViewController = MyChatViewController()
            }
            
        }
    }
    
    
    
    
    func logOut() {
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.codeVerifier)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.expires_in)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.expireTokenTime)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.refreshToken)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.token)
        
        // call appDelegate to start creating the app classes
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        let _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
    }
    
    
    
}

