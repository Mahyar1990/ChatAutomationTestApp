//
//  CreateThreadAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK

/*
 This method will create a thread with some specific users
 when calling this method,
 if the caller of this function filled the "invitees" and "title" -> then we create a thread with the ginven data
 else:
 we asume that we have to test every single situation to create thead including:
 addContact + create CHANNEL Thread with contact CellPhoneNumber (using TO_BE_USER_CELLPHONE_NUMBER)
 addContact + create CHANNEL_GROUP Thread with contact CellPhoneNumber (using TO_BE_USER_CELLPHONE_NUMBER)
 addContact + create OWNER_GROUP Thread with contact CellPhoneNumber (using TO_BE_USER_CELLPHONE_NUMBER)
 addContact + create PUBLIC_GROUP Thread with contact CellPhoneNumber (using TO_BE_USER_CELLPHONE_NUMBER)
 addContact + create NORMAL Thread with contact CellPhoneNumber (using TO_BE_USER_CELLPHONE_NUMBER)
 addContact + create NORMAL Thread with contact id (using TO_BE_USER_CONTACT_ID)
 addContact + create NORMAL Thread with contact linkeUser id (using TO_BE_USER_ID)
 addContact + create NORMAL Thread with contact linkeUser usename (using TO_BE_USER_USERNAME)
 */
class CreateThreadAutomation {
    
    let description:    String?
    let image:          String?
    let invitees:       [Invitee]?
    let metadata:       String?
    let title:          String?
    let type:           String?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias            = (String) -> ()
    typealias callbackServerResponseTypeAlias    = (CreateThreadModel) -> ()
    
    private var uniqueIdCallback: callbackStringTypeAlias?
    private var responseCallback: callbackServerResponseTypeAlias?
    
