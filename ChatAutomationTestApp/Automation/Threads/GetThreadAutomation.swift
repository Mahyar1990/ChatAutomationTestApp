//
//  GetThreadAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/14/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a getThread request will send
 */

class GetThreadAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let count:              Int?
    let coreUserId:         Int?
    let metadataCriteria:   JSON?
    let name:               String?
    let new:                Bool?
    let offset:             Int?
    let threadIds:          [Int]?
    let typeCode:           String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackCacheRespoonseTypeAlias   = (GetThreadsModel) -> ()
    typealias callbackServerResponseTypeAlias   = (GetThreadsModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var cacheCallback:      callbackServerResponseTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(count: Int?, coreUserId: Int?, metadataCriteria: JSON?, name: String?, new: Bool?, offset: Int?, threadIds: [Int]?, typeCode: String?) {
        
        self.count              = count
        self.coreUserId         = coreUserId
        self.metadataCriteria   = metadataCriteria
        self.name               = name
        self.new                = new
        self.offset             = offset
        self.threadIds          = threadIds
        self.typeCode           = typeCode
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetThreadsModel) -> (),
                cacheResponse:  @escaping (GetThreadsModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.cacheCallback      = cacheResponse
        self.responseCallback   = serverResponse
        
        if threadIds?.first == 0 {
            sendRequest(theCount: count, theCoreUserId: coreUserId, theMetadataCriteria: metadataCriteria, theName: name, theNew: new, theOffset: offset, theThreadIds: nil, theTypeCode: typeCode)
        } else {
            sendRequest(theCount: count, theCoreUserId: coreUserId, theMetadataCriteria: metadataCriteria, theName: name, theNew: new, theOffset: offset, theThreadIds: threadIds, theTypeCode: typeCode)
        }
        
        
        
    }
    
    
    func sendRequest(theCount: Int?, theCoreUserId: Int?, theMetadataCriteria: JSON?, theName: String?, theNew: Bool?, theOffset: Int?, theThreadIds: [Int]?, theTypeCode: String?) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "send Request to getThread with this params:\ncount = \(theCount ?? 50) coreUserId = \(theCoreUserId ?? 0) , metadataCriteria = \(theMetadataCriteria ?? JSON.null) , name = \(theName ?? "nil") , new = \(theNew ?? false) , offset = \(theOffset ?? 0) , threadIds = \(theThreadIds ?? [0]) , typeCode = \(theTypeCode ?? "nil")", lineNumbers: 2)
        
        let getThreadInput = GetThreadsRequestModel(count: theCount, coreUserId: theCoreUserId, metadataCriteria: theMetadataCriteria, name: theName, new: theNew, offset: theOffset, threadIds: theThreadIds, typeCode: theTypeCode)
        myChatObject?.getThreads(getThreadsInput: getThreadInput, uniqueId: { (getThreadUniqueId) in
//            self.delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "uniqueId = \(getThreadUniqueId)", lineNumbers: 1)
            self.uniqueIdCallback?(getThreadUniqueId)
        }, completion: { (getThreadsServerResponse) in
//            self.delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "server response = \(getThreadsServerResponse as! GetThreadsModel)", lineNumbers: 1)
            self.responseCallback?(getThreadsServerResponse as! GetThreadsModel)
        }, cacheResponse: { (getThreadsCacheResponse) in
//            self.delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "cache response = \(getThreadsCacheResponse as! GetThreadsModel)", lineNumbers: 1)
            self.cacheCallback?(getThreadsCacheResponse)
        })
        
    }
    
    
}
