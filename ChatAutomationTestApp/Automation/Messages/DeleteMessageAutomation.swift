//
//  DeleteMessageAutomation.swift
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
 a DeleteMessage request will send
 */

class DeleteMessageAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let deleteForAll:       Bool?
    let subjectId:          Int?
    let typeCode:           String?
    let requestUniqueId:    String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (DeleteMessageModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(deleteForAll: Bool?, subjectId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.deleteForAll       = deleteForAll
        self.subjectId          = subjectId
        self.typeCode           = typeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (DeleteMessageModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let subId = subjectId {
            let requestModel = DeleteMessageRequestModel(deleteForAll: deleteForAll, subjectId: subId, typeCode: typeCode, uniqueId: requestUniqueId)
            sendRequest(deleteMessageRequest: requestModel)
        } else {
            sendRequestSenario(contactCellPhone: nil, threadId: nil, responseThreadId: nil, responseMessageId: nil)
        }
        
    }
    
    
    func sendRequest(deleteMessageRequest: DeleteMessageRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "send Request to DeleteMessage with this params:\n deleteForAll = \(deleteMessageRequest.deleteForAll ?? false) , subjectId = \(deleteMessageRequest.subjectId) , typeCode = \(deleteMessageRequest.typeCode ?? "nil") , uniqueId = \(deleteMessageRequest.uniqueId ?? "nil")", lineNumbers: 2)
        
        let deleteMessageRequest = DeleteMessageRequestModel(deleteForAll:  deleteMessageRequest.deleteForAll,
                                                             subjectId:     deleteMessageRequest.subjectId,
                                                             typeCode:      deleteMessageRequest.typeCode,
                                                             uniqueId:      deleteMessageRequest.uniqueId)
        Chat.sharedInstance.deleteMessage(deleteMessageInput: deleteMessageRequest, uniqueId: { (deleteMessageUniqueId) in
            self.uniqueIdCallback?(deleteMessageUniqueId)
        }, completion: { (deleteMessageResponse) in
            self.responseCallback?(deleteMessageResponse as! DeleteMessageModel)
        })
        
    }
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, responseThreadId: Int?, responseMessageId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- delete this message
        
        switch      (contactCellPhone   , threadId      , responseThreadId  , responseMessageId) {
        case        (.none              , .none         , .none             , .none):           addContact()
        case let    (.some(cellPhone)   , .none         , .none             , .none):           createThread(withCellphoneNumber: cellPhone)
        case let    (_                  , .some(thread) , .none             , .none):           sendMessage(toThread: thread)
        case let    (_                  , _             , .some(tId)        , .some(mId)):      self.createDeleteMessageModel(inThreadId: tId, onMessageId: mId)
        case        (_                  , _             , .some(_)          , .none):           print("")
        case        (_                  , _             , .none             , .some(_)):        print("")
        }
    }
    
    
    // 1
    func addContact() {
        delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it, at the end, delete this message", lineNumbers: 2)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, responseThreadId: nil, responseMessageId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }

    }
    
    
    // 2
    func createThread(withCellphoneNumber cellphoneNumber: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: ThreadTypes.PUBLIC_GROUP, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
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
            
//            if let messageId = Int(sentResponse["content"].stringValue) {
            if let messageId = sentResponse.message?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, responseThreadId: sentResponse.message?.conversation?.id, responseMessageId: sentResponse.message?.id)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createDeleteMessageModel(inThreadId threadId: Int, onMessageId messageId: Int) {
        let requestModel = DeleteMessageRequestModel(deleteForAll: self.deleteForAll, subjectId: messageId, typeCode: self.typeCode, uniqueId: self.requestUniqueId)
        self.sendRequest(deleteMessageRequest: requestModel)
    }
    
}
