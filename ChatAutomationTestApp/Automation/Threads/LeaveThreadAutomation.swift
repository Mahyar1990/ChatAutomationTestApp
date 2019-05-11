//
//  LeaveThreadAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 LeaveThreadAutomation request will send
 */

class LeaveThreadAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let threadId:       Int?
    let typeCode:       String?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (CreateThreadModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(threadId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.requestUniqueId = requestUniqueId
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        if let id = threadId {
            sendRequest(theThreadId: id)
        } else {
            sendRequestSenario(contactCellPhone: nil, threadId: nil)
        }
    }
    
    func sendRequest(theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "send Request to leaveThread with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
        let leaveThreadInput = LeaveThreadRequestModel(content: nil,
                                                       threadId: theThreadId,
                                                       typeCode: typeCode,
                                                       uniqueId: requestUniqueId)
        myChatObject?.leaveThread(leaveThreadInput: leaveThreadInput, uniqueId: { (leaveThreadUniqueId) in
            self.uniqueIdCallback?(leaveThreadUniqueId)
        }, completion: { (leaveThreadServerResponseModel) in
            self.responseCallback?(leaveThreadServerResponseModel as! CreateThreadModel)
        })
        
    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- leaveThread
        
        switch (contactCellPhone, threadId) {
        case    (.none, .none):
            addContact()
            
        case let (.some(cellPhone), .none):
            createThread(withCellphoneNumber: cellPhone)
            
        case let (_ , .some(id)):
            self.sendRequest(theThreadId: id)
            
        }
    }
    
    
    func addContact() {
        // 1
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: pouria.email, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    self.delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber) , lastName = \(pouria.lastName)", lineNumbers: 2)
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
                self.delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactCellPhone: nil, threadId: id)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    
}
