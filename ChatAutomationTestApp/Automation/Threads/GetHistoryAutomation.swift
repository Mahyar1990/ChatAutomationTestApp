//
//  GetHistoryAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/19/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import PodChat
//import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a getHistory request will send
 */

class GetHistoryAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    let count:              Int?
    let firstMessageId:     Int?
    let fromTime:           UInt?
    let lastMessageId:      Int?
    let messageId:          Int?
    let metadataCriteria:   JSON?
    let offset:             Int?
    let order:              String?
    let query:              String?
    let threadId:           Int?
    let toTime:             UInt?
    let typeCode:           String?
    let requestUniqueId:    String?
    
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackCacheRespoonseTypeAlias   = (GetHistoryModel) -> ()
    typealias callbackServerResponseTypeAlias   = (GetHistoryModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var cacheCallback:      callbackServerResponseTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(count: Int?, firstMessageId: Int?, fromTime: UInt?, lastMessageId: Int?, messageId: Int?, metadataCriteria: JSON?, offset: Int?, order: String?, query: String?, threadId: Int?, toTime: UInt?, typeCode: String?, uniqueId: String?) {
        
        self.count              = count
        self.firstMessageId     = firstMessageId
        self.fromTime           = fromTime
        self.lastMessageId      = lastMessageId
        self.messageId          = messageId
        self.metadataCriteria   = metadataCriteria
        self.offset             = offset
        self.order              = order
        self.query              = query
        self.threadId           = threadId
        self.toTime             = toTime
        self.typeCode           = typeCode
        self.requestUniqueId    = uniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetHistoryModel) -> (),
                cacheResponse:  @escaping (GetHistoryModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.cacheCallback      = cacheResponse
        self.responseCallback   = serverResponse
        
        if let thId = threadId {
            let requestModel = GetHistoryRequestModel(count: count, firstMessageId: firstMessageId, fromTime: fromTime, lastMessageId: lastMessageId, messageId: messageId, metadataCriteria: metadataCriteria, offset: offset, order: order, query: query, threadId: thId, toTime: toTime, typeCode: typeCode, uniqueId: requestUniqueId)
            sendRequest(getHistoryRequest: requestModel)
            
        } else {
            sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: nil)
        }
        
    }
    
    
    func sendRequest(getHistoryRequest: GetHistoryRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetHistory.rawValue, message: "send Request to getHistory with this params:\ncount = \(getHistoryRequest.count ?? 50) firstMessageId = \(getHistoryRequest.firstMessageId ?? -1) , fromTime = \(getHistoryRequest.fromTime ?? 0) , lastMessageId = \(getHistoryRequest.lastMessageId ?? 0) , messageId = \(getHistoryRequest.messageId ?? 0) , metadataCriteria = \(getHistoryRequest.metadataCriteria ?? JSON.null) , offset = \(getHistoryRequest.offset ?? 0) , order = \(getHistoryRequest.order ?? "nil") , query = \(getHistoryRequest.query ?? "nil") , threadId = \(getHistoryRequest.threadId ) , toTime = \(getHistoryRequest.toTime ?? 0) , typeCode = \(getHistoryRequest.typeCode ?? "nil") , uniqueId = \(getHistoryRequest.uniqueId ?? "nil")", lineNumbers: 3)
        
        myChatObject?.getHistory(getHistoryInput: getHistoryRequest, uniqueId: { (getHistoryUniqueId) in
            self.uniqueIdCallback?(getHistoryUniqueId)
        }, completion: { (getHistoryServerResponse) in
            self.responseCallback?(getHistoryServerResponse as! GetHistoryModel)
        }, cacheResponse: { (getHistoryCahceResponse) in
            self.responseCallback?(getHistoryCahceResponse)
        }, textMessagesNotSent: { ([QueueOfWaitTextMessagesModel]) in
//            <#code#>
        }, editMessagesNotSent: { ([QueueOfWaitEditMessagesModel]) in
//            <#code#>
        }, forwardMessagesNotSent: { ([QueueOfWaitForwardMessagesModel]) in
//            <#code#>
        }, fileMessagesNotSent: { ([QueueOfWaitFileMessagesModel]) in
//            <#code#>
        }, uploadImageNotSent: { ([QueueOfWaitUploadImagesModel]) in
//            <#code#>
        }, uploadFileNotSent: { ([QueueOfWaitUploadFilesModel]) in
//            <#code#>
        })
        
    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, messageResponse: JSON?) {
        // 1- create contact
        // 2- create new thread with this contact, and get the threadId
        // 3- send a message
        // 4- sendRequest
        
        
        switch (contactCellPhone, threadId, messageResponse) {
        case    (.none, .none, .none):
            addContact()
            
        case let (.some(cellPhone), .none, .none):
            createThread(cellPhoneNumber: cellPhone)
            
        case let (_ , .some(thread), .none):
            sendMessage(toThread: thread)
            
        case let (_ , _ , .some(msg)):
            if let thId = msg["subjectId"].int {
                self.createGetHistoryModel(withThreadId: thId)
            }
        }
        
    }
    
    
    // 1
    func addContact() {
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellPhone = myContact.cellphoneNumber {
                    self.delegate?.newInfo(type: MoreInfoTypes.GetHistory.rawValue, message: "new conract has been created, cellphone number = \(cellPhone)", lineNumbers: 1)
                    self.sendRequestSenario(contactCellPhone: cellPhone, threadId: nil, messageResponse: nil)
                } else {
                    // handle error that didn't get contactId in the contact model
                }
                
            } else {
                // handle error that didn't add Contact Model
            }
        }
    }
    
    
    // 2
    func createThread(cellPhoneNumber: String) {
        let myInvitee = Invitee(id: "\(cellPhoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
        let createThread = CreateThreadAutomation(description: nil, image: nil, invitees: [myInvitee], metadata: nil, title: "new Chat Thread", type: nil, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (CreateThreadModelResponse, on) in
            if let conversationModel = CreateThreadModelResponse.thread {
                if let thId = conversationModel.id {
                    self.sendRequestSenario(contactCellPhone: nil, threadId: thId, messageResponse: nil)
                } else {
                    // handle error that the conversation model doesn't have id (threadId)
                }
            } else {
                // handle error that the response of createThread doesn't have Conversation Model
            }
            
        })
        
    }
    
    
    // 3
    func sendMessage(toThread thread: Int) {
        let sendMessage = SendTextMessageAutomation(content: "Hi", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: thread, typeCode: nil, uniqueId: nil)
        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (serverResponse) in
            self.sendRequestSenario(contactCellPhone: nil, threadId: nil, messageResponse: serverResponse)
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
        
    }
    
    
    // 4
    func createGetHistoryModel(withThreadId threadId: Int) {
        let getHistoryModel = GetHistoryRequestModel(count: nil, firstMessageId: nil, fromTime: nil, lastMessageId: nil, messageId: nil, metadataCriteria: nil, offset: nil, order: nil, query: nil, threadId: threadId, toTime: nil, typeCode: nil, uniqueId: nil)
        self.sendRequest(getHistoryRequest: getHistoryModel)
    }
    
    
    
}
