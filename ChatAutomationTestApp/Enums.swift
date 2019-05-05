//
//  Enums.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/15/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


struct MyUserDefaultKeys {
    static let codeVerifier     = "codeVerifier"        // String
    static let token            = "token"               // String
    static let refreshToken     = "refreshToken"        // String
    static let expireTokenTime  = "expireTokenTime"     // Int
    static let tokenIssuer      = "tokenIssuer"         // String of Int!!
    static let expires_in       = "expires_in"          // String
}


enum MoreInfoTypes: String {
    case AddContact         = "AddContact"
    case Block              = "Block"
    case GetBlockedList     = "GetBlockedList"
    case GetContact         = "GetContact"
    case RemoveContact      = "RemoveContact"
    case Unblock            = "Unblock"
    case UpdateContact      = "UpdateContact"
    
    case AddParticipant     = "AddParticipant"
    case CreateThread       = "CreateThread"
    case GetHistory         = "GetHistory"
    case GetThread          = "GetThread"
    case GetThreadParticipants  = "GetThreadParticipants"
    
    case DeleteMessage      = "DeleteMessage"
    case EditMessage        = "EditMessage"
    case ForwardMessage     = "ForwardMessage"
    case ReplyTextMessage   = "ReplyTextMessage"
    case SendTextMessage    = "SendTextMessage"
    
}


public enum SERVICE_ADDRESSES_ENUM: String {
    case GET_Code_CHALLENGE_URL = "http://172.16.110.76/oauth2/authorize"
    case GET_TOKEN_URL          = "http://172.16.110.76/oauth2/token"
}

struct GetTokenRequestInput {
    static let client_id:              String  = "2051121e4348af52664cf7de0bda"
    static let response_type:          String  = "code"
    static let redirect_uri:           String  = "http://localhost:8773/v1/auth/podsso_redirect"
    static let code_challenge_method:  String  = "S256"
    
    static let grant_type:             String  = "authorization_code"
}

struct GetRefreshTokenInput {
    static let grant_type:      String = "refresh_token"
    static let client_id:       String = "2051121e4348af52664cf7de0bda"
    static let redirect_uri:    String = "http://localhost:8773/v1/auth/podsso_redirect"
}




extension Date {
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    var secondsSince1970: Int {
        return Int((self.timeIntervalSince1970).rounded())
    }
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    init(seconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
}


