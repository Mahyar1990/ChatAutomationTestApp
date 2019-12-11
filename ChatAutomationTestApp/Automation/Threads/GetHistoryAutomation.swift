//
//  GetHistoryAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/19/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
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
    
    init(count: Int?, firstMessageId: Int?, fromTime: UInt?, lastMessageId: Int?, messageId: Int?, metadataCriteria: JSON?, offset: Int?, order: String?, query: String?, threadId: Int?, toTime: UInt?, typeCode: String?, requestUniqueId: String?) {
        
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
        self.requestUniqueId    = requestUniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetHistoryModel) -> (),
                cacheResponse:  @escaping (GetHistoryModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.cacheCallback      = cacheResponse
        self.responseCallback   = serverResponse
        
        sendRequestSenario(contactCellPhone: nil, threadId: nil, responseThreadId: threadId)
    }
    
    
    func sendRequest(getHistoryRequest: GetHistoryRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetHistory.rawValue, message: "send Request to getHistory with this params:\ncount = \(getHistoryRequest.count ?? 50) , fromTime = \(getHistoryRequest.fromTime ?? 0) , metadataCriteria = \(getHistoryRequest.metadataCriteria ?? JSON.null) , offset = \(getHistoryRequest.offset ?? 0) , order = \(getHistoryRequest.order) , query = \(getHistoryRequest.query ?? "nil") , threadId = \(getHistoryRequest.threadId ) , toTime = \(getHistoryRequest.toTime ?? 0) , typeCode = \(getHistoryRequest.typeCode ?? "nil") , uniqueId = \(getHistoryRequest.uniqueId ?? "nil")", lineNumbers: 3)
        
        Chat.sharedInstance.getHistory(getHistoryInput: getHistoryRequest, uniqueId: { (getHistoryUniqueId) in
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
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, responseThreadId: Int?) {
        // 1- create contact
        // 2- create new thread with this contact, and get the threadId
        // 3- send a message
        // 4- sendRequest
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactCellPhone, threadId, responseThreadId) {
            case    (.none, .none, .none):              self.addContact()
            case let (.some(cellPhone), .none, .none):  self.createThread(cellPhoneNumber: cellPhone)
            case let (_ , .some(thread), .none):        self.sendMessage(toThread: thread)
            case let (_ , _ , .some(msg)):              self.createGetHistoryModel(withThreadId: msg)
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
                    self.sendRequestSenario(contactCellPhone: cellPhone, threadId: nil, responseThreadId: nil)
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
        let myInvitee = Invitee(id: "\(cellPhoneNumber)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
        let createThread = CreateThreadAutomation(description: nil, image: nil, invitees: [myInvitee], metadata: nil, title: "new Chat Thread", type: nil, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModelResponse, on) in
            if let conversationModel = createThreadModelResponse.thread {
                if let thId = conversationModel.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.GetHistory.rawValue, message: "new thread has been created, threadId = \(thId)", lineNumbers: 1)
                    self.sendRequestSenario(contactCellPhone: nil, threadId: thId, responseThreadId: nil)
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
        let sendMessage = SendTextMessageAutomation(content:        "Hi",
                                                    metaData:       nil,
                                                    repliedTo:      nil,
                                                    systemMetadata: nil,
                                                    threadId:       thread,
                                                    typeCode:       nil,
                                                    uniqueId:       nil)
        sendMessage.create(uniqueId: { (_) in }, serverSentResponse: { (serverResponse) in
            self.delegate?.newInfo(type: MoreInfoTypes.GetHistory.rawValue, message: "new message has been sent, on threadId = \(thread) and message = Hi", lineNumbers: 1)
            self.sendRequestSenario(contactCellPhone: nil, threadId: nil, responseThreadId: serverResponse.threadId)
        }, serverDeliverResponse: { (_) in }, serverSeenResponse: { (_) in })
        
    }
    
    
    // 4
    func createGetHistoryModel(withThreadId threadId: Int) {
        let getHistoryModel = GetHistoryRequestModel(count:             count,
//                                                     firstMessageId:    firstMessageId,
                                                     fromTime:          fromTime,
//                                                     lastMessageId:     lastMessageId,
                                                     messageId:         messageId,
                                                     messageType: nil,
                                                     metadataCriteria:  metadataCriteria,
                                                     offset:            offset,
                                                     order:             order,
                                                     query:             query,
                                                     senderId:          nil,
                                                     threadId:          threadId,
                                                     toTime:            toTime,
                                                     uniqueIds:         nil,
                                                     userId:            nil,
                                                     typeCode:          typeCode,
                                                     uniqueId:          requestUniqueId)
        self.sendRequest(getHistoryRequest: getHistoryModel)
    }
    
    
    
}
