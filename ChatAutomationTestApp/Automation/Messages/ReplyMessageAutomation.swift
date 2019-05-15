//
//  ReplyMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a ReplyMessage request will send
 */

class ReplyMessageAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let content:            String?
    let metaData:           JSON?
    let repliedTo:          Int?
    let subjectId:          Int?
    let typeCode:           String?
    let requestUniqueId:    String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverSentResponse:     callbackServerResponseTypeAlias?
    private var serverDeliverResponse:  callbackServerResponseTypeAlias?
    private var serverSeenResponse:     callbackServerResponseTypeAlias?
    
    init(content: String?, metaData: JSON?, repliedTo: Int?, subjectId: Int?, typeCode: String?, uniqueId: String?) {
        
        self.content            = content
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.subjectId          = subjectId
        self.typeCode           = typeCode
        self.requestUniqueId    = uniqueId
    }
    
    func create(uniqueId:               @escaping (String) -> (),
                serverSentResponse:     @escaping (JSON) -> (),
                serverDeliverResponse:  @escaping (JSON) -> (),
                serverSeenResponse:     @escaping (JSON) -> ()) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverSentResponse     = serverSentResponse
        self.serverDeliverResponse  = serverDeliverResponse
        self.serverSeenResponse     = serverSeenResponse
        
        
        switch (repliedTo, subjectId, content) {
        case let (.some(repTo), .some(subTo), .some(myContent)):
            let inputModel = ReplyTextMessageRequestModel(content: myContent, metaData: metaData, repliedTo: repTo, subjectId: subTo, typeCode: typeCode, uniqueId: requestUniqueId)
            sendRequest(replyTextMessageRequest: inputModel)
            
        case let (.some(repTo), .some(subTo), .none):
            let inputModel = ReplyTextMessageRequestModel(content: "This is ReplyMessage", metaData: metaData, repliedTo: repTo, subjectId: subTo, typeCode: typeCode, uniqueId: requestUniqueId)
            sendRequest(replyTextMessageRequest: inputModel)
            
        default:
            sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: nil)
        }
        
    }
    
    
    func sendRequest(replyTextMessageRequest: ReplyTextMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "send Request to ReplyTextMessage with this params:\n content = \(replyTextMessageRequest.content) , metaData = \(replyTextMessageRequest.metaData ?? JSON.null) , repliedTo = \(replyTextMessageRequest.repliedTo) , subjectId = \(replyTextMessageRequest.subjectId) , typeCode = \(replyTextMessageRequest.typeCode ?? "nil") , uniqueId = \(replyTextMessageRequest.uniqueId ?? "nil")", lineNumbers: 2)
        
        myChatObject?.replyMessage(replyMessageInput: replyTextMessageRequest, uniqueId: { (replyMessageUniqueId) in
            self.uniqueIdCallback?(replyMessageUniqueId)
        }, onSent: { (sent) in
            self.serverSentResponse?(sent as! JSON)
        }, onDelivere: { (deliver) in
            self.serverDeliverResponse?(deliver as! JSON)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! JSON)
        })
        
    }
    
    
//    func sendMessageThenReplyToIt() {
//
//        // 1- add contact
//        // 2- create thread with this contact
//        // 3- sendMessage to this thread
//        // 4- reply this message to this thread
//
//        delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, reply this message to this thread", lineNumbers: 2)
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
//                    self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
//
//                    let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
//                    let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
//                    createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
//                        if let id = createThreadModel.thread?.id {
//
//                            // 3
//                            self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
//
//                            let sendMessage = SendTextMessageAutomation(content: "New Message", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
//                            sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
//                                print("message response = \(sentResponse)")
//                                // 4
//                                if let messageId = Int(sentResponse["content"].stringValue) {
//                                    self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
//
//                                    let requestModel = ReplyTextMessageRequestModel(content: "This is ReplyMessage", metaData: self.metaData, repliedTo: messageId, subjectId: id, typeCode: self.typeCode, uniqueId: self.requestUniqueId)
//                                    self.sendRequest(replyTextMessageRequest: requestModel)
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
//                    self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(firstName) , cellphoneNumber = \(cellphoneNumber))!", lineNumbers: 2)
//                }
//            } else {
//                // handle error that didn't add Contact Model
//                self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(firstName) , cellphoneNumber = \(cellphoneNumber) , lastName = \(lastName)", lineNumbers: 2)
//            }
//        }
//
//    }
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, messageResponse: JSON?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- reply this message to this thread
        
        
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
                    self.createReplyTextMessageModel(inThreadId: thId, onMessageId: messageId)
                }
            }
        }
        
    }
    
    
    func addContact() {
        // 1
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, messageResponse: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
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
                
                self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
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
            print("message response = \(sentResponse)")
            
            if let messageId = Int(sentResponse["content"].stringValue) {
                self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: sentResponse)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createReplyTextMessageModel(inThreadId threadId: Int, onMessageId messageId: Int) {
        let requestModel = ReplyTextMessageRequestModel(content: "This is ReplyMessage", metaData: self.metaData, repliedTo: messageId, subjectId: threadId, typeCode: self.typeCode, uniqueId: self.requestUniqueId)
        self.sendRequest(replyTextMessageRequest: requestModel)
    }
    
}
