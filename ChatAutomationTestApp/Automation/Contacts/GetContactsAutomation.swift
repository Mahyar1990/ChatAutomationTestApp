//
//  GetContactsAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK

/*
 if somebody call this method,
 a getContacts request will send
 if the callers did't send input parameters, inputs will fill qoutomatically by this parameters:
 - count: will be some number between 0 and 50
 - offset: will be some number between 0 and 50
 */

class GetContactsAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let count:      Int?
    let name:       String?
    let offset:     Int?
    let typeCode:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackCacheRespoonseTypeAlias   = (GetContactsModel) -> ()
    typealias callbackServerResponseTypeAlias   = (GetContactsModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var cacheCallback:      callbackServerResponseTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(count: Int?, name: String?, offset: Int?, typeCode: String?) {
        
        self.count      = count
        self.name       = name
        self.offset     = offset
        self.typeCode   = typeCode
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetContactsModel) -> (),
                cacheResponse:  @escaping (GetContactsModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.cacheCallback      = cacheResponse
        self.responseCallback   = serverResponse
        
        // if none of the parameters filled by the user, jenerate fake values and fill the input model to send request
        if (count == nil) && (name == nil) && (offset == nil) {
            let fakeParams = Faker.sharedInstance.generateFakeGetContactParams()
            delegate?.newInfo(type: MoreInfoTypes.GetContact.rawValue, message: "create random numbers:\ncount = \(fakeParams.count) , offset = \(fakeParams.offset)", lineNumbers: 2)
            sendRequest(theCount: fakeParams.count, theOffset: fakeParams.offset, theName: name)
        }
            // some or all of the parameters are filled by the client, so send request with this params
        else {
            sendRequest(theCount: count, theOffset: offset, theName: name)
        }
        
    }
    
    
    func sendRequest(theCount: Int?, theOffset: Int?, theName: String?) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetContact.rawValue, message: "send Request to getContacts with this params:\ncount = \(theCount ?? 50) , offset = \(theOffset ?? 0) , name = \(theName ?? "nil") , typeCode = \(typeCode ?? "nil")", lineNumbers: 2)
        
        let getContactInput = GetContactsRequestModel(count: theCount, name: theName, offset: theOffset, typeCode: typeCode)
        myChatObject?.getContacts(getContactsInput: getContactInput, uniqueId: { (getContactUniqueId) in
            self.uniqueIdCallback?(getContactUniqueId)
        }, completion: { (getContactsResponse) in
            self.responseCallback?(getContactsResponse as! GetContactsModel)
        }, cacheResponse: { (getContactsCacheResponse) in
            self.cacheCallback?(getContactsCacheResponse)
        })
    }
    
    
}



