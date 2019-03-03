//
//  BlockAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK


class BlockAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let contactId:  Int?
    let threadId:   Int?
    let typeCode:   String?
    let userId:     Int?
    
    typealias callbackStringTypeAlias            = (String) -> ()
    typealias callbackServerResponseTypeAlias    = (BlockedContactModel) -> ()
    
    private var uniqueIdCallback: callbackStringTypeAlias?
    private var responseCallback: callbackServerResponseTypeAlias?
    
    
    init(contactId: Int?, threadId: Int?, typeCode: String?, userId: Int?) {
        
        self.contactId  = contactId
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.userId     = userId
    }
    
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (BlockedContactModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let myContactId = contactId {
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block with contact id = \(myContactId)", lineNumbers: 1)
            blockWith(contactId: myContactId)
        } else if let myThreadId = threadId {
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block with thread id = \(myThreadId)", lineNumbers: 1)
            blockWith(threadId: myThreadId)
        } else if let myUserId = userId {
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block with user id = \(myUserId)", lineNumbers: 1)
            blockWith(userId: myUserId)
        } else {
             /*
                if we come here, it means tha the caller, didn't set any contact or thread to block
                so we test all the posibilities of varios block contact and block thread
               */
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block id didn't specify! so try all the posibilities", lineNumbers: 1)
            
            addContactThenBlockWithContactId()
            addContactThenBlockWithUserId()
            addContactThenCreateThreadWithItThenBlockIt()
            
        }
        
    }
    
    
    
    func sendRequest(theContactId: Int?, theThreadId: Int?, theTypeCode: String?, theUserId: Int?) {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "send block request with this parameters:\ncontactId = \(theContactId ?? 0) , threadId = \(theThreadId ?? 0) , typeCode = \(theTypeCode ?? "nil") , userId = \(theUserId ?? 0)", lineNumbers: 2)
        
        let blockContactInput = BlockContactsRequestModel(contactId: theContactId, threadId: theThreadId, typeCode: theTypeCode, userId: theUserId)
        myChatObject?.blockContact(blockContactsInput: blockContactInput, uniqueId: { (blockContactUniqueId) in
//            self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block Contact UniqueId response = \(blockContactUniqueId)", lineNumbers: 1)
            self.uniqueIdCallback?(blockContactUniqueId)
        }, completion: { (blockContactResponse) in
//            self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block contact response = \((blockContactResponse as! BlockedContactModel).returnDataAsJSON())", lineNumbers: 4)
            self.responseCallback?(blockContactResponse as! BlockedContactModel)
        })
        
    }
    
    
    
    func addContactThenBlockWithContactId() {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then block it with contactId!!", lineNumbers: 1)
        
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, contact id = \(id)", lineNumbers: 1)
                    self.blockWith(contactId: id)
                } else {
                    // handle error that the contact doesn't have id!!!!!
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }
    }
    
    func addContactThenBlockWithUserId() {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then block it with userId!!", lineNumbers: 1)
        
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.linkedUser?.coreUserId {
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, user id = \(id)", lineNumbers: 1)
                    self.blockWith(userId: id)
                } else {
                    // handle error that the contact doesn't have linkedUser, or coreUserId
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }
    }
    
    func addContactThenCreateThreadWithItThenBlockIt() {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then create thread with this contact, then block this threadId!!", lineNumbers: 1)
        
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, and now it's time to create thread with contactId = \(id)", lineNumbers: 1)
                    
                    let invitee = Invitee(id: "\(id)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID.rawValue)")
                    let createThread = CreateThreadAutomation(description: "new thread", image: nil, invitees: [invitee], metadata: nil, title: "Thread", type: ThreadTypes.NORMAL.rawValue, requestUniqueId: nil)
                    createThread.create(uniqueId: { _,_  in }, serverResponse: { (createThreadModel, _ )  in
                        if let threadId = createThreadModel.thread?.id {
                            self.blockWith(threadId: threadId)
                        } else {
                            // handle error that the create thread model, doesn't have thread in it, or id in the thread model!
                        }
                    })
                    
                } else {
                    // handle error that the contact doesn't have id!!!!!
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }
        
        
    }
    
    
    func blockWith(contactId: Int) {
        sendRequest(theContactId: contactId, theThreadId: nil, theTypeCode: typeCode, theUserId: nil)
    }
    
    func blockWith(threadId: Int) {
        sendRequest(theContactId: nil, theThreadId: threadId, theTypeCode: typeCode, theUserId: nil)
    }
    
    func blockWith(userId: Int) {
        sendRequest(theContactId: nil, theThreadId: nil, theTypeCode: typeCode, theUserId: userId)
    }
    
}
