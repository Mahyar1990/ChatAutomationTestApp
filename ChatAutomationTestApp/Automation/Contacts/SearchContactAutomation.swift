//
//  SearchContactAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK


class SearchContactAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let cellphoneNumber: String?
    let email:          String?
    let firstName:      String?
    let id:             Int?
    let lastName:       String?
    let offset:         Int?
    let size:           Int?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (ContactModel) -> ()
    typealias callbackCacheResponseTypeAlias    = (GetContactsModel) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverResponseCallback: callbackServerResponseTypeAlias?
    private var cacheResponseCallback:  callbackCacheResponseTypeAlias?
    
    init(cellphoneNumber: String?, email: String?, firstName: String?, id: Int?, lastName: String?, offset: Int?, size: Int?, requestUniqueId: String?) {
        self.cellphoneNumber = cellphoneNumber
        self.email          = email
        self.firstName      = firstName
        self.id             = id
        self.lastName       = lastName
        self.offset         = offset
        self.size           = size
        self.requestUniqueId = requestUniqueId
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias,
                cacheResponse: @escaping (GetContactsModel) -> ()) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverResponseCallback = serverResponse
        self.cacheResponseCallback  = cacheResponse
        
        sendRequest()
        
    }
    
    
    func sendRequest() {
        
        delegate?.newInfo(type: MoreInfoTypes.SearchContact.rawValue, message: "Send SearchContact request with this param:\n cellphoneNumber = \(cellphoneNumber ?? "nil") , email = \(email ?? "nil") , firstName = \(firstName ?? "nil") , id = \(id ?? 0) , lastName = \(lastName ?? "nil") , offset = \(offset ?? 0) , size = \(size ?? 0) , uniqueId = \(requestUniqueId ?? "nil")", lineNumbers: 3)
        
        let searchContactInput = SearchContactsRequestModel(cellphoneNumber: cellphoneNumber,
                                                            email:          email,
                                                            firstName:      firstName,
                                                            id:             id,
                                                            lastName:       lastName,
                                                            offset:         offset,
                                                            size:           size,
                                                            uniqueId:       requestUniqueId)
        myChatObject?.searchContacts(searchContactsInput: searchContactInput, uniqueId: { (searchContactUniqueId) in
            self.uniqueIdCallback?(searchContactUniqueId)
        }, completion: { (searchContactServerResponse) in
            self.serverResponseCallback?(searchContactServerResponse as! ContactModel)
        }, cacheResponse: { (searchContactCacheResponse) in
            self.cacheResponseCallback?(searchContactCacheResponse)
        })
        
    }
    
    
}
