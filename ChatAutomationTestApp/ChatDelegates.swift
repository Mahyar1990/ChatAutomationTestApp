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

// MARK: Chat delegatews
extension MyViewController: ChatDelegates {
    
    func chatConnected() {
        
    }
    
    func chatDisconnect() {
        chatIsReady = false
    }
    
    func chatReconnect() {
        
    }
    
    func chatThreadEvents() {
        //        print("@@MyLog(Chat): thread events")
    }
    
    func chatReady() {
        chatIsReady = true
    }
    
    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?) {
        //        print("@@MyLog(Chat): error: errCode = \(errorCode), errMsg = \(errorMessage)")
    }
    
    func chatState(state: Int) {
        //        print("@@MyLog(Chat): chat state = \(state)")
    }
    
    func chatDeliver(messageId: Int, ownerId: Int) {
        //        print("@@MyLog(Chat): deliver with messageId = \(messageId), and ownerId = \(ownerId)")
    }
    
    func messageEvents(type: String, result: JSON) {
        //        print("@@MyLog(Chat): message events with \n type = \(type) \n result: \(result)")
        
        //        print("\n\n\n****************************")
        //        print("****************************")
        //        print("****************************")
        //        print("MessageType: \(type)")
        //        print("result in JSON: \n \(result)")
        //        print("****************************")
        //        print("****************************")
        //        print("****************************\n\n\n")
    }
    
    func threadEvents(type: String, result: JSON) {
        //        print("@@MyLog:(Chat): ThreadEvents: \n type = \(type) , \n result: \(result) \n")
        
        if type == "THREAD_UNREAD_COUNT_UPDATED" {
            print("\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("THREAD_UNREAD_COUNT_UPDATED : ")
            print("\(result)")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")
        }
        
        if (type == "THREAD_LAST_ACTIVITY_TIME") {
            print("\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("THREAD_LAST_ACTIVITY_TIME : ")
            print("\(result)")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")
        }
        
    }
    
    
}
