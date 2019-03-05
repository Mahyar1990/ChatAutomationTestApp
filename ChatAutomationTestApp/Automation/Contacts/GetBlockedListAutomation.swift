//
//  GetBlockedListAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/14/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK

/*
 if somebody call this method,
 a getBlockedList request will send
 */

class GetBlockedListAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let count:      Int?
    let offset:     Int?
    let typeCode:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (GetBlockedContactListModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(count: Int?, offset: Int?, typeCode: String?) {
        
        self.count      = count
        self.offset     = offset
        self.typeCode   = typeCode
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetBlockedContactListModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        sendRequest(theCount: count, theOffset: offset, theTypeCode: typeCode)
        
    }
    
    
    func sendRequest(theCount: Int?, theOffset: Int?, theTypeCode: String?) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetBlockedList.rawValue, message: "send Request to GetBlockedList with this params:\ncount = \(theCount ?? 50) , offset = \(theOffset ?? 0) , typeCode = \(theTypeCode ?? "nil")", lineNumbers: 2)
        
        let getBlockedListInput = GetBlockedContactListRequestModel(count: theCount, offset: theOffset, typeCode: theTypeCode)
        myChatObject?.getBlockedContacts(getBlockedContactsInput: getBlockedListInput, uniqueId: { (getBlockedListUniqueId) in
//            self.delegate?.newInfo(type: MoreInfoTyps.GetBlockedList.rawValue, message: "uniqueId = \(getContactUniqueId)")
            self.uniqueIdCallback?(getBlockedListUniqueId)
        }, completion: { (getBlockedListResponse) in
//            self.delegate?.newInfo(type: MoreInfoTyps.GetBlockedList.rawValue, message: "server response = \(getBlockedListResponse as! GetBlockedContactListModel)")
            self.responseCallback?(getBlockedListResponse as! GetBlockedContactListModel)
        })
        
    }
    
    
}
