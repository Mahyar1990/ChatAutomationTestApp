//
//  ChatDelegates.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import UIKit
import SwiftyJSON
import FanapPodChatSDK
//import PodChat


// MARK: Chat delegatews
extension MyChatViewController: ChatDelegates {
    
    func chatConnect() {
        let text = "Chat Connected"
        addtext(text: text)
        self.logHeightArr.append(30)
        self.logBackgroundColor.append(UIColor.green)
        print(text)
    }
    
    func chatDisconnect() {
        let text = "Chat Disconnected"
        addtext(text: text)
        self.logHeightArr.append(30)
        self.logBackgroundColor.append(UIColor.red)
        print(text)
    }
    
    func chatReconnect() {
        let text = "Chat Reconnected"
        addtext(text: text)
        self.logHeightArr.append(30)
        self.logBackgroundColor.append(UIColor.yellow)
        print(text)
    }
    
    func chatState(state: Int) {
        print("chat state changed: \(state)")
    }
    
    func chatReady(withUserInfo: User) {
        let text = "Chat Ready. \nUserInfo = \(withUserInfo.formatToJSON())"
        addtext(text: text)
        self.logHeightArr.append(150)
        self.logBackgroundColor.append(UIColor.green)
        print(text)
        activityIndicator.stopAnimating()
        
        Chat.sharedInstance.getUserInfo(uniqueId: { (uId) in
//        myChatObject?.getUserInfo(uniqueId: { (uId) in
            print("UserInfo uniqueId:\n\(uId)")
        }, completion: { (ServerResponse) in
            print("Server UserInfoModel:\n\((ServerResponse as! UserInfoModel).returnDataAsJSON())")
        }, cacheResponse: { (userFromCache) in
            print("Cache UserInfoModel:\n\(userFromCache.returnDataAsJSON())")
        })
    }
    
    func contactEvents(type: ContactEventTypes, result: Any) {
        //
    }
    
    func messageEvents(type: MessageEventTypes, result: Any) {
        //
    }
    
    func threadEvents(type: ThreadEventTypes, result: Any) {
        //
    }
    
    func fileUploadEvents(type: FileUploadEventTypes, result: Any) {
        //
    }
    
    func systemEvents(type: SystemEventTypes, result: Any) {
        //
    }
    
    func botEvents(type: BotEventTypes, result: Any) {
        //
    }
    
    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?) {
        //
        let text = "Chat Error. \nerrorCode = \(errorCode) \nerrorMessage = \(errorMessage)"
        addtext(text: text)
        self.logHeightArr.append(90)
        self.logBackgroundColor.append(UIColor.orange)
        print(text)
    }
    
    
    
}
