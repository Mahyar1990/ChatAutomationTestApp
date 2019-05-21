//
//  ClearHistoryAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import PodChat
//import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a clearHistory request will send
 */

class ClearHistoryAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let threadId:           Int?
    let requestUniqueId:    String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackCacheRespoonseTypeAlias   = (JSON) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var cacheCallback:      callbackServerResponseTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(threadId: Int?, requestUniqueId: String?) {
        
        self.threadId           = threadId
        self.requestUniqueId    = requestUniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (JSON) -> (),
                cacheResponse:  @escaping (JSON) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.cacheCallback      = cacheResponse
        self.responseCallback   = serverResponse
        
        if let id = threadId {
            sendRequest(theThreadId: id)
        } else {
            delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "not threadId has been specified to clead it's History, we we will create a thread then do the ClearHistory", lineNumbers: 2)
            sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: nil)
        }
        
    }
    
    
    func sendRequest(theThreadId: Int) {
        
        delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "send Request to clearHistory with this params:\n threadId = \(theThreadId) , uniqueId = \(requestUniqueId ?? "nil")", lineNumbers: 2)
        
        let clearHistoryInput = ClearHistoryRequestModel(threadId: theThreadId, uniqueId: requestUniqueId)
        myChatObject?.clearHistory(clearHistoryInput: clearHistoryInput, uniqueId: { (clearHistoryUniqueId) in
            self.uniqueIdCallback?(clearHistoryUniqueId)
        }, completion: { (clearHistoryServerResponse) in
            self.responseCallback?(clearHistoryServerResponse as! JSON)
        }, cacheResponse: { (clearHistoryCacheResponse) in
            self.cacheCallback?(clearHistoryCacheResponse as! JSON)
        })
        
    }
    
}


extension ClearHistoryAutomation {
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, messageResponse: JSON?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- sendMessage to this thread
        // 4- clear history of this thread
        
        
        switch (contactCellPhone, threadId, messageResponse) {
        case    (.none, .none, .none):
            addContact()
            
        case let (.some(cellPhone), .none, .none):
            createThread(withCellphoneNumber: cellPhone)
            
        case let (_ , .some(thread), .none):
            sendMessage(toThread: thread)
            
        case let (_ , _ , .some(msg)):
            if let thId = msg["subjectId"].int {
                sendRequest(theThreadId: thId)
            }
        }
        
    }
    
    
    // 1
    func addContact() {
        delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "try to addContact, then create a thread with it, then send a message to it", lineNumbers: 2)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil, messageResponse: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
        
    }
    
    
    // 2
    func createThread(withCellphoneNumber cellphoneNumber: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: nil, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
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
                self.delegate?.newInfo(type: MoreInfoTypes.ClearHistory.rawValue, message: "Message has been sent to this threadId = \(id), messageId = \(messageId)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: sentResponse)
            }
            
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
    }
    
}


