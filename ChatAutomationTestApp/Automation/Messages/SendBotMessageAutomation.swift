//
//  SendBotMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 9/12/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON


class SendBotMessageAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let content:        String?
    let messsageId:     Int?
    let metaData:       JSON
    let threadId:       Int?
    let systemMetadata: JSON?
    let typeCode:       String?
    let requestUniqueId:  String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (SendMessageModel) -> ()
    typealias callbackServerResponseTypeAlias1   = (JSON) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverSentResponse:     callbackServerResponseTypeAlias?
    private var serverDeliverResponse:  callbackServerResponseTypeAlias?
    private var serverSeenResponse:     callbackServerResponseTypeAlias?
    
    init(content: String?, messsageId: Int?, metaData: JSON, threadId: Int?, systemMetadata: JSON?, typeCode: String?, uniqueId: String?) {
        
        self.content        = content
        self.messsageId     = messsageId
        self.metaData       = metaData
        self.threadId       = threadId
        self.systemMetadata = systemMetadata
        self.typeCode       = typeCode
        self.requestUniqueId = uniqueId
    }
    
    
    func create(uniqueId:               @escaping (String) -> (),
                serverSentResponse:     @escaping (SendMessageModel) -> (),
                serverDeliverResponse:  @escaping (SendMessageModel) -> (),
                serverSeenResponse:     @escaping (SendMessageModel) -> ()) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverSentResponse     = serverSentResponse
        self.serverDeliverResponse  = serverDeliverResponse
        self.serverSeenResponse     = serverSeenResponse
        
        
        switch (messsageId, threadId, content) {
        case let (.some(repTo), .some(_), .some(myContent)):
            let inputModel = SendBotMessageRequestModel(content:        myContent,
                                                        messageId:      repTo,
                                                        metaData:       metaData,
                                                        systemMetadata: nil,
                                                        typeCode:       nil,
                                                        uniqueId:       requestUniqueId)
            
            sendRequest(botMessageRequest: inputModel)
            
        case let (.some(repTo), .some(_), .none):
            let inputModel = SendBotMessageRequestModel(content:        "This is BotMessage",
                                                        messageId:      repTo,
                                                        metaData:       metaData,
                                                        systemMetadata: nil,
                                                        typeCode:       nil,
                                                        uniqueId:       requestUniqueId)
            sendRequest(botMessageRequest: inputModel)
            
        default:
            sendRequestSenario(contactId: nil, threadId: nil, responseThreadId: nil, responseMessageId: nil)
        }
        
    }
    
    
    func sendRequest(botMessageRequest: SendBotMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.SentBotMessage.rawValue, message: "send Request to SentBotMessage with this params:\n content = \(botMessageRequest.content) , metaData = \(botMessageRequest.metaData) , messageId = \(botMessageRequest.messageId) , typeCode = \(botMessageRequest.typeCode ?? "nil") , uniqueId = \(botMessageRequest.uniqueId ?? "nil")", lineNumbers: 2)
        
        Chat.sharedInstance.sendBotMessage(sendBotMessageInput: botMessageRequest, uniqueId: { (replyMessageUniqueId) in
            self.uniqueIdCallback?(replyMessageUniqueId)
        }, onSent: { (sent) in
            self.serverSentResponse?(sent as! SendMessageModel)
        }, onDelivered: { (deliver) in
            self.serverDeliverResponse?(deliver as! SendMessageModel)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! SendMessageModel)
        })
        
    }
    
    
    func sendRequestSenario(contactId: String?, threadId: Int?, responseThreadId: Int?, responseMessageId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- reply this message to this thread
        
        switch (contactId, threadId, responseThreadId, responseMessageId) {
        case    (.none, .none, .none, .none):       addContact()
        case let (.some(id), .none, .none, .none):  createThread(withContactId: id)
        case let (_ , .some(thread), .none, .none): sendMessage(toThread: thread)
        case let (_ , _ , .some(tId), .some(mId)):  self.createSentBotMessageModel(inThreadId: tId, onMessageId: mId)
        case (_, _, .some(_), .none):               print("")
        case (_, _, .none, .some(_)):               print("")
        }
        
    }
    
    // 1
    func addContact() {
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.SentBotMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this ContactId = \(contactId).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: "\(contactId)", threadId: nil, responseThreadId: nil, responseMessageId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.SentBotMessage.rawValue, message: "there is no ContactId when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.SentBotMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    
    // 2
    func createThread(withContactId contactId: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(contactId)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: nil, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.SentBotMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id, responseThreadId: nil, responseMessageId: nil)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    
    // 3
    func sendMessage(toThread id: Int) {
        let sendMessage = SendTextMessageAutomation(content: "New Message", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
            
            self.delegate?.newInfo(type: MoreInfoTypes.SentBotMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(sentResponse.messageId)", lineNumbers: 1)
            self.sendRequestSenario(contactId: nil, threadId: nil, responseThreadId: sentResponse.threadId, responseMessageId: sentResponse.messageId)
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createSentBotMessageModel(inThreadId threadId: Int, onMessageId messageId: Int) {
        let requestModel = SendBotMessageRequestModel(content:          "This is BotMessage",
                                                      messageId:        messageId,
                                                      metaData:         self.metaData,
                                                      systemMetadata:   self.systemMetadata,
                                                      typeCode:         self.typeCode,
                                                      uniqueId:         self.requestUniqueId)
        self.sendRequest(botMessageRequest: requestModel)
    }
    
    
}
