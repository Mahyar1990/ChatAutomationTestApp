//
//  AddAdminAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 3/11/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 GetAdminAutomation request will send
 */

class AddAdminAutomation {
    
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
        
        sendRequestSenario(inThreadId: threadId, withUserId: userId)
    }
    
    func sendRequest(theThreadId: Int, theUserId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "send Request to addAdminRoles with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
//        let addAdminInput = RoleRequestModel(roles: [Roles.ADD_RULE_TO_USER], threadId: theThreadId, userId: theUserId, typeCode: nil, uniqueId: requestUniqueId)
        
        let userRole = SetRemoveRoleModel(userId: theUserId, roles: [Roles.ADD_RULE_TO_USER])
        let addAdminInput = RoleRequestModel(userRoles: [userRole], threadId: theThreadId, typeCode: nil, uniqueId: requestUniqueId)
        
        Chat.sharedInstance.setRole(inputModel: addAdminInput, uniqueId: { (addAdminUniqueId) in
            self.uniqueIdCallback?(addAdminUniqueId)
        }, completion: { (addAdminServerResponseModel) in
            self.serverResponseCallback?(addAdminServerResponseModel as! UserRolesModel)
        })
        
    }
    
    func sendRequestSenario(inThreadId: Int?, withUserId: Int?) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (inThreadId, withUserId) {
            case let (.some(tId), .some(uId)):
                self.sendRequest(theThreadId: tId, theUserId: uId)
            default:
                self.createThreadAndAddParticipant()
            }
        }
        
    }
    
    func createThreadAndAddParticipant() {
        delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Try to create thread then add an participant to the thread", lineNumbers: 2)
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
                                            self.sendRequestSenario(inThreadId: myThreadId, withUserId: participantId)
                                            found = true
                                        case let (.some(isTrue), .some(participantId)):
                                            if !isTrue {
                                                self.sendRequestSenario(inThreadId: myThreadId, withUserId: participantId)
                                                found = true
                                            }
                                        default: return
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Error: AddParticipant response does not have Participants inside the thread Model!!!!", lineNumbers: 2)
                    }
                } else {
                    self.delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Error: AddParticipant response does not have threadId inside the thread Model!!!!", lineNumbers: 2)
                }
            } else {
                self.delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Error: AddParticipant response does not have thread model in it!!!!", lineNumbers: 2)
            }
        }
    }
    
    
}
