//
//  GetTokenWithRefreshToken.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/15/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


/*
 GetTokenWithRefreshToken:
 send request to get new token
 
 */

class GetTokenWithRefreshToken {
    
    let url = SERVICE_ADDRESSES_ENUM.GET_TOKEN_URL.rawValue
    let method: HTTPMethod  = .post
    var params: Parameters  = [:]
    
    init(refreshToken: String, codeVerifier: String) {
        self.params = ["grant_type":    GetRefreshTokenInput.grant_type,
                       "client_id":     GetRefreshTokenInput.client_id,
                       "redirect_uri":  GetRefreshTokenInput.redirect_uri,
                       "refresh_token": refreshToken,
                       "code_verifier": codeVerifier]
    }
    
    func request(serverResponse: @escaping (Bool) -> ()) {
        
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
                    
                    serverResponse(true)
                }
            }
        }
        
    }
    
}
