//
//  DeleteMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a DeleteMessage request will send
 */

class DeleteMessageAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let deleteForAll:       JSON?
    let subjectId:          Int?
    let typeCode:           String?
    let requestUniqueId:    String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(deleteForAll: JSON?, subjectId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.deleteForAll       = deleteForAll
        self.subjectId          = subjectId
        self.typeCode           = typeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (JSON) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let subId = subjectId {
            let requestModel = DeleteMessageRequestModel(deleteForAll: deleteForAll, subjectId: subId, typeCode: typeCode, uniqueId: requestUniqueId)
            sendRequest(deleteMessageRequest: requestModel)
        } else {
            sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: nil)
        }
        
    }
    
    
    func sendRequest(deleteMessageRequest: DeleteMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "send Request to DeleteMessage with this params:\n deleteForAll = \(deleteMessageRequest.deleteForAll ?? JSON.null) , subjectId = \(deleteMessageRequest.subjectId ?? 0) , typeCode = \(deleteMessageRequest.typeCode ?? "nil") , uniqueId = \(deleteMessageRequest.uniqueId ?? "nil")", lineNumbers: 2)
        
        myChatObject?.deleteMessage(deleteMessageInput: deleteMessageRequest, uniqueId: { (deleteMessageUniqueId) in
            self.uniqueIdCallback?(deleteMessageUniqueId)
        }, completion: { (deleteMessageResponse) in
            self.responseCallback?(deleteMessageResponse as! JSON)
        })
        
    }
    
    
//    func sendMessageThenDeleteIt() {
//        // 1- add contact
//        // 2- create thread with this contact
//        // 3- sendMessage to this thread
//        // 4- delete this message
//
//        delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, delete this message", lineNumbers: 2)
//
//        // 1
//        let cellphoneNumber = "09387181694"
//        let firstName       = "Pooria"
//        let lastName        = "Pahlevani"
//
//        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: nil, firstName: firstName, lastName: lastName)
//        addContact.create(uniqueId: { _ in }) { (contactModel) in
//            if let myContact = contactModel.contacts.first {
//                if let cellphoneNumber = myContact.cellphoneNumber {
//
//                    // 2
//                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
//
//                    self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
//
//                    let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
//                    let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
//                    createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
//                        if let id = createThreadModel.thread?.id {
//
//                            // 3
//                            self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
//
//                            let sendMessage = SendTextMessageAutomation(content: "New Message", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
//                            sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
//
//                                // 4
//                                if let messageId = Int(sentResponse["content"].stringValue) {
//                                    self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
//
//                                    let requestModel = DeleteMessageRequestModel(deleteForAll: self.deleteForAll, subjectId: messageId, typeCode: self.typeCode, uniqueId: self.requestUniqueId)
//                                    self.sendRequest(deleteMessageRequest: requestModel)
//
//                                }
//
//
//                            }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
//
//                        } else {
//                            // handle error, there is no id in the Conversation model
//                        }
//                    })
//
//                } else {
//                    // handle error that didn't get contact id in the contact model
//                    self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(firstName) , cellphoneNumber = \(cellphoneNumber))!", lineNumbers: 2)
//                }
//            } else {
//                // handle error that didn't add Contact Model
//                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(firstName) , cellphoneNumber = \(cellphoneNumber) , lastName = \(lastName)", lineNumbers: 2)
//            }
//        }
//
//    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, messageResponse: JSON?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- delete this message
        
        
        switch (contactCellPhone, threadId, messageResponse) {
        case    (.none, .none, .none):
            addContact()
            
        case let (.some(cellPhone), .none, .none):
            createThread(withCellphoneNumber: cellPhone)
            
        case let (_ , .some(thread), .none):
            sendMessage(toThread: thread)
            
        case let (_ , _ , .some(msg)):
            if let thId = msg["subjectId"].int {
                if let messageId = Int(msg["content"].stringValue) {
                    self.createDeleteMessageModel(inThreadId: thId, onMessageId: messageId)
                }
            }
        }
        
    }
    
    
    // 1
    func addContact() {
        delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, delete this message", lineNumbers: 2)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: pouria.email, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, messageResponse: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber) , lastName = \(pouria.lastName)", lineNumbers: 2)
            }
        }

    }
    
    
    // 2
    func createThread(withCellphoneNumber cellphoneNumber: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: id, messageResponse: nil)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    
    // 3
    func sendMessage(toThread id: Int) {
        let sendMessage = SendTextMessageAutomation(content: "New Message", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
            
            if let messageId = Int(sentResponse["content"].stringValue) {
                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: sentResponse)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createDeleteMessageModel(inThreadId threadId: Int, onMessageId messageId: Int) {
        let requestModel = DeleteMessageRequestModel(deleteForAll: self.deleteForAll, subjectId: messageId, typeCode: self.typeCode, uniqueId: self.requestUniqueId)
        self.sendRequest(deleteMessageRequest: requestModel)
    }
    
}
