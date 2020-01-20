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
    let metadataCriteria:   String?
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
    
    init(count: Int?, coreUserId: Int?, metadataCriteria: String?, name: String?, new: Bool?, offset: Int?, threadIds: [Int]?, typeCode: String?) {
        
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
        
        self.sendRequestSenario(contactCellPhone: nil, threadId: (threadIds?.first == 0) ? nil : threadIds?.first)
//        if threadIds?.first == 0 {
//            sendRequest(theThreadIds: nil)
//        } else {
//            sendRequest(theThreadIds: threadIds)
//        }
        
    }
    
    
    func sendRequest(theThreadIds: [Int]?) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "send Request to getThread with this params:\ncount = \(count ?? 50) coreUserId = \(coreUserId ?? 0) , metadataCriteria = \(metadataCriteria ?? "nil") , name = \(name ?? "nil") , new = \(new ?? false) , offset = \(offset ?? 0) , threadIds = \(theThreadIds ?? [0]) , typeCode = \(typeCode ?? "nil")", lineNumbers: 2)
        
        let getThreadInput = GetThreadsRequestModel(count: count,
                                                    creatorCoreUserId:  coreUserId,
                                                    metadataCriteria:   metadataCriteria,
                                                    name:               name,
                                                    new:                new,
                                                    offset:             offset,
                                                    partnerCoreContactId: nil,
                                                    partnerCoreUserId:  nil,
                                                    threadIds:          theThreadIds,
                                                    typeCode:           typeCode,
                                                    uniqueId:           nil)
        
        Chat.sharedInstance.getThreads(inputModel: getThreadInput, uniqueId: { (getThreadUniqueId) in
            self.uniqueIdCallback?(getThreadUniqueId)
        }, completion: { (getThreadsServerResponse) in
            self.responseCallback?(getThreadsServerResponse as! GetThreadsModel)
        }, cacheResponse: { (getThreadsCacheResponse) in
            self.cacheCallback?(getThreadsCacheResponse)
        })
        
    }
    
    
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?) {
        // 1- create contact
        // 2- create new thread with this contact, and get the threadId
        // 3- send a message
        // 4- sendRequest
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactCellPhone, threadId) {
            case    (.none, .none):              self.addContact()
            case let (.some(cellPhone), .none):  self.createThread(cellPhoneNumber: cellPhone)
            case let (_ , .some(thread)):        self.sendRequest(theThreadIds: [thread])
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
                    self.delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "new conract has been created, cellphone number = \(cellPhone)", lineNumbers: 1)
                    self.sendRequestSenario(contactCellPhone: cellPhone, threadId: nil)
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
                    self.delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "new thread has been created, threadId = \(thId)", lineNumbers: 1)
                    self.sendRequestSenario(contactCellPhone: nil, threadId: thId)
                } else {
                    // handle error that the conversation model doesn't have id (threadId)
                }
            } else {
                // handle error that the response of createThread doesn't have Conversation Model
            }
            
        })
        
    }
    
    
    
    
    
}
