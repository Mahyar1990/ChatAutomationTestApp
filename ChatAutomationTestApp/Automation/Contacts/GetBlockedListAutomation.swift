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
        
        sendRequest(theCount: count, theOffset: offset)
    }
    
    
    func sendRequest(theCount: Int?, theOffset: Int?) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetBlockedList.rawValue, message: "send Request to GetBlockedList with this params:\ncount = \(theCount ?? 50) , offset = \(theOffset ?? 0) , typeCode = \(self.typeCode ?? "nil")", lineNumbers: 2)
        
        let getBlockedListInput = GetBlockedContactListRequestModel(count: theCount, offset: theOffset, typeCode: self.typeCode)
        myChatObject?.getBlockedContacts(getBlockedContactsInput: getBlockedListInput, uniqueId: { (getBlockedListUniqueId) in
            self.uniqueIdCallback?(getBlockedListUniqueId)
        }, completion: { (getBlockedListResponse) in
            self.responseCallback?(getBlockedListResponse as! GetBlockedContactListModel)
        })
        
    }
    
    
}
