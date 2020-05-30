//
//  EditMessageAutomation.swift
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
 a EditMessage request will send
 */

class EditMessageAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let content:    String?
    let metadata:   String?
    let repliedTo:  Int?
    let messageId:  Int?
    let typeCode:   String?
    let requestUniqueId:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (EditMessageModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(content: String?, metadata: String?, repliedTo: Int?, messageId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.content            = content
        self.metadata           = metadata
        self.repliedTo          = repliedTo
        self.messageId          = messageId
        self.typeCode           = typeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (EditMessageModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        switch (content, messageId) {
        case let (.some(myContent) , .some(msgId)):
            let requestModel = EditTextMessageRequestModel(content:     myContent,
                                                           messageType: MessageType.text,
                                                           metadata:    metadata,
                                                           repliedTo:   repliedTo,
                                                           messageId:   msgId,
                                                           typeCode:    typeCode,
                                                           uniqueId:    requestUniqueId)
            sendRequest(editMessageRequest: requestModel)
            
        case let (.none , .some(smgId)):
            let requestModel = EditTextMessageRequestModel(content:     "This is Edited Message Text",
                                                           messageType: MessageType.text,
                                                           metadata:    metadata,
                                                           repliedTo:   repliedTo,
                                                           messageId:   smgId,
                                                           typeCode:    typeCode,
                                                           uniqueId:    requestUniqueId)
            sendRequest(editMessageRequest: requestModel)
            
        default:
            sendRequestSenario(contactId: nil, threadId: nil, messageId: nil)
        }
        
    }
    
    
    func sendRequest(editMessageRequest: EditTextMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "send Request to EditMessage with this params:\n content = \(editMessageRequest.textMessage) , repliedTo = \(editMessageRequest.repliedTo ?? 0) , subjectId = \(editMessageRequest.messageId) , typeCode = \(editMessageRequest.typeCode ?? "nil") , uniqueId = \(editMessageRequest.uniqueId ?? "nil")", lineNumbers: 2)
        Chat.sharedInstance.editMessage(inputModel: editMessageRequest, uniqueId: { (editMessageUniqueId) in
//        myChatObject?.editMessage(editMessageInput: editMessageRequest, uniqueId: { (editMessageUniqueId) in
            self.uniqueIdCallback?(editMessageUniqueId)
        }, completion: { (editMessageResponse) in
            self.responseCallback?(editMessageResponse as! EditMessageModel)
        })
        
    }
    
    func sendRequestSenario(contactId: String?, threadId: Int?, messageId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- edit this message
        
        switch (contactId, threadId, messageId) {
        case    (.none,     .none,          .none):         addContact()
        case let (.some(id), .none,         .none):         createThread(contactId: id)
        case let (_ ,       .some(thread),  .none):         sendMessage(toThread: thread)
        case let (_ ,       _ ,             .some(mId)):    createEditMessageModel(withMessageId: mId)
        }
        
    }
    
    
    // 1
    func addContact() {
        delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, edit this message", lineNumbers: 2)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this ContactId = \(contactId).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: "\(contactId)", threadId: nil, messageId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "there is no ContactId when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
        
    }
    
    
    // 2
    func createThread(contactId: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(contactId)", idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, uniqueName: nil, type: ThreadTypes.NORMAL, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id, messageId: nil)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    
    // 3
    func sendMessage(toThread id: Int) {
        delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "try to sendMessage to threadId \(id)", lineNumbers: 1)
        let sendMessage = SendTextMessageAutomation(content: "New Message", metadata: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
            
            self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(sentResponse.messageId)", lineNumbers: 1)
            self.sendRequestSenario(contactId: nil, threadId: id, messageId: sentResponse.messageId)
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createEditMessageModel(withMessageId messageId: Int) {
        let requestModel = EditTextMessageRequestModel(content:     self.content ?? "This is Edited Text Message",
                                                       messageType: MessageType.text,
                                                       metadata:    self.metadata,
                                                       repliedTo:   self.repliedTo,
                                                       messageId:   messageId,
                                                       typeCode:    self.typeCode,
                                                       uniqueId:    self.requestUniqueId)
        self.sendRequest(editMessageRequest: requestModel)
    }
    
}
