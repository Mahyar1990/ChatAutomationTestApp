//
//  UnblockAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/14/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

//import PodChat
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
        
        switch (blockId, contactId, userId, threadId) {
        case let (.some(bId), _, _, _):     sendRequest(theBlockId: bId, theContactId: nil, theUserId: nil, theThreadId: nil, isAutomation: false)
        case let (_, .some(cId), _, _):     sendRequest(theBlockId: nil, theContactId: cId, theUserId: nil, theThreadId: nil, isAutomation: false)
        case let ( _, _, .some(uId), _):    sendRequest(theBlockId: nil, theContactId: nil, theUserId: uId, theThreadId: nil, isAutomation: false)
        case let (_, _, _, .some(tId)):     sendRequest(theBlockId: nil, theContactId: nil, theUserId: nil, theThreadId: tId, isAutomation: false)
        default:
            delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "there is no id to unblock, so we have to implement all the possible cases to unblock", lineNumbers: 2)
            unblockSenario(withBlockId: nil, withContactId: nil, withUserId: nil, withThreadId: nil)
        }
        
    }
    
    
    func sendRequest(theBlockId: Int?, theContactId: Int?, theUserId: Int?, theThreadId: Int?, isAutomation: Bool) {
        
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "send Request to Unblock with this params:\nblockId = \(theBlockId ?? 0) , contactId = \(theContactId ?? 0) , threadId = \(theThreadId ?? 0) , typeCode = \(typeCode ?? "nil") , userId = \(theUserId ?? 0)", lineNumbers: 2)
        
        let unblockInput = UnblockContactsRequestModel(blockId: theBlockId, contactId: theContactId, threadId: theThreadId, userId: theUserId, requestTypeCode: typeCode, requestUniqueId: nil)
        
        Chat.sharedInstance.unblockContact(unblockContactsInput: unblockInput, uniqueId: { (unblockUniqueId) in
            self.uniqueIdCallback?(unblockUniqueId)
        }, completion: { (unblockResponse) in
            self.responseCallback?(unblockResponse as! BlockedContactModel)
            if isAutomation {
                switch (theBlockId, theContactId, theUserId, theThreadId) {
                case let (.some(id), .none, .none, .none):  self.unblockSenario(withBlockId: id, withContactId: nil, withUserId: nil, withThreadId: nil)
                case let (.none, .some(id), .none, .none):  self.unblockSenario(withBlockId: nil, withContactId: id, withUserId: nil, withThreadId: nil)
                case let (.none, .none, .some(id), .none):  self.unblockSenario(withBlockId: nil, withContactId: nil, withUserId: id, withThreadId: nil)
                default: return
                }
            }
        })
        
    }
    
    
    func unblockSenario(withBlockId: Int?, withContactId: Int?, withUserId: Int?, withThreadId: Int?) {
        switch (withBlockId, withContactId, withUserId, withThreadId) {
        case (.none, .none, .none, .none):      addContactThenBlock(withContactId: false, withUserId: false, withThreadId: false)
        case (.some(_), .none, .none, .none):   addContactThenBlock(withContactId: true, withUserId: false, withThreadId: false)
        case (.none, .some(_), .none, .none):   addContactThenBlock(withContactId: false, withUserId: true, withThreadId: false)
        case (.none, .none, .some(_), .none):   addContactThenBlock(withContactId: false, withUserId: false, withThreadId: true)
        default: return
        }
    }
    
    
}



extension UnblockAutomation {
    
    func addContactThenBlock(withContactId: Bool, withUserId: Bool, withThreadId: Bool) {
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "try to add contact, then block it with \(withContactId ? "ContactId" : (withUserId ? "UserId" : (withThreadId) ? "threadId" : "blockId"))!!", lineNumbers: 1)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                
                switch (withContactId, withUserId, withThreadId) {
                    
                case (false, false, false):
                    if let id = myContact.id {
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, contact id = \(id)", lineNumbers: 1)
                        self.blockWith(contactId: id, userId: nil, threadId: nil, needBlockList: true)
                    } else {
                        // handle error that the contact doesn't have id!!!!!
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "the contact doesn't have id", lineNumbers: 1)
                    }
                    
