//
//  LeaveThreadAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
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
    typealias callbackServerResponseTypeAlias   = (ThreadModel) -> ()
    
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
        
        sendRequestSenario(contactCellPhone: nil, threadId: threadId)
//        if let id = threadId {
//            sendRequest(theThreadId: id)
//        } else {
//            sendRequestSenario(contactCellPhone: nil, threadId: nil)
//        }
    }
    
    func sendRequest(theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "send Request to leaveThread with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
        let leaveThreadInput = LeaveThreadRequestModel(content: nil,
                                                       threadId: theThreadId,
                                                       typeCode: typeCode,
                                                       uniqueId: requestUniqueId)
        
        Chat.sharedInstance.leaveThread(leaveThreadInput: leaveThreadInput, uniqueId: { (leaveThreadUniqueId) in
//        myChatObject?.leaveThread(leaveThreadInput: leaveThreadInput, uniqueId: { (leaveThreadUniqueId) in
            self.uniqueIdCallback?(leaveThreadUniqueId)
        }, completion: { (leaveThreadServerResponseModel) in
            self.responseCallback?(leaveThreadServerResponseModel as! ThreadModel)
        })
        
    }
    
    
    func sendRequestSenario(contactCellPhone: String?, threadId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- leaveThread
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactCellPhone, threadId) {
            case    (.none, .none):
                self.addContact()
                
            case let (.some(cellPhone), .none):
                self.createThread(withCellphoneNumber: cellPhone)
                
            case let (_ , .some(id)):
                self.sendRequest(theThreadId: id)
            }
        }
        
    }
    
    
    func addContact() {
        // 1
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    self.delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    self.sendRequestSenario(contactCellPhone: cellphoneNumber, threadId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.LeaveThread.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withCellphoneNumber cellphoneNumber: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
        let createThread = CreateThreadAutomation(description: fakeParams.description,
                                                  image: nil,
                                                  invitees: [myInvitee],
                                                  metadata: nil,
                                                  title: fakeParams.title,
                                                  type: nil,
                                                  requestUniqueId: nil)
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
