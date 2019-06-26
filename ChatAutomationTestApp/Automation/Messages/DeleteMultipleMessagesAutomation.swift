//
//  DeleteMultipleMessagesAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 4/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a DeleteMessage request will send
 */

class DeleteMultipleMessagesAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let deleteForAll:       JSON?
    let subjectIds:         [Int]?
    let typeCode:           String?
    let requestUniqueIds:   [String]?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(deleteForAll: JSON?, subjectIds: [Int]?, typeCode: String?, requestUniqueIds: [String]?) {
        
        self.deleteForAll       = deleteForAll
        self.subjectIds         = subjectIds
        self.typeCode           = typeCode
        self.requestUniqueIds   = requestUniqueIds
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (JSON) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let subId = subjectIds {
            let requestModel = DeleteMultipleMessagesRequestModel(deleteForAll: deleteForAll, subjectIds: subId, typeCode: typeCode, uniqueIds: requestUniqueIds)
            sendRequest(deleteMessageRequest: requestModel)
        } else {
            sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: nil)
        }
        
    }
    
    
    func sendRequest(deleteMessageRequest: DeleteMultipleMessagesRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "send Request to DeleteMessage with this params:\n deleteForAll = \(deleteMessageRequest.deleteForAll ?? JSON.null) , subjectId = \(deleteMessageRequest.subjectIds) , typeCode = \(deleteMessageRequest.typeCode ?? "nil") , uniqueId = \(deleteMessageRequest.uniqueIds ?? ["nil"])", lineNumbers: 2)
        
        let input = DeleteMultipleMessagesRequestModel(deleteForAll: deleteMessageRequest.deleteForAll, subjectIds: deleteMessageRequest.subjectIds, typeCode: deleteMessageRequest.typeCode, uniqueIds: deleteMessageRequest.uniqueIds)
        myChatObject?.deleteMultipleMessages(deleteMessageInput: input, uniqueId: { (deleteMultipleMessagesUniqueId) in
            self.uniqueIdCallback?(deleteMultipleMessagesUniqueId)
        }, completion: { (deleteMultipleMessageResponse) in
            self.responseCallback?(deleteMultipleMessageResponse as! JSON)
        })
        
    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, messageResponse: [Int]?) {
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
            sendMessages(toThread: thread)
            
        case let (_ , .some(tId), .some(msgs)):
            self.createDeleteMessageModel(inThreadId: tId, onMessageIds: msgs)
            
        default:
            print("Wrong situation...")
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
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, messageResponse: nil)
                    
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
    
    // 3-1
    func sendMessages(toThread id: Int) {
        sendMessage(toThread: id) { (id1) in
            self.sendMessage(toThread: id, messageIdResponse: { (id2) in
                self.sendRequestSenario(contactCellPhone: nil, threadId: id, messageResponse: [id1, id2])
            })
        }
    }
    
    
    // 3-2
    func sendMessage(toThread id: Int, messageIdResponse: @escaping (Int)->()) {
        let sendMessage = SendTextMessageAutomation(content: "New Message", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: id, typeCode: nil, uniqueId: nil)
        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (sentResponse) in
            
            if let messageId = Int(sentResponse["content"].stringValue) {
                self.delegate?.newInfo(type: MoreInfoTypes.DeleteMessage.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                messageIdResponse(messageId)
//                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: sentResponse)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
    
    // 4
    func createDeleteMessageModel(inThreadId threadId: Int, onMessageIds messageIds: [Int]) {
        let requestModel = DeleteMultipleMessagesRequestModel(deleteForAll: self.deleteForAll, subjectIds: messageIds, typeCode: self.typeCode, uniqueIds: self.requestUniqueIds)
        self.sendRequest(deleteMessageRequest: requestModel)
    }
    
}
