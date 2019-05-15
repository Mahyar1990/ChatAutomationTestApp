//
//  MessageDeliveryListAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

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
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(count: Int?, messageId: Int?, offset: Int?, typeCode: String?) {
        
        self.count      = count
        self.messageId  = messageId
        self.offset     = offset
        self.typeCode   = typeCode
        
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (JSON) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let mId = messageId {
            sendRequest(theMessageId: mId)
        } else {
            
        }
        
    }
    
    
    func sendRequest(theMessageId: Int) {
        
        delegate?.newInfo(type: MoreInfoTypes.MessageDeliveryList.rawValue, message: "send Request to get MessageDeliveryList with this params:\n count = \(count ?? 0) , messageId = \(theMessageId) , offset = \(offset ?? 0) , typeCode = \(typeCode ?? "nil")", lineNumbers: 2)
        
        let deliveryInput = MessageDeliverySeenListRequestModel(count: count, messageId: theMessageId, offset: offset, typeCode: typeCode)
        myChatObject?.messageDeliveryList(messageDeliveryListInput: deliveryInput, uniqueId: { (messageDeliveryListUniqueId) in
            self.uniqueIdCallback?(messageDeliveryListUniqueId)
        }, completion: { (messageDeliveryListResponse) in
            self.responseCallback?(messageDeliveryListResponse as! JSON)
        })
        
    }
    
}