    init(description: String?, image: String?, invitees: [Invitee]?, metadata: String?, title: String?, type: String?, requestUniqueId: String?) {
        
        self.description        = description
        self.image              = image
        self.invitees           = invitees
        self.metadata           = metadata
        self.title              = title
        self.type               = type
        self.requestUniqueId    = requestUniqueId
    }
    
    
    func create(uniqueId: @escaping (String) -> (), serverResponse: @escaping (CreateThreadModel) -> ()) {
        
        self.uniqueIdCallback = uniqueId
        self.responseCallback = serverResponse
        
        // if the input parameter didn't filled by the user, first add a contact, then create a thread with this contact
        if (invitees == nil) && (title == nil) {
            
            createNormalThreadWithContactId(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            createNormalThreadWithId(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            createNormalThreadWithUsername(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            createNormalThreadWithCellPhoneNumber(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            createChannelThread(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            createChannelGroupThread(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            createOwnerGroup(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            createPublicGroup(cellphoneNumber: "09387181694", email: nil, firstName: "Pooria", lastName: "Pahlevani")
            
        }
            // some or all of the parameters are filled by the caller, so send request with this params
        else {
            
            if (title != nil) && (invitees != nil) {
                sendRequest(theDescription: description, theImage: image, theInvitees: invitees!, theMetadata: metadata, theTitle: title!, theType: type, theRequestUniqueId: requestUniqueId)
            } else {
                // handle that you should fill all these 2 items: title , invitees
            }
            
        }
        
    }
    
    
    
    
    func sendRequest(theDescription: String?, theImage: String?, theInvitees: [Invitee], theMetadata: String?, theTitle: String, theType: String?, theRequestUniqueId: String?) {
        
        let createThreadInput = CreateThreadRequestModel(description: theDescription, image: nil, invitees: theInvitees, metadata: nil, title: theTitle, type: theType, uniqueId: nil)
        myChatObject?.createThread(createThreadInput: createThreadInput, uniqueId: { (createThreadUniqueId) in
            self.uniqueIdCallback?(createThreadUniqueId)
        }, completion: { (createThreadModel) in
            self.responseCallback?(createThreadModel as! CreateThreadModel)
        })
        
    }
    
    
    /*
     first create a contact, in the response ContactModel there is parameter nameed "id"
     in the invitee model to pass to createThread, pass this "id" and type "TO_BE_USER_CONTACT_ID"
     */
    func createNormalThreadWithContactId(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    
                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                    let myInvitee = Invitee(id: "\(contactId)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID.rawValue)")
                    self.sendRequest(theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: fakeParams.type, theRequestUniqueId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }
        
    }
    
    /*
     first create a contact, then use it linkeUser model,
     insid linkeUser, there is parameter nameed "coreUserId"
     in the invitee model to pass to createThread, pass this "coreUserId" and type "TO_BE_USER_ID"
     */
    func createNormalThreadWithId(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if myContact.hasUser {
                    
                    if let linkeUser = myContact.linkedUser {
                        if let linkUserId = linkeUser.coreUserId {
                            let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                            let myInvitee = Invitee(id: "\(linkUserId)", idType: "\(InviteeVOidTypes.TO_BE_USER_ID.rawValue)")
                            self.sendRequest(theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: fakeParams.type, theRequestUniqueId: nil)
                        } else { // handle error that didn't get linkUserId in the linkedUser model of Contact
                        }
                        
                    } else { // handle error that didn't get linkUser model of Contact
                    }
                    
                } else { // this contact don't have linkeUser
                }
                
            } else { // handle error that didn't add Contact Model
            }
        }
        
    }
    
    /*
     this one needs user ssoId that has not implemented yet (how to get user ssoId)
     */
    func createNormalThreadWithSsoId() {
        
    }
    
    /*
     first create a contact, then use it linkeUser model,
     insid linkeUser, there is parameter nameed "username"
     in the invitee model to pass to createThread, pass this "username" and type "TO_BE_USER_USERNAME"
     */
    func createNormalThreadWithUsername(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if myContact.hasUser {
                    
                    if let linkeUser = myContact.linkedUser {
                        if let linkedUsername = linkeUser.username {
                            let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                            let myInvitee = Invitee(id: linkedUsername, idType: "\(InviteeVOidTypes.TO_BE_USER_USERNAME.rawValue)")
                            self.sendRequest(theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: fakeParams.type, theRequestUniqueId: nil)
                        } else { // handle error that didn't get linkUserId in the linkedUser model of Contact
                        }
                        
                    } else { // handle error that didn't get linkUser model of Contact
                    }
                    
                } else { // this contact don't have linkeUser
                }
                
            } else { // handle error that didn't add Contact Model
            }
        }
        
    }
    
    /*
     first create a contact, in the response ContactModel there is parameter nameed "cellphoneNumber"
     in the invitee model to pass to createThread, pass this "cellphoneNumber" and type "TO_BE_USER_CELLPHONE_NUMBER"
     */
    func createNormalThreadWithCellPhoneNumber(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        createContactWithPhoneNumberThenCreateThread(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.NORMAL.rawValue)
    }
    
    
    func createChannelThread(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        createContactWithPhoneNumberThenCreateThread(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.CHANNEL.rawValue)
    }
    
    func createChannelGroupThread(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        createContactWithPhoneNumberThenCreateThread(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.CHANNEL_GROUP.rawValue)
    }
    
    func createOwnerGroup(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        createContactWithPhoneNumberThenCreateThread(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.OWNER_GROUP.rawValue)
    }
    
    func createPublicGroup(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        createContactWithPhoneNumberThenCreateThread(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.PUBLIC_GROUP.rawValue)
    }
    
    func createContactWithPhoneNumberThenCreateThread(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?, threadType: String) {
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.cellphoneNumber {
                    
                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                    let myInvitee = Invitee(id: "\(contactId)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER.rawValue)")
                    self.sendRequest(theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: threadType, theRequestUniqueId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                }
            } else {
                // handle error that didn't add Contact Model
            }
            
        }
        
    }
    
    
    
    
}




