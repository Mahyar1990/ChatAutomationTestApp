//
//  Networking.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 9/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


class Networking: NSObject {
    
//    var token                   = "955b899521a045cd88c67a5f6bd04766"
    
    public static let sharedInstance = Networking()
        
        var url         = "https://sandbox.pod.ir:8043/srv/basic-platform"    // platformHost
        var method:     HTTPMethod  = .get
        var headers     = HTTPHeaders()
        var parameters: [String: Any]  = [:]
        
        
        func sendRequest(response: @escaping (JSON?, Error?) -> ()) {
            Alamofire.request(url, method: method, parameters: parameters, /*encoding: URLEncoding(destination: .queryString),*/ headers: headers).responseJSON { (myResponse) in
                if myResponse.result.isSuccess {
                    
                    if let jsonValue = myResponse.result.value {
                        let jsonResponse: JSON = JSON(jsonValue)
                        response(jsonResponse, nil)
                    } else {
                        response(nil, myResponse.result.error)
                    }
                    
                } else {
                    response(nil, myResponse.error)
                }
            }
        }
        
        
        func generateStateResponse(json: JSON) -> (ServerResponseState) {
            let serverResponseModel = ServerResponseModelAsArray(json: json)
            let serverResponseState = ServerResponseState(count:            serverResponseModel.count,
                                                          errorCode:        serverResponseModel.errorCode,
                                                          hasError:         serverResponseModel.hasError,
                                                          message:          serverResponseModel.message,
                                                          ott:              serverResponseModel.ott,
                                                          referenceNumber:  serverResponseModel.referenceNumber)
            return (serverResponseState)
        }
        
        
        func checkTokenValidationTime() {
            let codeVerifier = UserDefaults.standard.value(forKey: MyUserDefaultKeys.codeVerifier) as! String
            let defaults = UserDefaults(suiteName: "group.CY-8227ADCA-EA5E-11E8-8AF6-93415DA6B906.com.cydia.Extender")
            defaults?.setValue(codeVerifier, forKey: "codeVerifier")
            
            if let tokenExTime = UserDefaults.standard.value(forKey: MyUserDefaultKeys.expireTokenTime) as? Int {
                if (Date().secondsSince1970 > tokenExTime) {
                    // call referesh token!
    //                DispatchQueue.main.sync {
                        refereshToken()
    //                }
                }
            }
        }
        
        
        func refereshToken() {
            let refreshToken = UserDefaults.standard.value(forKey: MyUserDefaultKeys.refreshToken) as! String
            let codeVerifier = UserDefaults.standard.value(forKey: MyUserDefaultKeys.codeVerifier) as! String
    //        DispatchQueue.main.sync {
                getTokenWithRefreshToken(refreshToken: refreshToken, codeVerifier: codeVerifier, serverResponse: { (result) in
                    if (result == false) {
                        self.logOutUser()
                    }
                })
    //        }
        }
        
        func logOutUser() {
            resetUserDefaults()
            
            // call appDelegate to start creating the app classes
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            let _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        }
    
    
    
    
    public func  getTokenWithRefreshToken(refreshToken:      String,
                                          codeVerifier:      String,
                                          serverResponse:    @escaping (Bool) -> ()) {
            
            headers.removeAll()
            parameters.removeAll()
            url     = SERVICE_ADDRESSES_ENUM.GET_TOKEN_URL.rawValue
            method  = .post
            parameters = ["grant_type":     GetRefreshTokenInput.grant_type,
                          "client_id":      GetRefreshTokenInput.client_id,
                          "redirect_uri":   GetRefreshTokenInput.redirect_uri,
                          "refresh_token":  refreshToken,
                          "code_verifier":  codeVerifier]
            
            Alamofire.request(url, method: method, parameters: parameters, headers: nil).responseJSON { (myResponse) in
                if myResponse.result.isSuccess {
                    if let jsonValue = myResponse.result.value {
                        
                        let defaults = UserDefaults(suiteName: "group.CY-8227ADCA-EA5E-11E8-8AF6-93415DA6B906.com.cydia.Extender")
                        
                        let jsonResponse: JSON = JSON(jsonValue)
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
    //                    if let id_token = jsonResponse["id_token"].string {
    //                        print("id_token = \(id_token)")
    //                    }
                        if let refresh_token = jsonResponse["refresh_token"].string {
                            UserDefaults.standard.setValue(refresh_token, forKey: MyUserDefaultKeys.refreshToken)
                            defaults?.setValue(refresh_token, forKey: "refreshToken")
                        }
                        
                        serverResponse(true)
                    }
                }
            }
            
        }
    
    
}









class ServerResponseModelAsObject {
    
    let count:          Int
    let errorCode:      Int
    let hasError:       Bool
    let message:        String
    let ott:            String
    let referenceNumber: Int
    let result:         JSON
    
    init(count: Int, errorCode: Int, hasError: Bool, message: String, ott: String, referenceNumber: Int, result: JSON) {
        self.count          = count
        self.errorCode      = errorCode
        self.hasError       = hasError
        self.ott            = ott
        self.message        = message
        self.referenceNumber = referenceNumber
        self.result         = result
    }
    
    init(json: JSON) {
        self.count          = json["count"].intValue
        self.errorCode      = json["errorCode"].intValue
        self.hasError       = json["hasError"].boolValue
        self.message        = json["message"].stringValue
        self.ott            = json["ott"].stringValue
        self.referenceNumber = json["referenceNumber"].intValue
        self.result         = json["result"]
    }
    
}



class ServerResponseModelAsArray {
    
    let count:          Int
    let errorCode:      Int
    let hasError:       Bool
    let message:        String
    let ott:            String
    let referenceNumber: Int
    let result:         [JSON]
    
    init(count: Int, errorCode: Int, hasError: Bool, message: String, ott: String, referenceNumber: Int, result: [JSON]) {
        self.count          = count
        self.errorCode      = errorCode
        self.hasError       = hasError
        self.message        = message
        self.ott            = ott
        self.referenceNumber = referenceNumber
        self.result         = result
    }
    
    init(json: JSON) {
        self.count          = json["count"].intValue
        self.errorCode      = json["errorCode"].intValue
        self.hasError       = json["hasError"].boolValue
        self.message        = json["message"].stringValue
        self.ott            = json["ott"].stringValue
        self.referenceNumber = json["referenceNumber"].intValue
        self.result         = json["result"].arrayValue
    }
    
}



struct ServerResponseState {
    let count:          Int
    let errorCode:      Int
    let hasError:       Bool
    let message:        String
    let ott:            String
    let referenceNumber: Int
}





