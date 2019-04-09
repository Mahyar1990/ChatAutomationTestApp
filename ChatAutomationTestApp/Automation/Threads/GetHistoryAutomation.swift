//
//  GetHistoryAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/19/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
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
            sendMessageThenGetHistory()
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
    
    
    func sendMessageThenGetHistory() {
        // 1- create contact
        // 2- create new thread with this contact, and get the threadId
        // 3- send a message
        // 4- sendRequest
        
        // 1
        let addContact = AddContactAutomation(cellphoneNumber: nil, email: nil, firstName: nil, lastName: nil)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.GetHistory.rawValue, message: "new conract has been created, contact id = \(contactId)", lineNumbers: 1)
                    
                    // 2
                    let myInvitee = Invitee(id: "\(contactId)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID)")
                    let createThread = CreateThreadAutomation(description: nil, image: nil, invitees: [myInvitee], metadata: nil, title: "new Chat Thread", type: nil, requestUniqueId: nil)
                    createThread.create(uniqueId: { (_, _) in }, serverResponse: { (CreateThreadModelResponse, on) in
                        
                        // 3
                        if let conversationModel = CreateThreadModelResponse.thread {
                            if let thId = conversationModel.id {
                                
                                let sendMessage = SendTextMessageAutomation(content: "Hi", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: thId, typeCode: nil, uniqueId: nil)
                                sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (serverResponse) in
                                    
                                    // 4
                                    let getHistoryModel = GetHistoryRequestModel(count: nil, firstMessageId: nil, fromTime: nil, lastMessageId: nil
                                        , messageId: nil, metadataCriteria: nil, offset: nil, order: nil, query: nil, threadId: thId, toTime: nil, typeCode: nil, uniqueId: nil)
                                    self.sendRequest(getHistoryRequest: getHistoryModel)
                                    
                                }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
                                
                            } else {
                                // handle error that the conversation model doesn't have id (threadId)
                            }
                        } else {
                            // handle error that the response of createThread doesn't have Conversation Model
                        }
                        
                    })
                    
                } else {
                    // handle error that didn't get contactId in the contact model
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }
    }
    
    
}
