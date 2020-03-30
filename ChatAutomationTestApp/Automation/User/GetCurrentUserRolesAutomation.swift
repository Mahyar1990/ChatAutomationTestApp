//
//  GetCurrentUserRolesAutomation.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 1/6/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
import SwiftyJSON

class GetCurrentUserRolesAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let threadId:       Int?
    let typeCode:       String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackCacheRespoonseTypeAlias   = (GetCurrentUserRolesModel) -> ()
    typealias callbackServerResponseTypeAlias   = (GetCurrentUserRolesModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var cacheCallback:      callbackServerResponseTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(threadId: Int?, typeCode: String?) {
        self.threadId           = threadId
        self.typeCode           = typeCode
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetCurrentUserRolesModel) -> (),
                cacheResponse:  @escaping (GetCurrentUserRolesModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.cacheCallback      = cacheResponse
        self.responseCallback   = serverResponse
        
        sendRequestSenario(contactId: nil, threadId: threadId)
    }
    
    func sendRequest(theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.GetCurrentUserRole.rawValue, message: "send Request to getCurrentUserRoles with this params:\n threadIds = \(theThreadId) , typeCode = \(typeCode ?? "nil")", lineNumbers: 2)
        
        let getCurrentUserRolesInput = GetCurrentUserRolesRequestModel(threadId: theThreadId,
                                                                       typeCode: typeCode,
                                                                       uniqueId: nil)
        
        Chat.sharedInstance.getCurrentUserRoles(inputModel: getCurrentUserRolesInput, getCacheResponse: nil, uniqueId: { (currentUserRolesUniqueId) in
            self.uniqueIdCallback?(currentUserRolesUniqueId)
        }, completion: { (currentUserRolesServerResponse) in
            self.responseCallback?(currentUserRolesServerResponse as! GetCurrentUserRolesModel)
        }, cacheResponse: { (currentUserRolesCacheResponse) in
            self.cacheCallback?(currentUserRolesCacheResponse)
        })
            
    }
    
    
    func sendRequestSenario(contactId: Int?, threadId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- getparticipants
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactId, threadId) {
            case    (.none, .none):         self.addContact()
            case let (.some(id), .none):    self.createThread(withContactId: id)
            case let (_ , .some(id)):       self.sendRequest(theThreadId: id)
            }
        }
        
    }
    
    
    func addContact() {
        // 1
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.GetCurrentUserRole.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contactId = \(contactId).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: contactId, threadId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.GetCurrentUserRole.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.GetCurrentUserRole.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withContactId contactId: Int) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(contactId)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, uniqueName: nil, type: nil, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.GetCurrentUserRole.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    
}
