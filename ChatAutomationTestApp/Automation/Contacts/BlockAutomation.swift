//
//  BlockAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

//import PodChat
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
            sendRequest(theContactId: myContactId, theUserId: nil, theThreadId: nil, isAutomation: false)
        } else if let myUserId = userId {
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block with user id = \(myUserId)", lineNumbers: 1)
            sendRequest(theContactId: nil, theUserId: myUserId, theThreadId: nil, isAutomation: false)
        } else if let myThreadId = threadId {
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block with thread id = \(myThreadId)", lineNumbers: 1)
            sendRequest(theContactId: nil, theUserId: nil, theThreadId: myThreadId, isAutomation: false)
        } else {
             /*
                if we come here, it means tha the caller, didn't set any contact or thread to block
                so we test all the posibilities of varios block contact and block thread
               */
            delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "block id didn't specify! so try all the posibilities", lineNumbers: 1)
            sendRequestSenario(theContactId: nil, theUserId: nil, theThreadId: nil)
        }
        
    }
    
    
    func sendRequest(theContactId: Int?, theUserId: Int?, theThreadId: Int?, isAutomation: Bool) {
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "send block request with this parameters:\ncontactId = \(theContactId ?? 0) , threadId = \(theThreadId ?? 0) , typeCode = \(typeCode ?? "nil") , userId = \(theUserId ?? 0)", lineNumbers: 2)
        let blockContactInput = BlockContactsRequestModel(contactId: theContactId, threadId: theThreadId, userId: theUserId, requestTypeCode: typeCode, requestUniqueId: nil)
        
        Chat.sharedInstance.blockContact(blockContactsInput: blockContactInput, uniqueId: { (blockContactUniqueId) in
            self.uniqueIdCallback?(blockContactUniqueId)
        }, completion: { (blockContactResponse) in
            self.responseCallback?(blockContactResponse as! BlockedContactModel)
            if isAutomation {
                switch (theContactId, theUserId, theThreadId) {
                case let (.some(id),    .none, .none):      self.sendRequestSenario(theContactId: id, theUserId: nil, theThreadId: nil)
                case let (.none,        .none, .some(id)):  self.sendRequestSenario(theContactId: nil, theUserId: nil, theThreadId: id)
                default: return
                }
            }
            
        })
        
    }
    
    func sendRequestSenario(theContactId: Int?, theUserId: Int?, theThreadId: Int?) {
        switch (theContactId, theUserId, theThreadId) {
        case (.none,    .none, .none):      addContactThenBlockWithContactIdSenario(contactId: nil)
        case (.some(_), .none, .none):      addContactThenCreateThreadWithItThenBlockItSenario(threadId: nil)
        case (.none,    .none, .some(_)):   addContactThenBlockWithUserIdSenario(userId: nil)
        default:    return
        }
    }
    
}


// MARK: - Block with ContactId senario
extension BlockAutomation {
    func addContactThenBlockWithContactIdSenario(contactId: Int?) {
        if let cId = contactId {
            sendRequest(theContactId: cId, theUserId: nil, theThreadId: nil, isAutomation: true)
        } else {
            addContactAndGetContactId()
        }
    }
    
    func addContactAndGetContactId() {
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then block it with contactId!!", lineNumbers: 1)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: nil, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, contact id = \(id)", lineNumbers: 1)
                    self.addContactThenBlockWithContactIdSenario(contactId: id)
                } else {
                    // handle error that the contact doesn't have id!!!!!
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "Error: this contact doesn't have id!!", lineNumbers: 1)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "Error: didn't add Contact Model!!", lineNumbers: 1)
            }
        }
    }
}


// MARK: - Block with UserId senario
extension BlockAutomation {
    func addContactThenBlockWithUserIdSenario(userId: Int?) {
        if let uId = userId {
            sendRequest(theContactId: nil, theUserId: uId, theThreadId: nil, isAutomation: true)
        } else {
            addContactAndGetUserId()
        }
    }
    
    func addContactAndGetUserId() {
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then block it with userId!!", lineNumbers: 1)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: nil, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let _ = contactModel.contacts.first {
                let getContactRequestInputs = GetContactsRequestModel(count: 1, offset: 0, query: pouria.firstName, requestTypeCode: nil, requestUniqueId: nil)
                self.getContact(withInput: getContactRequestInputs) { (contact) in
                    if let id = contact.userId {
                        self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, user id = \(id)", lineNumbers: 1)
                        self.addContactThenBlockWithUserIdSenario(userId: id)
                    } else {
                        // handle error that the contact doesn't have UserId
                        self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "Error: this contact doesn't have UserId!!", lineNumbers: 1)
                    }
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "Error: didn't add Contact Model!!", lineNumbers: 1)
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
    
}


// MARK: - Block with ThreadId senario
extension BlockAutomation {
    func addContactThenCreateThreadWithItThenBlockItSenario(threadId: Int?) {
        if let tId = threadId {
            sendRequest(theContactId: nil, theUserId: nil, theThreadId: tId, isAutomation: true)
        } else {
            addContactAndGetContactIdToCreateThread()
        }
    }
    
    func addContactAndGetContactIdToCreateThread() {
        delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "try to add contact, then create thread with this contact, then block this threadId!!", lineNumbers: 1)
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: nil, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let phoneNumber = myContact.cellphoneNumber {
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new conract has been created, and now it's time to create thread with contact cellphoneNumber = \(phoneNumber)", lineNumbers: 1)
                    self.createThreadWith(cellPhoneNumber: phoneNumber)
                } else {
                    // handle error that the contact doesn't have id!!!!!
                    self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "Error: this contact doesn't have id!!", lineNumbers: 1)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "Error: didn't add Contact Model!!", lineNumbers: 1)
            }
        }
    }
    
    func createThreadWith(cellPhoneNumber: String) {
        let invitee = Invitee(id: cellPhoneNumber, idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
        let createThread = CreateThreadAutomation(description: "new thread", image: nil, invitees: [invitee], metadata: nil, title: "Thread", type: ThreadTypes.NORMAL, requestUniqueId: nil)
        createThread.create(uniqueId: { _,_  in }, serverResponse: { (createThreadModel, _ )  in
            if let myThreadId = createThreadModel.thread?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "new thread has been created, thread id = \(myThreadId)", lineNumbers: 1)
                self.addContactThenCreateThreadWithItThenBlockItSenario(threadId: myThreadId)
            } else {
                // handle error that the create thread model, doesn't have thread in it, or id in the thread model!
                self.delegate?.newInfo(type: MoreInfoTypes.Block.rawValue, message: "Error: the create thread model, doesn't have thread in it, or id in the thread model!!", lineNumbers: 2)
            }
        })
    }
    
}


