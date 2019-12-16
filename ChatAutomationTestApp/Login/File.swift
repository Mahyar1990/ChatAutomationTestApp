//
//  File.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 9/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


extension NSObject {


    func resetUserDefaults() {
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.codeVerifier)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.expires_in)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.expireTokenTime)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.refreshToken)
        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.token)
    }



}
