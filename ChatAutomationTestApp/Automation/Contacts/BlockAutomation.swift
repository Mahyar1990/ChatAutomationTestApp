//
//  BlockAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK


class BlockAutomation {
    
    let contactId:  Int?
    let threadId:   Int?
    let typeCode:   String?
    let userId:     Int?
    
    typealias callbackStringTypeAlias            = (String) -> ()
    typealias callbackServerResponseTypeAlias    = (BlockedContactModel) -> ()
    
    private var uniqueIdCallback: callbackStringTypeAlias?
    private var responseCallback: callbackServerResponseTypeAlias?
    
    
    init(contactId: Int?, threadId: Int?, typeCode: String?, userId: Int) {
        
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
            blockWith(contactId: myContactId)
        } else if let myThreadId = threadId {
            blockWith(threadId: myThreadId)
        } else if let myUserId = userId {
            blockWith(userId: myUserId)
        } else {
             /*
                if we come here, it means tha the caller, didn't set any contact or thread to block
                so we test all the posibilities of varios block contact and block thread
               */
            
            addContactThenBlockWithContactId()
            addContactThenBlockWithUserId()
            addContactThenCreateThreadWithItThenBlockIt()
            
        }
        
    }
    
    
    
    func sendRequest(theContactId: Int?, theThreadId: Int?, theTypeCode: String?, theUserId: Int?) {
        
        let blockContactInput = BlockContactsRequestModel(contactId: theContactId, threadId: theThreadId, typeCode: theTypeCode, userId: theUserId)
        myChatObject?.blockContact(blockContactsInput: blockContactInput, uniqueId: { (blockContactUniqueId) in
            self.uniqueIdCallback?(blockContactUniqueId)
        }, completion: { (blockContactResponse) in
            self.responseCallback?(blockContactResponse as! BlockedContactModel)
        })
        
    }
    
    
    
    func addContactThenBlockWithContactId() {
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
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
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.linkedUser?.coreUserId {
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
        
        let addContact = AddContactAutomation(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    let invitee = Invitee(id: "\(id)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID.rawValue)")
                    let createThread = CreateThreadAutomation(description: "new thread", image: nil, invitees: [invitee], metadata: nil, title: "Thread", type: ThreadTypes.NORMAL.rawValue, requestUniqueId: nil)
                    createThread.create(uniqueId: { _ in }, serverResponse: { (createThreadModel) in
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
