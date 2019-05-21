//
//  AddParticipantAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/15/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import PodChat
//import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a getThreadParticipants request will send
 */

class AddParticipantAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let contacts:           [Int]?
    let threadId:           Int?
    let typeCode:           String?
    let requestUniqueId:    String?
    
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (AddParticipantModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(contacts: [Int]?, threadId: Int?, typeCode: String?, uniqueId: String?) {
        
        self.contacts           = contacts
        self.threadId           = threadId
        self.typeCode           = typeCode
        self.requestUniqueId    = uniqueId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (AddParticipantModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let id = threadId {
            if let myContacts = contacts {
                sendRequest(theContacts: myContacts, theThreadId: id)
            } else {
                
            }
        } else {
            delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "threadId is not specified so we will create a thread by ourself and do the rest", lineNumbers: 2)
            sendRequestSenario(contactCellPhone: nil, threadId: nil, contacts: nil)
        }
    }
    
    func sendRequest(theContacts: [Int], theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "send Request addParticipant with this params:\ncontacts = \(theContacts), threadId = \(theThreadId) , typeCode = \(typeCode ?? "nil"), uniqueId = \(requestUniqueId ?? "nil")", lineNumbers: 2)
        
        let addParticipantInput = AddParticipantsRequestModel(contacts: theContacts,
                                                              threadId: theThreadId,
                                                              typeCode: typeCode,
                                                              uniqueId: requestUniqueId)
        myChatObject?.addParticipants(addParticipantsInput: addParticipantInput, uniqueId: { (addParticipantsUniqueId) in
            print("uniqueId = \(addParticipantsUniqueId)")
            self.uniqueIdCallback?(addParticipantsUniqueId)
        }, completion: { (addParticipantServerResponse) in
            print("response = \((addParticipantServerResponse as! AddParticipantModel).returnDataAsJSON())")
            self.responseCallback?(addParticipantServerResponse as! AddParticipantModel)
        })
        
    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?, contacts: [Int]?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- add contact to this thread
        // 4- send request
        
        switch (contactCellPhone, threadId, contacts) {
        case (.none, .none, .none):
            addContact()
            
        case let (.some(cellPhone), .none, .none):
            createThread(withCellphoneNumber: cellPhone)
            
        case let (_ , .some(id), .none):
            addContactToThread(threadId: id)
            
        case let (_ , .some(id), .some(cntcts)):
            sendRequest(theContacts: cntcts, theThreadId: id)
            
        case (_, .none, .some(_)):
            print("wrong situation")
        }
    }
    
    
    func addContact() {
        // 1
        let arvin = Faker.sharedInstance.ArvinAsContact
        let addContact = AddContactAutomation(cellphoneNumber: arvin.cellphoneNumber, email: arvin.email, firstName: arvin.firstName, lastName: arvin.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contact id = \(id).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: "\(id)", threadId: nil, contacts: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "there is no id when addContact with this user (firstName = \(arvin.firstName) , cellphoneNumber = \(arvin.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(arvin.firstName) , cellphoneNumber = \(arvin.cellphoneNumber) , lastName = \(arvin.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withCellphoneNumber cellphoneNumber: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID)")
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: ThreadTypes.PUBLIC_GROUP.rawValue, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: id, contacts: nil)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    // 3
    func addContactToThread(threadId: Int) {
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { (_) in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "New Contact has been created, now try to add this contact id: \(id) to the thread \(threadId)", lineNumbers: 1)
                    self.sendRequestSenario(contactCellPhone: nil, threadId: threadId, contacts: [id])
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "there is no id when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    
    
}
