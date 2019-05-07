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
        
        switch (blockId, contactId, threadId, userId) {
        case let (.some(bId), _, _, _):
            sendRequest(theBlockId: bId, theContactId: nil, theThreadId: nil, theUserId: nil, isAutomation: false)
        case let (_, .some(cId), _, _):
            sendRequest(theBlockId: nil, theContactId: cId, theThreadId: nil, theUserId: nil, isAutomation: false)
        case let ( _, _, .some(tId), _):
            sendRequest(theBlockId: nil, theContactId: nil, theThreadId: tId, theUserId: nil, isAutomation: false)
        case let (_, _, _, .some(uId)):
            sendRequest(theBlockId: nil, theContactId: nil, theThreadId: nil, theUserId: uId, isAutomation: false)
        default:
            unblockSenario(withBlockId: nil, withContactId: nil, withThreadId: nil, withUserId: nil)
        }
        
//        if let block = blockId {
//            sendRequest(theBlockId: block, theContactId: nil, theThreadId: nil, theUserId: nil)
//        } else if let contact = contactId {
//            sendRequest(theBlockId: nil, theContactId: contact, theThreadId: nil, theUserId: nil)
//        } else if let thread = threadId {
//            sendRequest(theBlockId: nil, theContactId: nil, theThreadId: thread, theUserId: nil)
//        } else if let user = userId {
//            sendRequest(theBlockId: nil, theContactId: nil, theThreadId: nil, theUserId: user)
//        } else {
//            addContactAndBlockItWithContactId()
//            addContactAndBlockItWithUserId()
//            createThreadAndBlockIt()
//        }
        
        
    }
    
    
    func sendRequest(theBlockId: Int?, theContactId: Int?, theThreadId: Int?, theUserId: Int?, isAutomation: Bool) {
        
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "send Request to Unblock with this params:\nblockId = \(theBlockId ?? 0) , contactId = \(theContactId ?? 0) , threadId = \(theThreadId ?? 0) , typeCode = \(typeCode ?? "nil") , userId = \(theUserId ?? 0)", lineNumbers: 2)
        
        let unblockInput = UnblockContactsRequestModel(blockId: theBlockId, contactId: theContactId, threadId: theThreadId, typeCode: typeCode, userId: theUserId)
        
        myChatObject?.unblockContact(unblockContactsInput: unblockInput, uniqueId: { (unblockUniqueId) in
            self.uniqueIdCallback?(unblockUniqueId)
        }, completion: { (unblockResponse) in
            self.responseCallback?(unblockResponse as! BlockedContactModel)
            if isAutomation {
                switch (theBlockId, theContactId, theThreadId, theUserId) {
                case let (.some(id), .none, .none, .none):
                    self.unblockSenario(withBlockId: id, withContactId: nil, withThreadId: nil, withUserId: nil)
                case let (.none, .some(id), .none, .none):
                    self.unblockSenario(withBlockId: nil, withContactId: id, withThreadId: nil, withUserId: nil)
                case let (.none, .none, .some(id), .none):
                    self.unblockSenario(withBlockId: nil, withContactId: nil, withThreadId: id, withUserId: nil)
                default: return
                }
            }
        })
        
    }
    
    
    func unblockSenario(withBlockId: Int?, withContactId: Int?, withThreadId: Int?, withUserId: Int?) {
        switch (withBlockId, withContactId, withThreadId, withUserId) {
        case (.none, .none, .none, .none):      createContactAndBlockItThenUnblockWithBlockId()
        case (.some(_), .none, .none, .none):   addContactThenBlock(withContactId: true, withThreadId: false, withUserId: false)
        case (.none, .some(_), .none, .none):   addContactThenBlock(withContactId: false, withThreadId: true, withUserId: false)
        case (.none, .none, .some(_), .none):   addContactThenBlock(withContactId: false, withThreadId: false, withUserId: true)
        default: return
        }
    }
    
    func createContactAndBlockItThenUnblockWithBlockId() {
        
    }
    
    func addContactThenBlock(withContactId: Bool, withThreadId: Bool, withUserId: Bool) {
        
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "try to add contact, then block it with contactId!!", lineNumbers: 1)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: pouria.email, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                
                switch (withContactId, withUserId, withThreadId) {
                case (true, false, false):
                    if let id = myContact.id {
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, contact id = \(id)", lineNumbers: 1)
                        self.blockWith(contactId: id, threadId: nil, userId: nil)
                    } else {
                        // handle error that the contact doesn't have id!!!!!
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "the contact doesn't have id", lineNumbers: 1)
                    }
                    
                case (false, true, false):
                    if let id = myContact.linkedUser?.id {
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, user id = \(id)", lineNumbers: 1)
                        self.blockWith(contactId: nil, threadId: nil, userId: id)
                    } else {
                        // handle error that the contact doesn't have linkedUser, or coreUserId
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "the contact doesn't have linkedUser, or coreUserId in its Model", lineNumbers: 1)
                    }
                    
                case (false, false, true):
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
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber))!", lineNumbers: 2)
                    }
                    
                default: return
                }
                
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "there is no Contact Model on response", lineNumbers: 1)
            }
        }
    }
    
    
    
    func blockWith(contactId: Int?, threadId: Int?, userId: Int?) {
        
        switch (contactId, threadId, userId) {
        case let (.some(contact), .none, .none):
            let block = BlockAutomation(contactId: contact, threadId: nil, typeCode: typeCode, userId: nil)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                if let blockId = blockedContactModel.blockedContact.id {
                    self.sendRequest(theBlockId: nil, theContactId: blockId, theThreadId: nil, theUserId: nil, isAutomation: true)
                }
            }
            
        case let (.none, .some(thread), .none):
            let block = BlockAutomation(contactId: nil, threadId: thread, typeCode: typeCode, userId: nil)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                if let blockId = blockedContactModel.blockedContact.id {
                    self.sendRequest(theBlockId: nil, theContactId: nil, theThreadId: blockId, theUserId: nil, isAutomation: true)
                }
            }
            
        case let (.none, .none, .some(user)):
            let block = BlockAutomation(contactId: nil, threadId: nil, typeCode: typeCode, userId: user)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                if let blockId = blockedContactModel.blockedContact.id {
                    self.sendRequest(theBlockId: nil, theContactId: nil, theThreadId: nil, theUserId: blockId, isAutomation: true)
                }
            }
            
        default: return
        }
        
        
    }
    
}
