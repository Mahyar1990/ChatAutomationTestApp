//
//  CreateThreadWithMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
import SwiftyJSON

/*
 
 */
class CreateThreadWithMessageAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let description:    String?
    let image:          String?
    let invitees:       [Invitee]?
    let messageText:    String?
    let metadata:       String?
    let title:          String?
    let type:           String?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias                   = (String) -> ()
    typealias callbackServerThreadResponseTypeAlias     = (CreateThreadModel) -> ()
    typealias callbackServerMessageResponseTypeAlias    = (JSON) -> ()
    
    private var uniqueIdCallback:           callbackStringTypeAlias?
    private var completionResponseCallback: callbackServerThreadResponseTypeAlias?
    private var serverSentResponse:         callbackServerMessageResponseTypeAlias?
    private var serverDeliverResponse:      callbackServerMessageResponseTypeAlias?
    private var serverSeenResponse:         callbackServerMessageResponseTypeAlias?
    
    init(description: String?, image: String?, invitees: [Invitee]?, messageText: String?, metadata: String?, title: String?, type: String?, requestUniqueId: String?) {
        
        self.description        = description
        self.image              = image
        self.invitees           = invitees
        self.messageText        = messageText
        self.metadata           = metadata
        self.title              = title
        self.type               = type
        self.requestUniqueId    = requestUniqueId
    }
    
    
    func create(uniqueId:               @escaping callbackStringTypeAlias,
                serverResponse:         @escaping callbackServerThreadResponseTypeAlias,
                serverSentResponse:     @escaping callbackServerMessageResponseTypeAlias,
                serverDeliverResponse:  @escaping callbackServerMessageResponseTypeAlias,
                serverSeenResponse:     @escaping callbackServerMessageResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.completionResponseCallback     = serverResponse
        self.serverSentResponse             = serverSentResponse
        self.serverDeliverResponse          = serverDeliverResponse
        self.serverSeenResponse             = serverSeenResponse
        
        // if the input parameter didn't filled by the user, first add a contact, then create a thread with this contact
        if ((invitees == nil) || (invitees?.count == 0)) {
            delegate?.newInfo(type: MoreInfoTypes.CreateThreadWithMessage.rawValue, message: "there is no invitee or title specify to creat thread, so have to implement all the possible cases to create a thread!!", lineNumbers: 2)
            addContactThenCreateThread()
            
        } else {
            // some or all of the parameters are filled by the caller, so send request with this params
            if (title != nil) && (invitees != nil) {
                let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                sendRequest(withDescription: description ?? fakeParams.description, withInvitees: invitees!, withTitle: title ?? fakeParams.title, withType: type ?? fakeParams.type, withMessage: messageText ?? fakeParams.message)
            } else {
                // handle that you should fill all these 2 items: title , invitees
                delegate?.newInfo(type: MoreInfoTypes.CreateThreadWithMessage.rawValue, message: "'title' and 'invitees' are empty. you should fill both of these items", lineNumbers: 1)
            }
        }
    }
    
    
    
    
    func sendRequest(withDescription: String?, withInvitees: [Invitee], withTitle: String, withType: String, withMessage: String) {
        
        var i = ""
        for item in withInvitees {
            i.append("\(item.formatToJSON()) ,")
        }
        
        delegate?.newInfo(type: MoreInfoTypes.CreateThreadWithMessage.rawValue, message: "send create thread with Message request with this parameters:\n message = \(withMessage), description = \(withDescription ?? "nil") , image = \(self.image ?? "nil") , invitees = \(i) , metadata = \(self.metadata ?? "nil") , title = \(withTitle) , type = \(withType) , requestUniqueId = \(self.requestUniqueId ?? "nil")", lineNumbers: 4)
        
        let createThreadWithMessageInput = CreateThreadWithMessageRequestModel(threadDescription: withDescription,
                                                                               threadImage: self.image,
                                                                               threadInvitees: withInvitees,
                                                                               threadMetadata: self.metadata,
                                                                               threadTitle: withTitle,
                                                                               threadType: withType,
                                                                               uniqueId: self.requestUniqueId,
                                                                               messageContent: "This is The Message Text",
                                                                               messageMetaDataId: nil,
                                                                               messageMetaDataType: nil,
                                                                               messageMetaDataOwner: nil)
        
            myChatObject?.creatThreadWithMessage(creatThreadWithMessageInput: createThreadWithMessageInput, uniqueId: { (createThreadWithMessageUniqueId) in
                self.uniqueIdCallback?(createThreadWithMessageUniqueId)
            }, completion: { (createThreadModel) in
                self.completionResponseCallback?(createThreadModel as! CreateThreadModel)
            }, onSent: { (sent) in
                self.serverSentResponse?(sent as! JSON)
            }, onDelivere: { (deliver) in
                self.serverDeliverResponse?(deliver as! JSON)
            }, onSeen: { (seen) in
                self.serverSeenResponse?(seen as! JSON)
            })
        
    }
    
    
    
    
}


extension CreateThreadWithMessageAutomation {
    
    func addContactThenCreateThread() {
        let pouria = Faker.sharedInstance.pouriaAsContact
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: pouria.email, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThreadWithMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contact Id = \(id).", lineNumbers: 2)
                    
                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                    let myInvitee = Invitee(id: "\(id)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID)")
                    self.sendRequest(withDescription: fakeParams.description, withInvitees: [myInvitee], withTitle: fakeParams.title, withType: fakeParams.type, withMessage: fakeParams.message)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThreadWithMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThreadWithMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber) , lastName = \(pouria.lastName)", lineNumbers: 2)
            }
        }
    }
    
}


