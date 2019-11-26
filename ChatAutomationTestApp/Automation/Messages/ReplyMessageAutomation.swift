//
//  ReplyMessageAutomation.swift
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
    typealias callbackServerResponseTypeAlias   = (SendMessageModel) -> ()
    
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
                serverSentResponse:     @escaping (SendMessageModel) -> (),
                serverDeliverResponse:  @escaping (SendMessageModel) -> (),
                serverSeenResponse:     @escaping (SendMessageModel) -> ()) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverSentResponse     = serverSentResponse
        self.serverDeliverResponse  = serverDeliverResponse
        self.serverSeenResponse     = serverSeenResponse
        
        
        switch (repliedTo, subjectId, content) {
        case let (.some(repTo), .some(subTo), .some(myContent)):
            let inputModel = ReplyTextMessageRequestModel(content:          myContent,
                                                          metaData:         metaData,
                                                          repliedTo:        repTo,
                                                          subjectId:        subTo,
                                                          requestTypeCode:  typeCode,
                                                          requestUniqueId:  requestUniqueId)
            sendRequest(replyTextMessageRequest: inputModel)
            
        case let (.some(repTo), .some(subTo), .none):
            let inputModel = ReplyTextMessageRequestModel(content:          "This is ReplyMessage",
                                                          metaData:         metaData,
                                                          repliedTo:        repTo,
                                                          subjectId:        subTo,
                                                          requestTypeCode:  typeCode,
                                                          requestUniqueId:  requestUniqueId)
            sendRequest(replyTextMessageRequest: inputModel)
            
        default:
            sendRequestSenario(contactCellPhone: nil, threadId: nil, responseThreadId: nil, responseMessageId: nil)
        }
        
    }
    
    
    func sendRequest(replyTextMessageRequest: ReplyTextMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "send Request to ReplyTextMessage with this params:\n content = \(replyTextMessageRequest.content) , metaData = \(replyTextMessageRequest.metaData ?? JSON.null) , repliedTo = \(replyTextMessageRequest.repliedTo) , subjectId = \(replyTextMessageRequest.subjectId) , typeCode = \(replyTextMessageRequest.requestTypeCode ?? "nil") , uniqueId = \(replyTextMessageRequest.requestUniqueId ?? "nil")", lineNumbers: 2)
        
        Chat.sharedInstance.replyMessage(replyMessageInput: replyTextMessageRequest, uniqueId: { (replyMessageUniqueId) in
            self.uniqueIdCallback?(replyMessageUniqueId)
        }, onSent: { (sent) in
            self.serverSentResponse?(sent as! SendMessageModel)
        }, onDelivere: { (deliver) in
            self.serverDeliverResponse?(deliver as! SendMessageModel)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! SendMessageModel)
        })
        
    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, responseThreadId: Int?, responseMessageId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- reply this message to this thread
        
        switch (contactCellPhone, threadId, responseThreadId, responseMessageId) {
        case    (.none, .none, .none, .none):               addContact()
        case let (.some(cellPhone), .none, .none, .none):   createThread(withCellphoneNumber: cellPhone)
        case let (_ , .some(thread), .none, .none):         sendMessage(toThread: thread)
        case let (_ , _ , .some(tId), .some(mId)):          self.createReplyTextMessageModel(inThreadId: tId, onMessageId: mId)
        case (_, _, .some(_), .none):                       print("")
        case (_, _, .none, .some(_)):                       print("")
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
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, responseThreadId: nil, responseMessageId: nil)
                    
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
        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: nil, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: id, responseThreadId: nil, responseMessageId: nil)
                
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
            
            if let messageId = sentResponse.message?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.ReplyTextMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, responseThreadId: sentResponse.message?.conversation?.id, responseMessageId: sentResponse.message?.id)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createReplyTextMessageModel(inThreadId threadId: Int, onMessageId messageId: Int) {
        let requestModel = ReplyTextMessageRequestModel(content: "This is ReplyMessage", metaData: self.metaData, repliedTo: messageId, subjectId: threadId, requestTypeCode: self.typeCode, requestUniqueId: self.requestUniqueId)
        self.sendRequest(replyTextMessageRequest: requestModel)
    }
    
}
