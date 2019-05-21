//
//  ForwardMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import PodChat
//import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a ForwardMessage request will send
 */

class ForwardMessageAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let messageIds:         [Int]?
    let metaData:           JSON?
    let repliedTo:          Int?
    let subjectId:          Int?
    let typeCode:           String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverSentResponse:     callbackServerResponseTypeAlias?
    private var serverDeliverResponse:  callbackServerResponseTypeAlias?
    private var serverSeenResponse:     callbackServerResponseTypeAlias?
    
    init(messageIds: [Int]?, metaData: JSON?, repliedTo: Int?, subjectId: Int?, typeCode: String?, uniqueId: String?) {
        
        self.messageIds         = messageIds
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.subjectId          = subjectId
        self.typeCode           = typeCode
    }
    
    func create(uniqueId:               @escaping (String) -> (),
                serverSentResponse:     @escaping (JSON) -> (),
                serverDeliverResponse:  @escaping (JSON) -> (),
                serverSeenResponse:     @escaping (JSON) -> ()) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverSentResponse     = serverSentResponse
        self.serverDeliverResponse  = serverDeliverResponse
        self.serverSeenResponse     = serverSeenResponse
        
        
        switch (messageIds, subjectId) {
        case let (.some(msgIds), .some(subId)):
            
            let inputModel = ForwardMessageRequestModel(messageIds: msgIds, metaData: metaData, repliedTo: repliedTo, subjectId: subId, typeCode: typeCode)
            sendRequest(forwardMessageRequest: inputModel)
            
        default:
            sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: nil)
        }
        
    }
    
    
    func sendRequest(forwardMessageRequest: ForwardMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "send Request to ForwardMessage with this params:\n messageIds = \(forwardMessageRequest.messageIds) , metaData = \(forwardMessageRequest.metaData ?? JSON.null) , repliedTo = \(forwardMessageRequest.repliedTo ?? 0) , subjectId = \(forwardMessageRequest.subjectId) , typeCode = \(forwardMessageRequest.typeCode ?? "nil")", lineNumbers: 2)
        
        myChatObject?.forwardMessage(forwardMessageInput: forwardMessageRequest, uniqueIds: { (forwardMessageUniqueId) in
            self.uniqueIdCallback?(forwardMessageUniqueId)
        }, onSent: { (sent) in
            self.serverSentResponse?(sent as! JSON)
        }, onDelivere: { (deliver) in
            self.serverDeliverResponse?(deliver as! JSON)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! JSON)
        })
        
    }
    
    
//    func sendMessageThenForwardIt() {
//        // 1- add contact
//        // 2- create thread with this contact
//        // 3- sendMessage to this thread
//        // 4- forward this message to this thread
//
//        delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, forward this message to this thread", lineNumbers: 2)
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
//                    self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
//
//                    let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
//                    let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
//                    createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
//                        if let id = createThreadModel.thread?.id {
//
//                            // 3
//                            self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
//
//                            let sendMessage = SendTextMessageAutomation(content: "New Message", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
//                            sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
//
//                                // 4
//                                if let messageId = Int(sentResponse["content"].stringValue) {
//                                    self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
//
//                                    let requestModel = ForwardMessageRequestModel(messageIds: [messageId], metaData: self.metaData, repliedTo: self.repliedTo, subjectId: id, typeCode: self.typeCode)
//                                    self.sendRequest(forwardMessageRequest: requestModel)
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
//                    self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(firstName) , cellphoneNumber = \(cellphoneNumber))!", lineNumbers: 2)
//                }
//            } else {
//                // handle error that didn't add Contact Model
//                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(firstName) , cellphoneNumber = \(cellphoneNumber) , lastName = \(lastName)", lineNumbers: 2)
//            }
//        }
//
//    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, messageResponse: JSON?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- forward this message to this thread
        
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
                    self.createForwardMessageModel(inThreadId: thId, onMessageId: messageId)
                }
            }
        }
        
    }
    
    
    // 1
    func addContact() {
        delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, forward this message to this thread", lineNumbers: 2)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(mehdi.cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, messageResponse: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
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
                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
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
                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: sentResponse)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createForwardMessageModel(inThreadId threadId: Int, onMessageId messageId: Int) {
        let requestModel = ForwardMessageRequestModel(messageIds: [messageId], metaData: self.metaData, repliedTo: self.repliedTo, subjectId: threadId, typeCode: self.typeCode)
        self.sendRequest(forwardMessageRequest: requestModel)
    }
    
}
