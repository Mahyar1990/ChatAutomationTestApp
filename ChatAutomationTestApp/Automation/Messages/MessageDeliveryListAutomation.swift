//
//  MessageDeliveryListAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a DeleteMessage request will send
 */

class MessageDeliveryListAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    let count:      Int?
    let messageId:  Int?
    let offset:     Int?
    let typeCode:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (GetThreadParticipantsModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(count: Int?, messageId: Int?, offset: Int?, typeCode: String?) {
        
        self.count      = count
        self.messageId  = messageId
        self.offset     = offset
        self.typeCode   = typeCode
        
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetThreadParticipantsModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let mId = messageId {
            sendRequest(theMessageId: mId)
        } else {
            delegate?.newInfo(type: MoreInfoTypes.MessageDeliveryList.rawValue, message: "MessageId has not been specified, so we will create a thread and send a message, then we will send MessageDelivery request", lineNumbers: 2)
            sendMessage()
        }
        
    }
    
    
    func sendRequest(theMessageId: Int) {
        
        delegate?.newInfo(type: MoreInfoTypes.MessageDeliveryList.rawValue, message: "send Request to get MessageDeliveryList with this params:\n count = \(count ?? 0) , messageId = \(theMessageId) , offset = \(offset ?? 0) , typeCode = \(typeCode ?? "nil")", lineNumbers: 2)
        
        let deliveryInput = MessageDeliverySeenListRequestModel(count:              count,
                                                                messageId:          theMessageId,
                                                                offset:             offset,
                                                                requestTypeCode:    typeCode,
                                                                requestUniqueId:    nil)
        
        Chat.sharedInstance.messageDeliveryList(messageDeliveryListInput: deliveryInput, uniqueId: { (messageDeliveryListUniqueId) in
            self.uniqueIdCallback?(messageDeliveryListUniqueId)
        }, completion: { (messageDeliveryListResponse) in
            self.responseCallback?(messageDeliveryListResponse as! GetThreadParticipantsModel)
        })
        
    }
    
    
    func sendMessage() {
        
        let x = SendTextMessageAutomation(content: "hi", metaData: nil, repliedTo: nil, systemMetadata: nil, threadId: nil, typeCode: nil, uniqueId: nil)
        x.create(uniqueId: { _ in }, serverSentResponse: { (sent) in
            self.delegate?.newInfo(type: MoreInfoTypes.MessageDeliveryList.rawValue, message: "new Message has been sent", lineNumbers: 1)
            print("\n\nSent: \n\(sent)\n\n")
            if let messageId = sent.message?.id {
                self.sendRequest(theMessageId: messageId)
            }
        }, serverDeliverResponse: { (deliver) in
            print("\n\nDeliver: \n\(deliver)\n\n")
        }) { (seen) in
            print("\n\nSeen: \n\(seen)\n\n")
        }
        
    }
    
}
