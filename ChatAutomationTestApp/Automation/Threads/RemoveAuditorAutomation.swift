//
//  RemoveAuditorAutomation.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON


class RemoveAuditorAutomation {
    
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
        
        sendRequestSenario(contactId: nil, inThreadId: threadId, withUserId: userId, removeAuditor: true)
    }
    
    func sendRequest(theThreadId: Int, theUserId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "send Request to removeAuditor with this params: \n threadId = \(theThreadId), \n userId = \(theUserId)", lineNumbers: 2)
        
        let removeAuditor = AddRemoveAuditorRequestModel(roles:     [Roles.ADD_RULE_TO_USER],
                                                         threadId:  theThreadId,
                                                         userId:    theUserId,
                                                         typeCode:  nil,
                                                         uniqueId:  requestUniqueId)
        
        Chat.sharedInstance.setAuditor(inputModel: removeAuditor, uniqueId: { (removeAuditorUniqueId) in
            self.uniqueIdCallback?(removeAuditorUniqueId)
        }, completion: { (removeAuditorResponseModel) in
            self.serverResponseCallback?(removeAuditorResponseModel as! UserRolesModel)
        })
        
    }
    
    
    func sendRequestSenario(contactId: Int?, inThreadId: Int?, withUserId: Int?, removeAuditor: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactId, inThreadId, withUserId, removeAuditor) {
            case (.none ,.none, .none, _):
                self.addContact()
                
            case let (.some(cId), .none, .none, _):
                self.createThread(withContact: cId)
            
            case let (_, .some(tId), .none, _):
                self.createContactToGetUserId(threadId: tId)
            
            case let (_ , .some(tId), .some(uId), false):
                self.addAuditor(theThreadId: tId, theUserId: uId)
                
            case let (_ , .some(tId), .some(uId), true):
                self.sendRequest(theThreadId: tId, theUserId: uId)
                
            default: break
            }
        }
        
    }
    
    
    func addContact() {
        // 1
        let sara = Faker.sharedInstance.SaraAsContacts
        let addContact = AddContactAutomation(cellphoneNumber: sara.cellphoneNumber, email: sara.email, firstName: sara.firstName, lastName: sara.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contact id = \(id).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: id, inThreadId: nil, withUserId: nil, removeAuditor: false)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "there is no id when addContact with this user (firstName = \(sara.firstName) , cellphoneNumber = \(sara.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(sara.firstName) , cellphoneNumber = \(sara.cellphoneNumber) , lastName = \(sara.lastName)", lineNumbers: 2)
            }
        }
    }
    
    func createThread(withContact: Int) {
        delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "Try to create thread with contactId = \(withContact)", lineNumbers: 1)
        
        let invitee = Invitee(id: "\(withContact)", idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)
        let createThreadRequest = CreateThreadRequestModel(description: nil,
                                                           image:       nil,
                                                           invitees:    [invitee],
                                                           metadata:    nil,
                                                           uniqueName:  nil,
                                                           title:       "title",
                                                           type:        ThreadTypes.NORMAL,
                                                           typeCode:    nil,
                                                           uniqueId:    nil)
        Chat.sharedInstance.createThread(inputModel: createThreadRequest, uniqueId: { _ in }, completion: { (createThreadModel) in
            let myThreadModel = createThreadModel as! ThreadModel
            if let theThreadId = myThreadModel.thread?.id {
                self.sendRequestSenario(contactId: nil, inThreadId: theThreadId, withUserId: nil, removeAuditor: false)
            } else {
                // handle error that didn't get thread id in the Conversation model
                self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "there is no id when createThread with this user (contactId = \(withContact))!", lineNumbers: 2)
            }
        })
        
    }
    
    
    func createContactToGetUserId(threadId: Int) {
        let mehran = Faker.sharedInstance.MehranAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehran.cellphoneNumber, email: mehran.email, firstName: mehran.firstName, lastName: mehran.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.userId {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "Another Contact has been created to add it to the thread as Audotor.", lineNumbers: 2)
                    self.sendRequestSenario(contactId: nil, inThreadId: threadId, withUserId: id, removeAuditor: false)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "there is no userId on the response of addContact with this params: (firstName = \(mehran.firstName) , cellphoneNumber = \(mehran.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehran.firstName) , cellphoneNumber = \(mehran.cellphoneNumber) , lastName = \(mehran.lastName)", lineNumbers: 2)
            }
        }
    }
    
    
    func addAuditor(theThreadId: Int, theUserId: Int) {
            
        delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "try to addAuditor with this params: threadId = \(theThreadId), userId = \(theUserId)", lineNumbers: 2)
        
        let userRole = SetRemoveRoleModel(userId: theUserId, roles: [Roles.ADD_RULE_TO_USER])
        let addAdminInput = RoleRequestModel(userRoles: [userRole], threadId: theThreadId, typeCode: nil, uniqueId: nil)
        
        Chat.sharedInstance.setRole(inputModel: addAdminInput, uniqueId: { _ in }, completion: { (addAdminServerResponseModel) in
            self.delegate?.newInfo(type: MoreInfoTypes.RemoveAuditor.rawValue, message: "This is addAuditor response from server:\n\(addAdminServerResponseModel)", lineNumbers: 3)
            self.sendRequestSenario(contactId: nil, inThreadId: theThreadId, withUserId: theUserId, removeAuditor: true)
        })
        
    }
    
    
}
