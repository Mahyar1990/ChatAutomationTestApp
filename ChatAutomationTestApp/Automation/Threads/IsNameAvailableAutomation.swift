//
//  IsNameAvailableAutomation.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 1/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON


class IsNameAvailableAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let name:       String?
    let typeCode:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (IsAvailableNameModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(name: String?, typeCode: String?) {
        
        self.name       = name
        self.typeCode   = typeCode
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        sendRequest(theName: name ?? Faker.sharedInstance.generateNameAsString(withLength: 14))
    }
    
    func sendRequest(theName: String) {
        delegate?.newInfo(type: MoreInfoTypes.IsNameAvailable.rawValue, message: "send Request to IsNameAvailable with this params: \n name = \(theName)", lineNumbers: 2)
        
        let isNameAvailableInputModel = IsNameAvailableThreadRequestModel(name:     theName,
                                                                          typeCode: typeCode,
                                                                          uniqueId: nil)
        Chat.sharedInstance.isNameAvailable(inputModel: isNameAvailableInputModel, uniqueId: { (isNameAvailableUniqueId) in
            self.uniqueIdCallback?(isNameAvailableUniqueId)
        }, completion: { (isNameAvailableUniqueIdServerResponseModel) in
            self.responseCallback?(isNameAvailableUniqueIdServerResponseModel as! IsAvailableNameModel)
        })
        
    }
    
}
