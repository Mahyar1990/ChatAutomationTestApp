//
//  ForwardMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a ForwardMessage request will send
 */

class ForwardMessageAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let messageIds:         [Int]?
    let metadata:           String?
    let repliedTo:          Int?
    let subjectId:          Int?
    let typeCode:           String?
    
    var recievedSendMessageResponse = false
    
    typealias callbackStringTypeAlias           = ([String]) -> ()
    typealias callbackServerResponseTypeAlias   = (SendMessageModel) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverSentResponse:     callbackServerResponseTypeAlias?
    private var serverDeliverResponse:  callbackServerResponseTypeAlias?
    private var serverSeenResponse:     callbackServerResponseTypeAlias?
    
    init(messageIds: [Int]?, metadata: String?, repliedTo: Int?, subjectId: Int?, typeCode: String?, uniqueId: String?) {
        
        self.messageIds         = messageIds
        self.metadata           = metadata
        self.repliedTo          = repliedTo
        self.subjectId          = subjectId
        self.typeCode           = typeCode
    }
    
    func create(uniqueId:               @escaping ([String]) -> (),
                serverSentResponse:     @escaping (SendMessageModel) -> (),
                serverDeliverResponse:  @escaping (SendMessageModel) -> (),
                serverSeenResponse:     @escaping (SendMessageModel) -> ()) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverSentResponse     = serverSentResponse
        self.serverDeliverResponse  = serverDeliverResponse
        self.serverSeenResponse     = serverSeenResponse
        
        
        switch (messageIds, subjectId) {
        case let (.some(msgIds), .some(subId)):
            
            let inputModel = ForwardMessageRequestModel(messageIds: msgIds,
                                                        metadata:   metadata,
                                                        repliedTo:  repliedTo,
                                                        threadId:   subId,
                                                        typeCode:   typeCode)
            sendRequest(forwardMessageRequest: inputModel)
            
        default:
            sendRequestSenario(contactId: nil, threadId: nil, responseThreadId: nil, responseMessageId: nil)
        }
        
    }
    
    
    func sendRequest(forwardMessageRequest: ForwardMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "send Request to ForwardMessage with this params:\n messageIds = \(forwardMessageRequest.messageIds) , subjectId = \(forwardMessageRequest.threadId) , typeCode = \(forwardMessageRequest.typeCode ?? "nil")", lineNumbers: 2)
        
        Chat.sharedInstance.forwardMessage(inputModel: forwardMessageRequest, uniqueIds: { (forwardMessageUniqueId) in
            self.uniqueIdCallback?(forwardMessageUniqueId)
        }, onSent: { (sent) in
            self.serverSentResponse?(sent as! SendMessageModel)
        }, onDelivere: { (deliver) in
            self.serverDeliverResponse?(deliver as! SendMessageModel)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! SendMessageModel)
        })
        
    }
    
    func sendRequestSenario(contactId: String?, threadId: Int?, responseThreadId: Int?, responseMessageId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- forward this message to this thread
        
        switch (contactId, threadId, responseThreadId, responseMessageId) {
        case    (.none, .none, .none, .none):               addContact()
        case let (.some(cellPhone), .none, .none, .none):   createThread(withContactId: cellPhone)
        case let (_ , .some(thread), .none, .none):         sendMessage(toThread: thread)
        case let (_ , _ , .some(tId), .some(mId)):          self.createForwardMessageModel(inThreadId: tId, onMessageId: mId)
        case (_, _, .some(_), .none):                       print("")
        case (_, _, .none, .some(_)):                       print("")
        }
        
    }
    
    
    // 1
    func addContact() {
        delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, forward this message to this thread", lineNumbers: 2)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this ContactId = \(mehdi.cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: "\(contactId)", threadId: nil, responseThreadId: nil, responseMessageId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "there is no ContactId when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    
    // 2
    func createThread(withContactId contactId: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        
        let myInvitee = Invitee(id: "\(contactId)", idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description:      fakeParams.description,
                                                  image:            nil,
                                                  invitees:         [myInvitee],
                                                  metadata:         nil,
                                                  title:            fakeParams.title,
                                                  uniqueName:       nil,
                                                  type:             nil,
                                                  requestUniqueId:  nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id, responseThreadId: nil, responseMessageId: nil)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    
    // 3
    func sendMessage(toThread id: Int) {
        let sendMessage = SendTextMessageAutomation(content: "New Message", metadata: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
            
//            if let messageId = sentResponse.message?.id {
//                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
//                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, responseThreadId: sentResponse.message?.conversation?.id, responseMessageId: sentResponse.message?.id)
//            }
            if !self.recievedSendMessageResponse {
                self.delegate?.newInfo(type: MoreInfoTypes.ForwardMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(sentResponse.messageId)", lineNumbers: 1)
                self.recievedSendMessageResponse = !self.recievedSendMessageResponse
                self.sendRequestSenario(contactId: nil, threadId: nil, responseThreadId: sentResponse.threadId, responseMessageId: sentResponse.messageId)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createForwardMessageModel(inThreadId threadId: Int, onMessageId messageId: Int) {
        let requestModel = ForwardMessageRequestModel(messageIds: [messageId], metadata: self.metadata, repliedTo: self.repliedTo, threadId: threadId, typeCode: self.typeCode)
        self.sendRequest(forwardMessageRequest: requestModel)
    }
    
}
