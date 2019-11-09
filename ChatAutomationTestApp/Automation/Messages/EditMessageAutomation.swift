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
    
    
    let content:            String?
    let metaData:           JSON?
    let repliedTo:          Int?
    let messageId:          Int?
    let typeCode:           String?
    let requestUniqueId:    String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (EditMessageModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(content: String?, metaData: JSON?, repliedTo: Int?, messageId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.content            = content
        self.metaData           = metaData
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
            let requestModel = EditTextMessageRequestModel(content:         myContent,
                                                           metaData:        metaData,
                                                           repliedTo:       repliedTo,
                                                           subjectId:       msgId,
                                                           requestTypeCode: typeCode,
                                                           requestUniqueId: requestUniqueId)
            sendRequest(editMessageRequest: requestModel)
            
        case let (.none , .some(smgId)):
            let requestModel = EditTextMessageRequestModel(content: "This is Edited Message Text",
                                                           metaData:        metaData,
                                                           repliedTo:       repliedTo,
                                                           subjectId:       smgId,
                                                           requestTypeCode: typeCode,
                                                           requestUniqueId: requestUniqueId)
            sendRequest(editMessageRequest: requestModel)
            
        default:
            sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: nil)
        }
        
    }
    
    
    func sendRequest(editMessageRequest: EditTextMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "send Request to EditMessage with this params:\n content = \(editMessageRequest.content) , metaData = \(editMessageRequest.metaData ?? JSON.null) , repliedTo = \(editMessageRequest.repliedTo ?? 0) , subjectId = \(editMessageRequest.subjectId) , typeCode = \(editMessageRequest.requestTypeCode ?? "nil") , uniqueId = \(editMessageRequest.requestUniqueId ?? "nil")", lineNumbers: 2)
        Chat.sharedInstance.editMessage(editMessageInput: editMessageRequest, uniqueId: { (editMessageUniqueId) in
//        myChatObject?.editMessage(editMessageInput: editMessageRequest, uniqueId: { (editMessageUniqueId) in
            self.uniqueIdCallback?(editMessageUniqueId)
        }, completion: { (editMessageResponse) in
            self.responseCallback?(editMessageResponse as! EditMessageModel)
        })
        
    }
    
    
//    func sendMessageThenEditIt() {
//        // 1- add contact
//        // 2- create thread with this contact
//        // 3- sendMessage to this thread
//        // 4- edit this message
//
//        delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, edit this message", lineNumbers: 2)
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
//                    self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
//
//                    let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
//                    let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
//                    createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
//                        if let id = createThreadModel.thread?.id {
//
//                            // 3
//                            self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
//
//                            let sendMessage = SendTextMessageAutomation(content: "New Message", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
//                            sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
//
//                                // 4
//                                if let messageId = Int(sentResponse["content"].stringValue) {
//                                    self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
//
//                                    let requestModel = EditTextMessageRequestModel(content: self.content ?? "This is Edited Text Message", metaData: self.metaData, repliedTo: self.repliedTo, subjectId: messageId, typeCode: self.typeCode, uniqueId: self.requestUniqueId)
//                                    self.sendRequest(editMessageRequest: requestModel)
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
//                    self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(firstName) , cellphoneNumber = \(cellphoneNumber))!", lineNumbers: 2)
//                }
//            } else {
//                // handle error that didn't add Contact Model
//                self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(firstName) , cellphoneNumber = \(cellphoneNumber) , lastName = \(lastName)", lineNumbers: 2)
//            }
//        }
//
//    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, messageResponse: JSON?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- edit this message
        
        switch (contactCellPhone, threadId, messageResponse) {
        case    (.none, .none, .none):
            addContact()
            
        case let (.some(cellPhone), .none, .none):
            createThread(cellPhoneNumber: cellPhone)
            
        case let (_ , .some(thread), .none):
            sendMessage(toThread: thread)
            
        case let (_ , _ , .some(msg)):
            if let _ = msg["subjectId"].int {
                if let messageId = Int(msg["content"].stringValue) {
                    self.createEditMessageModel(withMessageId: messageId)
                }
            }
        }
        
    }
    
    
    // 1
    func addContact() {
        delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, edit this message", lineNumbers: 2)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, messageResponse: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    
    // 2
    func createThread(cellPhoneNumber: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(cellPhoneNumber)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: ThreadTypes.PUBLIC_GROUP, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
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
            
//            if let messageId = Int(sentResponse["content"].stringValue) {
            if let messageId = sentResponse.message?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.EditMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createEditMessageModel(withMessageId messageId: Int) {
        let requestModel = EditTextMessageRequestModel(content:         self.content ?? "This is Edited Text Message",
                                                       metaData:        self.metaData,
                                                       repliedTo:       self.repliedTo,
                                                       subjectId:       messageId,
                                                       requestTypeCode: self.typeCode,
                                                       requestUniqueId: self.requestUniqueId)
        self.sendRequest(editMessageRequest: requestModel)
    }
    
}
