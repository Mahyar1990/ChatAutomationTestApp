//
//  UnpinMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a EditMessage request will send
 */

class UnpinMessageAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let messageId:  Int?
    let typeCode:   String?
    let requestUniqueId:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (PinUnpinMessageModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(messageId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.messageId          = messageId
        self.typeCode           = typeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (PinUnpinMessageModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        switch (messageId) {
        case let (.some(msgId)):
            let unpinModel = PinAndUnpinMessageRequestModel(messageId:  msgId,
                                                            notifyAll:  true,
                                                            typeCode:   typeCode,
                                                            uniqueId:   requestUniqueId)
            sendRequest(unpinMessageRequest: unpinModel)
            
        default:
            tryToPinMessage()
//            sendRequestSenario(contactId: nil, threadId: nil, messageId: nil)
        }
        
    }
    
    
    func sendRequest(unpinMessageRequest: PinAndUnpinMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "send Request to PinMessage with this params:\n messageId = \(unpinMessageRequest.messageId) , notifyAll = \(unpinMessageRequest.notifyAll) , typeCode = \(unpinMessageRequest.typeCode ?? "nil") , uniqueId = \(unpinMessageRequest.uniqueId)", lineNumbers: 2)
        
        Chat.sharedInstance.unpinMessage(inputModel: unpinMessageRequest, uniqueId: { (unpinMessageUniqueId) in
            self.uniqueIdCallback?(unpinMessageUniqueId)
        }) { (unpinMessageResponse) in
            self.responseCallback?(unpinMessageResponse as! PinUnpinMessageModel)
        }
        
    }
    
    
    func tryToPinMessage() {
        let pinMessage = PinMessageAutomation(messageId: nil, typeCode: nil, requestUniqueId: nil)
        pinMessage.create(uniqueId: { _ in }) { (pinMessageResponse) in
            let unpinModel = PinAndUnpinMessageRequestModel(messageId:  pinMessageResponse.pinUnpinModel.messageId,
                                                            notifyAll:  true,
                                                            typeCode:   self.typeCode,
                                                            uniqueId:   self.requestUniqueId)
            self.delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "a new message has been Pinned. messageId = \(unpinModel.messageId)", lineNumbers: 2)
            self.sendRequest(unpinMessageRequest: unpinModel)
        }
    }
    
    
//    func sendRequestSenario(contactId: String?, threadId: Int?, messageId: Int?) {
//        // 1- add contact
//        // 2- create thread with this contact
//        // 3- sendMessage to this thread
//        // 4- pin this message
//
//        switch (contactId, threadId, messageId) {
//        case    (.none,     .none,          .none):         addContact()
//        case let (.some(id), .none,         .none):         createThread(contactId: id)
//        case let (_ ,       .some(thread),  .none):         sendMessage(toThread: thread)
//        case let (_ ,       _ ,             .some(mId)):    createPinMessageModel(withMessageId: mId)
//        }
//
//    }
//
//
//    // 1
//    func addContact() {
//        delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, pin this message", lineNumbers: 2)
//
//        let mehdi = Faker.sharedInstance.mehdiAsContact
//        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
//        addContact.create(uniqueId: { _ in }) { (contactModel) in
//            if let myContact = contactModel.contacts.first {
//                if let contactId = myContact.id {
//
//                    self.delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this ContactId = \(contactId).", lineNumbers: 2)
//                    self.sendRequestSenario(contactId: "\(contactId)", threadId: nil, messageId: nil)
//
//                } else {
//                    // handle error that didn't get contact id in the contact model
//                    self.delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "there is no ContactId when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
//                }
//            } else {
//                // handle error that didn't add Contact Model
//                self.delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
//            }
//        }
//
//    }
//
//
//    // 2
//    func createThread(contactId: String) {
//        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
//        let myInvitee = Invitee(id: "\(contactId)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CONTACT_ID)
//        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: ThreadTypes.PUBLIC_GROUP, requestUniqueId: nil)
//        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
//            if let id = createThreadModel.thread?.id {
//
//                self.delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
//                self.sendRequestSenario(contactId: nil, threadId: id, messageId: nil)
//
//            } else {
//                // handle error, there is no id in the Conversation model
//            }
//        })
//    }
//
//
//    // 3
//    func sendMessage(toThread id: Int) {
//        delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "try to sendMessage to threadId \(id)", lineNumbers: 1)
//        let sendMessage = SendTextMessageAutomation(content: "New Message", metadata: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
//        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
//
//            self.delegate?.newInfo(type: MoreInfoTypes.UnpinMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(sentResponse.messageId)", lineNumbers: 1)
//            self.sendRequestSenario(contactId: nil, threadId: id, messageId: sentResponse.messageId)
//
//        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
//    }
//
//
//    // 4
//    func createPinMessageModel(withMessageId messageId: Int) {
//        let pinModel = PinAndUnpinMessageRequestModel(messageId:    messageId,
//                                                      notifyAll:    true,
//                                                      typeCode:     self.typeCode,
//                                                      uniqueId:     self.requestUniqueId)
//        self.sendRequest(unpinMessageRequest: pinModel)
//    }
    
}

