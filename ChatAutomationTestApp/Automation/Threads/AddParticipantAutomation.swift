//
//  AddParticipantAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/15/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a getThreadParticipants request will send
 */

class AddParticipantAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let contacts:   [Int]?
    let threadId:   Int?
    let typeCode:   String?
    let requestUniqueId:   String?
    
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (AddParticipantModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(contacts: [Int]?, threadId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.contacts           = contacts
        self.threadId           = threadId
        self.typeCode           = typeCode
        self.requestUniqueId    = requestUniqueId
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
            sendRequestSenario(contactId: nil, threadId: nil, contacts: nil)
        }
    }
    
    func sendRequest(theContacts: [Int], theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "send Request addParticipant with this params:\ncontacts = \(theContacts), threadId = \(theThreadId) , typeCode = \(typeCode ?? "nil"), uniqueId = \(requestUniqueId ?? "nil")", lineNumbers: 2)
        
        let addParticipantInput = AddParticipantsRequestModel(contactIds: theContacts,
                                                              threadId: theThreadId,
                                                              typeCode: typeCode,
                                                              uniqueId: requestUniqueId)
        
        Chat.sharedInstance.addParticipants(inputModel: addParticipantInput, uniqueId: { (addParticipantsUniqueId) in
            print("uniqueId = \(addParticipantsUniqueId)")
            self.uniqueIdCallback?(addParticipantsUniqueId)
        }, completion: { (addParticipantServerResponse) in
            self.responseCallback?(addParticipantServerResponse as! AddParticipantModel)
        })
        
    }
    
    
    func sendRequestSenario(contactId: String?, threadId: Int?, contacts: [Int]?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- add contact to this thread
        // 4- send request
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactId, threadId, contacts) {
            case (.none, .none, .none):                 self.addContact()
            case let (.some(id), .none, .none):         self.createThread(withContactId: id)
            case let (_ , .some(id), .none):            self.addContactToThread(threadId: id)
            case let (_ , .some(id), .some(cntcts)):    self.sendRequest(theContacts: cntcts, theThreadId: id)
            case (_, .none, .some(_)):                  print("wrong situation")
            }
        }
        
    }
    
    
    func addContact() {
        // 1
        let sara = Faker.sharedInstance.SaraAsContacts
        let addContact = AddContactAutomation(cellphoneNumber: sara.cellphoneNumber, email: sara.email, firstName: sara.firstName, lastName: sara.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contact id = \(id).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: "\(id)", threadId: nil, contacts: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "there is no id when addContact with this user (firstName = \(sara.firstName) , cellphoneNumber = \(sara.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(sara.firstName) , cellphoneNumber = \(sara.cellphoneNumber) , lastName = \(sara.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withContactId contactId: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(contactId)", idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description:      fakeParams.description,
                                                  image:            nil,
                                                  invitees:         [myInvitee],
                                                  metadata:         nil,
                                                  title:            fakeParams.title,
                                                  uniqueName:       nil,
                                                  type:             ThreadTypes.OWNER_GROUP,
                                                  requestUniqueId:  nil)
        var i = ""
        for item in createThread.invitees! {
            i.append("\(item.formatToJSON()) ,")
        }
        delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "try to create new PublicGroup thread with this parameters: \n description = \(createThread.description!),\n invitees = \(i),\n title = \(createThread.title!),\n type = \(createThread.type!)", lineNumbers: 6)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                
                self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id, contacts: nil)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    // 3
    func addContactToThread(threadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "try to add new contact to this new threadId: \(threadId)", lineNumbers: 2)
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { (_) in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.AddParticipant.rawValue, message: "New Contact has been created, now try to add this contact id: \(id) to the thread \(threadId)", lineNumbers: 1)
                    self.sendRequestSenario(contactId: nil, threadId: threadId, contacts: [id])
                    
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
