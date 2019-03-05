//
//  UnblockAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/14/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK

/*
 if somebody call this method,
 a Unblock request will send
 */

class UnblockAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    

    let blockId:    Int?
    let contactId:  Int?
    let threadId:   Int?
    let typeCode:   String?
    let userId:     Int?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (BlockedContactModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(blockId: Int?, contactId: Int?, threadId: Int?, typeCode: String?, userId: Int?) {
        
        self.blockId    = blockId
        self.contactId  = contactId
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.userId     = userId
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (BlockedContactModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let block = blockId {
            sendRequest(theBlockId: block, theContactId: nil, theThreadId: nil, theTypeCode: typeCode, theUserId: nil)
        } else if let contact = contactId {
            sendRequest(theBlockId: nil, theContactId: contact, theThreadId: nil, theTypeCode: typeCode, theUserId: nil)
        } else if let thread = threadId {
            sendRequest(theBlockId: nil, theContactId: nil, theThreadId: thread, theTypeCode: typeCode, theUserId: nil)
        } else if let user = userId {
            sendRequest(theBlockId: nil, theContactId: nil, theThreadId: nil, theTypeCode: typeCode, theUserId: user)
        } else {
            addContactAndBlockItWithContactId()
            addContactAndBlockItWithUserId()
            createThreadAndBlockIt()
        }
        
        
    }
    
    
    func sendRequest(theBlockId: Int?, theContactId: Int?, theThreadId: Int?, theTypeCode: String?, theUserId: Int?) {
        
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "send Request to Unblock with this params:\nblockId = \(theBlockId ?? 0) , contactId = \(theContactId ?? 0) , threadId = \(theThreadId ?? 0) , typeCode = \(theTypeCode ?? "nil") , userId = \(theUserId ?? 0)", lineNumbers: 2)
        
        let unblockInput = UnblockContactsRequestModel(blockId: theBlockId, contactId: theContactId, threadId: theThreadId, typeCode: theTypeCode, userId: theUserId)
        
        myChatObject?.unblockContact(unblockContactsInput: unblockInput, uniqueId: { (unblockUniqueId) in
//            self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "uniqueId = \(unblockUniqueId)", lineNumbers: 1)
            self.uniqueIdCallback?(unblockUniqueId)
        }, completion: { (unblockResponse) in
//            self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "server response = \(unblockResponse as! BlockedContactModel)", lineNumbers: 2)
            self.responseCallback?(unblockResponse as! BlockedContactModel)
        })
        
    }
    
    
    
    func addContactAndBlockItWithContactId() {
        
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "try to add contact, then block it with contactId!!", lineNumbers: 1)
        
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, contact id = \(id)", lineNumbers: 1)
                    self.blockWith(contactId: id, threadId: nil, userId: nil)
                } else {
                    // handle error that the contact doesn't have id!!!!!
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }
    }
    
    
    func addContactAndBlockItWithUserId() {
        
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "try to add contact, then block it with userId!!", lineNumbers: 1)
        
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.linkedUser?.coreUserId {
                    self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, user id = \(id)", lineNumbers: 1)
                    self.blockWith(contactId: nil, threadId: nil, userId: id)
                } else {
                    // handle error that the contact doesn't have linkedUser, or coreUserId
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }

    }
    
    
    func createThreadAndBlockIt() {
        
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "try to addContact, then create a thread with it, then block it", lineNumbers: 1)
        
        let cellphoneNumber = "09387181694"
        let firstName       = "Pooria"
        let lastName        = "Pahlevani"
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: nil, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    
                    let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
                    
                    let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
                    
                    createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
                        if let threadId = createThreadModel.thread?.id {
                            self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new Thread has been created, threadId = \(threadId)", lineNumbers: 1)
                            
                            self.blockWith(contactId: nil, threadId: threadId, userId: nil)
                        }
                    })
                
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(firstName) , cellphoneNumber = \(cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(firstName) , cellphoneNumber = \(cellphoneNumber) , lastName = \(lastName)", lineNumbers: 2)
            }
        }
        
        
    }
    
    
    
    
    func blockWith(contactId: Int?, threadId: Int?, userId: Int?) {
        
        if let contact = contactId {
            let block = BlockAutomation(contactId: contact, threadId: nil, typeCode: typeCode, userId: nil)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                if let blockId = blockedContactModel.blockedContact.id {
                    self.sendRequest(theBlockId: nil, theContactId: blockId, theThreadId: nil, theTypeCode: self.typeCode, theUserId: nil)
                }
            }
        } else if let thread = threadId {
            let block = BlockAutomation(contactId: nil, threadId: thread, typeCode: typeCode, userId: nil)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                if let blockId = blockedContactModel.blockedContact.id {
                    self.sendRequest(theBlockId: nil, theContactId: nil, theThreadId: blockId, theTypeCode: self.typeCode, theUserId: nil)
                }
            }
        } else if let user = userId {
            let block = BlockAutomation(contactId: nil, threadId: nil, typeCode: typeCode, userId: user)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                if let blockId = blockedContactModel.blockedContact.id {
                    self.sendRequest(theBlockId: nil, theContactId: nil, theThreadId: nil, theTypeCode: self.typeCode, theUserId: blockId)
                }
            }
        }
        
    }
    
}
