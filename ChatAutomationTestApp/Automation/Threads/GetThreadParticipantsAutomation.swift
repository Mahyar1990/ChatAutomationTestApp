//
//  GetThreadParticipantsAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/14/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a getThreadParticipants request will send
 */

class GetThreadParticipantsAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let count:          Int?
    let firstMessageId: Int?
    let lastMessageId:  Int?
    let name:           String?
    let offset:         Int?
    let threadId:       Int?
    let typeCode:       String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackCacheRespoonseTypeAlias   = (GetThreadParticipantsModel) -> ()
    typealias callbackServerResponseTypeAlias   = (GetThreadParticipantsModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var cacheCallback:      callbackServerResponseTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(count: Int?, firstMessageId: Int?, lastMessageId: Int?, name: String?, offset: Int?, threadId: Int?, typeCode: String?) {
        
        self.count              = count
        self.firstMessageId     = firstMessageId
        self.lastMessageId      = lastMessageId
        self.name               = name
        self.offset             = offset
        self.threadId           = threadId
        self.typeCode           = typeCode
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (GetThreadParticipantsModel) -> (),
                cacheResponse:  @escaping (GetThreadParticipantsModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.cacheCallback      = cacheResponse
        self.responseCallback   = serverResponse
        
        if let id = threadId {
            sendRequest(theThreadId: id)
        } else {
            sendRequestSenario(contactCellPhone: nil, threadId: nil)
        }
    }
    
    func sendRequest(theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.GetThreadParticipants.rawValue, message: "send Request to getThreadParticipants with this params:\ncount = \(count ?? 50) firstMessageId = \(firstMessageId ?? 0) , lastMessageId = \(firstMessageId ?? 0) , name = \(name ?? "nil") , offset = \(offset ?? 0) , threadIds = \(theThreadId) , typeCode = \(typeCode ?? "nil")", lineNumbers: 2)
        
        let getThreadParticipantsInput = GetThreadParticipantsRequestModel(count:           count,
                                                                           firstMessageId:  firstMessageId,
                                                                           lastMessageId:   lastMessageId,
                                                                           name:            name,
                                                                           offset:          offset,
                                                                           threadId:        theThreadId,
                                                                           typeCode:        typeCode)
        myChatObject?.getThreadParticipants(getThreadParticipantsInput: getThreadParticipantsInput, uniqueId: { (getThreadParticipantsUniqueId) in
            self.uniqueIdCallback?(getThreadParticipantsUniqueId)
        }, completion: { (getThreadParticipantsServerResponse) in
            self.responseCallback?(getThreadParticipantsServerResponse as! GetThreadParticipantsModel)
        }, cacheResponse: { (getThreadParticipantsCacheResponse) in
            self.cacheCallback?(getThreadParticipantsCacheResponse)
        })
    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- getparticipants
        
        switch (contactCellPhone, threadId) {
        case    (.none, .none):
            print("here 1")
            addContact()
            
        case let (.some(cellPhone), .none):
            print("here 2")
            createThread(withCellphoneNumber: cellPhone)
            
        case let (_ , .some(id)):
            print("here 3")
            self.sendRequest(theThreadId: id)
            
        }
    }
    
    
    func addContact() {
        // 1
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    self.delegate?.newInfo(type: MoreInfoTypes.GetThreadParticipants.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.GetThreadParticipants.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.GetThreadParticipants.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withCellphoneNumber cellphoneNumber: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.GetThreadParticipants.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: id)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    
}