                case (true, false, false):
                    if let id = myContact.id {
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, contact id = \(id)", lineNumbers: 1)
                        self.blockWith(contactId: id, userId: nil, threadId: nil, needBlockList: false)
                    } else {
                        // handle error that the contact doesn't have id!!!!!
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "the contact doesn't have id", lineNumbers: 1)
                    }
                    
                case (false, true, false):
                    let getContactRequestInputs = GetContactsRequestModel(count: 1, offset: 0, query: mehdi.firstName, requestTypeCode: nil, requestUniqueId: nil)
                    self.getContact(withInput: getContactRequestInputs) { (contact) in
                        if let id = contact.userId {
                            self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, user id = \(id)", lineNumbers: 1)
                            self.blockWith(contactId: myContact.id, userId: id, threadId: nil, needBlockList: false)
                        } else {
                            // handle error that the contact doesn't have UserId
                            self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "Error: this contact doesn't have UserId!!", lineNumbers: 1)
                        }
                    }
                    
//                    if let id = myContact.linkedUser?.coreUserId {
//                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new conract has been created, user id = \(id)", lineNumbers: 1)
//                        self.blockWith(contactId: myContact.id, userId: id, threadId: nil, needBlockList: false)
//                    } else {
//                        // handle error that the contact doesn't have linkedUser, or coreUserId
//                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "the contact doesn't have linkedUser, or coreUserId in its Model", lineNumbers: 1)
//                    }
                    
                case (false, false, true):
                    if let cellphoneNumber = myContact.cellphoneNumber {
                        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
                        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: nil, requestUniqueId: nil)
                        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
                            if let threadId = createThreadModel.thread?.id {
                                self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new Thread has been created, threadId = \(threadId)", lineNumbers: 1)
                                
                                self.blockWith(contactId: nil, userId: nil, threadId: threadId, needBlockList: false)
                            }
                        })
                    } else {
                        // handle error that didn't get contact id in the contact model
                        self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                    }
                    
                default: return
                }
                
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "there is no Contact Model on response", lineNumbers: 1)
            }
        }
    }
    
    private func getContact(withInput requestModel: GetContactsRequestModel, completion: @escaping (Contact)->() ) {
        Chat.sharedInstance.getContacts(getContactsInput: requestModel, uniqueId: { (_) in
        }, completion: { (cotactM) in
            let contactModel = cotactM as! GetContactsModel
            if let firstContact = contactModel.contacts.first {
                completion(firstContact)
            }
        }) { (_) in }
    }
    
    
    func blockWith(contactId: Int?, userId: Int?, threadId: Int?, needBlockList: Bool) {
        
        switch (contactId, userId, threadId) {
        case let (.some(contact), .none, .none):
            delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new try to block contact with contactId = \(contact)", lineNumbers: 1)
            let block = BlockAutomation(contactId: contact, threadId: nil, typeCode: typeCode, userId: nil)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "contact has been blocked", lineNumbers: 1)
                if needBlockList {
                    self.getBlockList()
                } else {
                    self.sendRequest(theBlockId: nil, theContactId: contact, theUserId: nil, theThreadId: nil, isAutomation: true)
                }
            }
        
        case let (.some(contact), .some(user), .none):
            delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new try to block contact with userId = \(user)", lineNumbers: 1)
            let block = BlockAutomation(contactId: contact, threadId: nil, typeCode: typeCode, userId: nil)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                self.sendRequest(theBlockId: nil, theContactId: nil, theUserId: user, theThreadId: nil, isAutomation: true)
            }
        
        case let (.none, .none, .some(thread)):
            delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "new try to block the threadId = \(thread)", lineNumbers: 1)
            let block = BlockAutomation(contactId: nil, threadId: thread, typeCode: typeCode, userId: nil)
            block.create(uniqueId: { _ in }) { (blockedContactModel) in
                self.sendRequest(theBlockId: nil, theContactId: nil, theUserId: nil, theThreadId: thread, isAutomation: true)
            }
            
        
        default: return
        }
        
    }
    
    func getBlockList() {
        delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "send request to get block list", lineNumbers: 1)
        let getBlockLists = GetBlockedListAutomation(count: 1, offset: 0, typeCode: nil)
        getBlockLists.create(uniqueId: { _ in}) { (getBlockedContactListModel) in
            if let blockedContact = getBlockedContactListModel.blockedList.first {
                if let blockId = blockedContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "got the block id (\(blockId)) from the GetBlockList Request", lineNumbers: 2)
                    self.sendRequest(theBlockId: blockId, theContactId: nil, theUserId: nil, theThreadId: nil, isAutomation: true)
                } else {
                    // handle error that the blocked Model doesn't have id !!!
                    self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "the blocked Model doesn't have id !!!", lineNumbers: 1)
                }
            } else {
                // handle error that there is no block object on the server response
                self.delegate?.newInfo(type: MoreInfoTypes.Unblock.rawValue, message: "there is no objec in the blockedList array!", lineNumbers: 1)
            }
        }
    }
    
}

