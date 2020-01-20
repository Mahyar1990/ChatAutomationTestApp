//
//  RemoveAdminAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 3/12/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 GetAdminAutomation request will send
 */

class RemoveAdminAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let threadId:   Int?
    let userId:     Int?
    
    let requestUniqueId:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (UserRolesModel) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverResponseCallback: callbackServerResponseTypeAlias?
    
    init(threadId: Int?, userId: Int?, requestUniqueId: String?) {
        
        self.threadId           = threadId
        self.userId             = userId
        self.requestUniqueId    = requestUniqueId
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverResponseCallback = serverResponse
        
        sendRequestSenario(threadId: threadId, theUserId: userId, addedAsAdmin: false)
        
    }
    
    func sendRequest(theThreadId: Int, theUserId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.RemoveAdmin.rawValue, message: "send Request to removeAdminRole with this params: \n threadId = \(theThreadId), \n userId = \(theUserId)", lineNumbers: 2)
        
//        let removeAdminInput = RoleRequestModel(roles: [Roles.ADD_RULE_TO_USER], threadId: theThreadId, userId: theUserId, typeCode: nil, uniqueId: requestUniqueId)
        
        let userModel = SetRemoveRoleModel(userId: theUserId, roles: [Roles.ADD_RULE_TO_USER])
        let removeAdminInput = RoleRequestModel(userRoles: [userModel], threadId: theThreadId, typeCode: nil, uniqueId: requestUniqueId)
        
        Chat.sharedInstance.removeRole(inputModel: removeAdminInput, uniqueId: { (addAdminUniqueId) in
            self.uniqueIdCallback?(addAdminUniqueId)
        }, completion: { (addAdminServerResponseModel) in
            self.serverResponseCallback?(addAdminServerResponseModel as! UserRolesModel)
        })
        
    }
    
    
    func sendRequestSenario(threadId: Int?, theUserId: Int?, addedAsAdmin: Bool) {
        // 1- create thread and add participant to it
        // 2- set admin role to the participant
        // 3- send a message
        // 4- sendRequest
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (threadId, theUserId, addedAsAdmin) {
            case    (.none, .none, _):                  self.createThreadAndAddParticipant()
            case let (.some(tId), .some(uID), false):   self.addAdmin(theThreadId: tId, theUserId: uID)
            case let (.some(tId), .some(uID), true):    self.sendRequest(theThreadId: tId, theUserId: uID)
            default:                                    print("Wrong situation!!!")
            }
        }
        
    }
    
    
    func createThreadAndAddParticipant() {
        delegate?.newInfo(type: MoreInfoTypes.RemoveAdmin.rawValue, message: "Try to create thread then add an participant to the thread", lineNumbers: 2)
        let addParticipant = AddParticipantAutomation(contacts: nil, threadId: nil, typeCode: nil, requestUniqueId: nil)
        addParticipant.create(uniqueId: { _ in }) { (addParticipantResponseModel) in
            if let threadModel = addParticipantResponseModel.thread {
                if let myThreadId = threadModel.id {
                    if let participants = threadModel.participants {
                        if participants.count > 0 {
                            if let threadParticipants = threadModel.participants {
                                var found = false
                                for item in threadParticipants {
                                    if !found {
                                        switch (item.admin, item.id) {
                                        case let (.none, .some(participantId)):
                                            self.sendRequestSenario(threadId: myThreadId, theUserId: participantId, addedAsAdmin: false)
                                            found = true
                                        case let (.some(isTrue), .some(participantId)):
                                            if !isTrue {
                                                self.sendRequestSenario(threadId: myThreadId, theUserId: participantId, addedAsAdmin: false)
                                                found = true
                                            }
                                        default: return
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.delegate?.newInfo(type: MoreInfoTypes.RemoveAdmin.rawValue, message: "Error: AddParticipant response does not have Participants inside the thread Model!!!!", lineNumbers: 2)
                    }
                } else {
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveAdmin.rawValue, message: "Error: AddParticipant response does not have threadId inside the thread Model!!!!", lineNumbers: 2)
                }
            } else {
                self.delegate?.newInfo(type: MoreInfoTypes.RemoveAdmin.rawValue, message: "Error: AddParticipant response does not have thread model in it!!!!", lineNumbers: 2)
            }
        }
    }
    
    
    
    
    func addAdmin(theThreadId: Int, theUserId: Int) {
        
        delegate?.newInfo(type: MoreInfoTypes.RemoveAdmin.rawValue, message: "try to addAdmin with this params: threadId = \(theThreadId), userId = \(theUserId)", lineNumbers: 2)
        
        let userRole = SetRemoveRoleModel(userId: theUserId, roles: [Roles.ADD_RULE_TO_USER])
        let addAdminInput = RoleRequestModel(userRoles: [userRole], threadId: theThreadId, typeCode: nil, uniqueId: nil)
        
        Chat.sharedInstance.setRole(inputModel: addAdminInput, uniqueId: { _ in }, completion: { (addAdminServerResponseModel) in
            self.delegate?.newInfo(type: MoreInfoTypes.RemoveAdmin.rawValue, message: "This is addAdmin response from server:\n\(addAdminServerResponseModel)", lineNumbers: 3)
            self.sendRequestSenario(threadId: theThreadId, theUserId: theUserId, addedAsAdmin: true)
        })
        
    }
    
    
}
