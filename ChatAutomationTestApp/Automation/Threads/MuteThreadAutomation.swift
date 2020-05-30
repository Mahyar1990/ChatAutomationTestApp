//
//  MuteThreadAutomation.swift
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
 MuteThreadAutomation request will send
 */

class MuteThreadAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let threadId:       Int?
    let typeCode:       String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (MuteUnmuteThreadModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(threadId: Int?, typeCode: String?) {
        
        self.threadId       = threadId
        self.typeCode       = typeCode
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        sendRequestSenario(contactId: nil, threadId: threadId)
    }
    
    func sendRequest(theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.MuteThread.rawValue, message: "send Request to MuteThread with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
        let muteThreadInput = MuteAndUnmuteThreadRequestModel(subjectId:    theThreadId,
                                                              typeCode:     typeCode,
                                                              uniqueId:     nil)
        
        Chat.sharedInstance.muteThread(inputModel: muteThreadInput, uniqueId: { (muteThreadUniqueId) in
            self.uniqueIdCallback?(muteThreadUniqueId)
        }, completion: { (muteThreadServerResponseModel) in
            self.responseCallback?(muteThreadServerResponseModel as! MuteUnmuteThreadModel)
        })
        
    }
    
    
    func sendRequestSenario(contactId: Int?, threadId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- muteThread
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (contactId, threadId) {
            case    (.none, .none):             self.addContact()
            case let (.some(cellPhone), .none): self.createThread(withContactId: cellPhone)
            case let (_ , .some(id)):           self.sendRequest(theThreadId: id)
            }
        }
        
    }
    
    
    func addContact() {
        // 1
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.MuteThread.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contactId = \(id).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: id, threadId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.MuteThread.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.MuteThread.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withContactId contactId: Int) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(contactId)", idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, uniqueName: nil, type: ThreadTypes.OWNER_GROUP, requestUniqueId: nil)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.MuteThread.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
}
