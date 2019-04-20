//
//  BlockAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK

public typealias completionTypeAlias = ((Bool) -> ())?

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
//            blockWith(contactId: myContactId, completion: nil)
        } else if let myThreadId = threadId {
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block with thread id = \(myThreadId)", lineNumbers: 1)
            blockWith(threadId: myThreadId)
//            blockWith(threadId: myThreadId, completion: nil)
        } else if let myUserId = userId {
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block with user id = \(myUserId)", lineNumbers: 1)
            blockWith(userId: myUserId)
//            blockWith(userId: myUserId, completion: nil)
        } else {
             /*
                if we come here, it means tha the caller, didn't set any contact or thread to block
                so we test all the posibilities of varios block contact and block thread
               */
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block id didn't specify! so try all the posibilities", lineNumbers: 1)
            
//            addContactThenBlockWithContactId { (_) in
//                self.addContactThenBlockWithUserId(completion: { (_) in
//                    self.addContactThenCreateThreadWithItThenBlockIt(completion: nil)
//                })
//            }
            
            addContactThenBlockWithContactId()
            addContactThenBlockWithUserId()
            addContactThenCreateThreadWithItThenBlockIt()
            
        }
        
    }
    
    
    func sendRequest(theContactId: Int?, theThreadId: Int?, theTypeCode: String?, theUserId: Int?) {
//    func sendRequest(theContactId: Int?, theThreadId: Int?, theTypeCode: String?, theUserId: Int?, completion: completionTypeAlias) {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "send block request with this parameters:\ncontactId = \(theContactId ?? 0) , threadId = \(theThreadId ?? 0) , typeCode = \(theTypeCode ?? "nil") , userId = \(theUserId ?? 0)", lineNumbers: 2)
        
        let blockContactInput = BlockContactsRequestModel(contactId: theContactId, threadId: theThreadId, typeCode: theTypeCode, userId: theUserId)
        myChatObject?.blockContact(blockContactsInput: blockContactInput, uniqueId: { (blockContactUniqueId) in
//            self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block Contact UniqueId response = \(blockContactUniqueId)", lineNumbers: 1)
            self.uniqueIdCallback?(blockContactUniqueId)
        }, completion: { (blockContactResponse) in
//            self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block contact response = \((blockContactResponse as! BlockedContactModel).returnDataAsJSON())", lineNumbers: 4)
            self.responseCallback?(blockContactResponse as! BlockedContactModel)
//            completion?(true)
        })
        
    }
    
    
    func addContactThenBlockWithContactId() {
//    func addContactThenBlockWithContactId(completion: completionTypeAlias) {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then block it with contactId!!", lineNumbers: 1)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: nil, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, contact id = \(id)", lineNumbers: 1)
                    
                    self.blockWith(contactId: id)
//                    self.blockWith(contactId: id, completion: { (status) in
//                        completion?(status)
//                    })
//                    self.blockWith(contactId: id)
                    
                } else {
//                    completion?(false)
                    // handle error that the contact doesn't have id!!!!!
                }
            } else {
//                completion?(false)
                // handle error that didn't add Contact Model
            }
        }
    }
    
    func addContactThenBlockWithUserId() {
//    func addContactThenBlockWithUserId(completion: completionTypeAlias) {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then block it with userId!!", lineNumbers: 1)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: nil, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.linkedUser?.coreUserId {
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, user id = \(id)", lineNumbers: 1)
                    
                    self.blockWith(userId: id)
//                    self.blockWith(userId: id, completion: { (status) in
//                        completion?(status)
//                    })
//                    self.blockWith(userId: id)
                    
                } else {
//                    completion?(false)
                    // handle error that the contact doesn't have linkedUser, or coreUserId
                }
            } else {
//                completion?(false)
                // handle error that didn't add Contact Model
            }
        }
    }


    func addContactThenCreateThreadWithItThenBlockIt() {
//    func addContactThenCreateThreadWithItThenBlockIt(completion: completionTypeAlias) {
        
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then create thread with this contact, then block this threadId!!", lineNumbers: 1)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: nil, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, and now it's time to create thread with contactId = \(id)", lineNumbers: 1)
                    
                    let invitee = Invitee(id: "\(id)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID.rawValue)")
                    let createThread = CreateThreadAutomation(description: "new thread", image: nil, invitees: [invitee], metadata: nil, title: "Thread", type: ThreadTypes.NORMAL.rawValue, requestUniqueId: nil)
                    createThread.create(uniqueId: { _,_  in }, serverResponse: { (createThreadModel, _ )  in
                        if let threadId = createThreadModel.thread?.id {
                            
                            self.blockWith(threadId: threadId)
//                            self.blockWith(threadId: threadId, completion: { (status) in
//                                completion?(status)
//                            })
//                            self.blockWith(threadId: threadId)
                            
                        } else {
//                            completion?(false)
                            // handle error that the create thread model, doesn't have thread in it, or id in the thread model!
                        }
                    })
                    
                } else {
//                    completion?(false)
                    // handle error that the contact doesn't have id!!!!!
                }
            } else {
//                completion?(false)
                // handle error that didn't add Contact Model
            }
        }
        
        
    }
    
    
    func blockWith(contactId: Int) {
//    func blockWith(contactId: Int, completion: completionTypeAlias) {
//        sendRequest(theContactId: contactId, theThreadId: nil, theTypeCode: typeCode, theUserId: nil) { (status) in
//            completion?(status)
//        }
        
        sendRequest(theContactId: contactId, theThreadId: nil, theTypeCode: typeCode, theUserId: nil)
    }
    
    func blockWith(threadId: Int) {
//    func blockWith(threadId: Int, completion: completionTypeAlias) {
//        sendRequest(theContactId: nil, theThreadId: threadId, theTypeCode: typeCode, theUserId: nil) { (status) in
//            completion?(status)
//        }
        
        sendRequest(theContactId: nil, theThreadId: threadId, theTypeCode: typeCode, theUserId: nil)
    }
    
    func blockWith(userId: Int) {
//    func blockWith(userId: Int, completion: completionTypeAlias) {
//        sendRequest(theContactId: nil, theThreadId: nil, theTypeCode: typeCode, theUserId: userId) { (status) in
//            completion?(status)
//        }
        
        sendRequest(theContactId: nil, theThreadId: nil, theTypeCode: typeCode, theUserId: userId)
    }
    
}
