//
//  GetAdminAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 3/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 GetAdminAutomation request will send
 */

class GetAdminAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let threadId:       Int?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    typealias callbackCacheResponseTypeAlias    = (JSON) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverResponseCallback: callbackServerResponseTypeAlias?
    private var cacheResponseCallback:  callbackCacheResponseTypeAlias?
    
    init(threadId: Int?, requestUniqueId: String?) {
        
        self.threadId       = threadId
        self.requestUniqueId = requestUniqueId
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias,
                cacheResponse:  @escaping callbackCacheResponseTypeAlias) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverResponseCallback = serverResponse
        self.cacheResponseCallback  = cacheResponse
        
        if let id = threadId {
            sendRequest(theThreadId: id)
        } else {
            addParticipant()
//            sendRequestSenario(contactCellPhone: nil, threadId: nil)
        }
    }
    
    func sendRequest(theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.GetAdmins.rawValue, message: "send Request to getAdmins with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
        let getAdminInput = GetAdminListRequestModel(threadId: theThreadId, uniqueId: requestUniqueId)
        myChatObject?.getAdminList(getAdminListInput: getAdminInput, uniqueId: { (getAdminUniqueId) in
            self.uniqueIdCallback?(getAdminUniqueId)
        }, completion: { (getAdminServerResponseModel) in
            self.serverResponseCallback?(getAdminServerResponseModel as! JSON)
        }, cacheResponse: { (getAdminCacheResponseModel) in
            self.cacheResponseCallback?(getAdminCacheResponseModel as! JSON)
        })
        
    }
    
    
//    func sendRequestSenario(contactCellPhone: String?, threadId: Int?) {
//        // 1- add contact
//        // 2- create thread with this contact
//        // 3- leaveThread
//
//        switch (contactCellPhone, threadId) {
//        case    (.none, .none):
//            addContact()
//
//        case let (.some(cellPhone), .none):
//            createThread(withCellphoneNumber: cellPhone)
//
//        case let (_ , .some(id)):
//            self.sendRequest(theThreadId: id)
//
//        }
//    }
    
    
    func addParticipant() {
        delegate?.newInfo(type: MoreInfoTypes.GetAdmins.rawValue, message: "Try to create thread then add an participant to the thread", lineNumbers: 2)
        let addParticipant = AddParticipantAutomation(contacts: nil, threadId: nil, typeCode: nil, uniqueId: nil)
        addParticipant.create(uniqueId: { _ in }) { (addParticipantResponseModel) in
            if let threadModel = addParticipantResponseModel.thread {
                if let myThreadId = threadModel.id {
                    if let participants = threadModel.participants {
                        if participants.count > 0 {
                            self.sendRequest(theThreadId: myThreadId)
                        }
                    } else {
                        self.delegate?.newInfo(type: MoreInfoTypes.GetAdmins.rawValue, message: "Error: AddParticipant response does not have Participants inside the thread Model!!!!", lineNumbers: 2)
                    }
                } else {
                    self.delegate?.newInfo(type: MoreInfoTypes.GetAdmins.rawValue, message: "Error: AddParticipant response does not have threadId inside the thread Model!!!!", lineNumbers: 2)
                }
            } else {
                self.delegate?.newInfo(type: MoreInfoTypes.GetAdmins.rawValue, message: "Error: AddParticipant response does not have thread model in it!!!!", lineNumbers: 2)
            }
        }
    }
    
    
}
