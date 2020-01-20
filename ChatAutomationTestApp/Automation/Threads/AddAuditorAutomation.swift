//
//  AddAuditorAutomation.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
import SwiftyJSON


class AddAuditorAutomation {

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
        
        sendRequestSenario(contactId: nil, inThreadId: threadId, withUserId: userId)
    }
    
    func sendRequest(theThreadId: Int, theUserId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "send Request to addAuditor with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
        let addAuditor = AddRemoveAuditorRequestModel(roles:    [Roles.ADD_RULE_TO_USER],
                                                      threadId: theThreadId,
                                                      userId:   theUserId,
                                                      typeCode: nil,
                                                      uniqueId: requestUniqueId)
        
        Chat.sharedInstance.setAuditor(inputModel: addAuditor, uniqueId: { (setAuditorUniqueId) in
            self.uniqueIdCallback?(setAuditorUniqueId)
        }, completion: { (addAuditorResponseModel) in
            self.serverResponseCallback?(addAuditorResponseModel as! UserRolesModel)
        })
        
    }
    
    func sendRequestSenario(contactId: Int?, inThreadId: Int?, withUserId: Int?) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactId, inThreadId, withUserId) {
            case (.none ,.none, .none):
                self.addContact()
                
            case let (.some(cId), .none, .none):
                self.createThread(withContact: cId)
            
            case let (_, .some(tId), .none):
                self.createContactToGetUserId(threadId: tId)
            
            case let (_ , .some(tId), .some(uId)):
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
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contact id = \(id).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: id, inThreadId: nil, withUserId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "there is no id when addContact with this user (firstName = \(sara.firstName) , cellphoneNumber = \(sara.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(sara.firstName) , cellphoneNumber = \(sara.cellphoneNumber) , lastName = \(sara.lastName)", lineNumbers: 2)
            }
        }
    }
    
    func createThread(withContact: Int) {
        delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "Try to create thread with contactId = \(withContact)", lineNumbers: 1)
        
        let invitee = Invitee(id: "\(withContact)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CONTACT_ID)
        let createThreadRequest = CreateThreadRequestModel(description: nil,
                                                           image:       nil,
                                                           invitees:    [invitee],
                                                           metadata:    nil,
                                                           title:       "title",
                                                           type:        ThreadTypes.NORMAL,
                                                           typeCode:    nil,
                                                           uniqueId:    nil)
        Chat.sharedInstance.createThread(inputModel: createThreadRequest, uniqueId: { _ in }, completion: { (createThreadModel) in
            let myThreadModel = createThreadModel as! ThreadModel
            if let theThreadId = myThreadModel.thread?.id {
                self.sendRequestSenario(contactId: nil, inThreadId: theThreadId, withUserId: nil)
            } else {
                // handle error that didn't get thread id in the Conversation model
                self.delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "there is no id when createThread with this user (contactId = \(withContact))!", lineNumbers: 2)
            }
        })
        
    }
    
    
    func createContactToGetUserId(threadId: Int) {
        let mehran = Faker.sharedInstance.MehranAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehran.cellphoneNumber, email: mehran.email, firstName: mehran.firstName, lastName: mehran.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "Another Contact has been created to add it to the thread as Audotor.", lineNumbers: 2)
                    self.sendRequestSenario(contactId: nil, inThreadId: threadId, withUserId: id)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "there is no userId on the response of addContact with this params: (firstName = \(mehran.firstName) , cellphoneNumber = \(mehran.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.AddAuditor.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehran.firstName) , cellphoneNumber = \(mehran.cellphoneNumber) , lastName = \(mehran.lastName)", lineNumbers: 2)
            }
        }
    }
    
    
}
