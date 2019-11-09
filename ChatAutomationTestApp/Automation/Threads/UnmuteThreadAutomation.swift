//
//  UnmuteThreadAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 UnmuteThreadAutomation request will send
 */

class UnmuteThreadAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let threadId:       Int?
    let typeCode:       String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (MuteUnmuteThreadModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(threadId: Int?, typeCode: String?) {
        
        self.threadId       = threadId
        self.typeCode       = typeCode
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        sendRequestSenario()
    }
    
    func sendRequest(theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.UnmuteThread.rawValue, message: "send Request to UnmuteThread with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
        let muteThreadInput = MuteAndUnmuteThreadRequestModel(subjectId:        theThreadId,
                                                              requestTypeCode:  typeCode,
                                                              requestUniqueId:  nil)
        
        Chat.sharedInstance.muteThread(muteThreadInput: muteThreadInput, uniqueId: { (muteThreadUniqueId) in
//        myChatObject?.muteThread(muteThreadInput: muteThreadInput, uniqueId: { (muteThreadUniqueId) in
            self.uniqueIdCallback?(muteThreadUniqueId)
        }, completion: { (muteThreadServerResponseModel) in
            self.responseCallback?(muteThreadServerResponseModel as! MuteUnmuteThreadModel)
        })
        
    }
    
    func sendRequestSenario() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            if let id = self.threadId {
                self.sendRequest(theThreadId: id)
            } else {
                self.muteThread()
            }
        }
    }
    
    func muteThread() {
        let muteThread = MuteThreadAutomation(threadId: nil, typeCode: nil)
        muteThread.create(uniqueId: { _ in }) { (muteThreadResponse) in
            
            self.delegate?.newInfo(type: MoreInfoTypes.UnmuteThread.rawValue, message: "This thread with id = \(muteThreadResponse.threadId) has been Muted", lineNumbers: 1)
            self.sendRequest(theThreadId: muteThreadResponse.threadId)
            
//            if let mutedThread = muteThreadResponse as? MuteUnmuteThreadModel {
//
//            } else {
//                self.delegate?.newInfo(type: MoreInfoTypes.UnmuteThread.rawValue, message: "Response of the Mute Thread does not contain threadId!! (result in the json response)", lineNumbers: 2)
//            }
        }
    }
    
}

