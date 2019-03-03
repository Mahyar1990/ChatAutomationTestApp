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
    
    public weak var delegate: MoreInfoDelegate?
    
    let description:    String?
    let image:          String?
    let invitees:       [Invitee]?
    let metadata:       String?
    let title:          String?
    let type:           String?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias            = (String, String) -> ()
    typealias callbackServerResponseTypeAlias    = (CreateThreadModel, String) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(description: String?, image: String?, invitees: [Invitee]?, metadata: String?, title: String?, type: String?, requestUniqueId: String?) {
        
        self.description        = description
        self.image              = image
        self.invitees           = invitees
        self.metadata           = metadata
        self.title              = title
        self.type               = type
        self.requestUniqueId    = requestUniqueId
    }
    
    
    func create(uniqueId: @escaping callbackStringTypeAlias, serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        // if the input parameter didn't filled by the user, first add a contact, then create a thread with this contact
        if (invitees == nil) && (title == nil) {
            
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "there is no invitee or title specify to creat thread, so have to implement all the possible cases to create a thread!!", lineNumbers: 2)
            
            createNormalThreadWithId(cellphoneNumber: "09148401824", email: nil, firstName: "Masoud", lastName: "Amjadi")
            createNormalThreadWithUsername(cellphoneNumber: "09368640180", email: nil, firstName: "Mehdi", lastName: "Akbarian")
            createNormalThreadWithCellPhoneNumber(cellphoneNumber: "09368640180", email: nil, firstName: "Mehdi", lastName: "Akbarian")
            createNormalThreadWithContactId(cellphoneNumber: "09368640180", email: nil, firstName: "Mehdi", lastName: "Akbarian")
            createChannelThread(cellphoneNumber: "09368640180", email: nil, firstName: "Mehdi", lastName: "Akbarian")
            createChannelGroupThread(cellphoneNumber: "09368640180", email: nil, firstName: "Mehdi", lastName: "Akbarian")
            createOwnerGroup(cellphoneNumber: "09368640180", email: nil, firstName: "Mehdi", lastName: "Akbarian")
            createPublicGroup(cellphoneNumber: "09368640180", email: nil, firstName: "Mehdi", lastName: "Akbarian")
            
        }
            // some or all of the parameters are filled by the caller, so send request with this params
        else {
            
            if (title != nil) && (invitees != nil) {
                sendRequest(on: "", theDescription: description, theImage: image, theInvitees: invitees!, theMetadata: metadata, theTitle: title!, theType: type, theRequestUniqueId: requestUniqueId)
            } else {
                // handle that you should fill all these 2 items: title , invitees
            }
            
        }
        
    }
    
    
    
    
    func sendRequest(on: String, theDescription: String?, theImage: String?, theInvitees: [Invitee], theMetadata: String?, theTitle: String, theType: String?, theRequestUniqueId: String?) {
        
        var i = ""
        for item in theInvitees {
            i.append("\(item.formatToJSON()) ,")
        }
        
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "\(on) send create thread request with this parameters:\ndescription = \(theDescription ?? "nil") , image = \(theImage ?? "nil") , invitees = \(i) , metadata = \(theMetadata ?? "nil") , title = \(theTitle) , type = \(theType ?? "nil") , requestUniqueId = \(theRequestUniqueId ?? "nil")", lineNumbers: 3)
        
        let createThreadInput = CreateThreadRequestModel(description: theDescription, image: nil, invitees: theInvitees, metadata: nil, title: theTitle, type: theType, uniqueId: nil)
        myChatObject?.createThread(createThreadInput: createThreadInput, uniqueId: { (createThreadUniqueId) in
//            self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "create thread UniqueId response = \(createThreadUniqueId)", lineNumbers: 1)
            self.uniqueIdCallback?(createThreadUniqueId, on)
        }, completion: { (createThreadModel) in
//            self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "create thread response = \((createThreadModel as! CreateThreadModel).returnDataAsJSON())", lineNumbers: 3)
            print("server response to create thread:\n\((createThreadModel as! CreateThreadModel).returnDataAsJSON())")
            self.responseCallback?(createThreadModel as! CreateThreadModel, on)
        })
        
    }
    
    
    /*
     first create a contact, then use it linkeUser model,
     insid linkeUser, there is parameter nameed "coreUserId"
     in the invitee model to pass to createThread, pass this "coreUserId" and type "TO_BE_USER_ID"
     */
    func createNormalThreadWithId(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with userId", lineNumbers: 1)
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                
                if let linkeUser = myContact.linkedUser {
                    if let linkUserId = linkeUser.coreUserId {
                        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                        
                        self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithId) New Contact has been created, now try to create thread with some fake params and this user id = \(linkUserId).", lineNumbers: 2)
                        
                        let myInvitee = Invitee(id: "\(linkUserId)", idType: "\(InviteeVOidTypes.TO_BE_USER_ID)")
                        self.sendRequest(on: "(on createNormalThreadWithId)", theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: fakeParams.type, theRequestUniqueId: nil)
                    } else {
                        // handle error that didn't get linkUserId in the linkedUser model of Contact
                        self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithId) This user is register but it doesn't have coreUserId in it's Model!)", lineNumbers: 1)
                    }
                    
                } else {
                    // handle error that didn't get linkUser model of Contact
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithId) This user is not registered! (doesn't have LinkUser Model inside the server response...)", lineNumbers: 1)
                }
                
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "AddContact (on createNormalThreadWithId) with this parameters is Failed!\nfirstName = \(firstName ?? "nil") , cellphoneNumber = \(cellphoneNumber ?? "nil") , lastName = \(lastName ?? "nil")", lineNumbers: 2)
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
        
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with Username", lineNumbers: 1)
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
//                if myContact.hasUser {
                
                    if let linkeUser = myContact.linkedUser {
                        if let linkedUsername = linkeUser.username {
                            let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                            
                            self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithUsername) New Contact has been created, now try to create thread with some fake params and this username = \(linkedUsername).", lineNumbers: 2)
                            
                            let myInvitee = Invitee(id: linkedUsername, idType: "\(InviteeVOidTypes.TO_BE_USER_USERNAME)")
                            self.sendRequest(on: "(on createNormalThreadWithUsername)", theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: fakeParams.type, theRequestUniqueId: nil)
                        } else {
                            // handle error that didn't get linkUserId in the linkedUser model of Contact
                            self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithUsername) This user is register but it doesn't have username in it's Model!)", lineNumbers: 1)
                        }
                        
                    } else {
                        // handle error that didn't get linkUser model of Contact
                        self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithUsername) This user is not registered! (doesn't have LinkUser Model inside the server response...)", lineNumbers: 1)
                    }
                    
//                } else {
//                    // this contact don't have linkeUser
//                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithUsername) This user is not registered! (the property 'hasUser' == 'flase' inside the server response...)", lineNumbers: 1)
//                }
                
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "AddContact (on createNormalThreadWithUsername) with this parameters is Failed!\nfirstName = \(firstName ?? "nil") , cellphoneNumber = \(cellphoneNumber ?? "nil") , lastName = \(lastName ?? "nil")", lineNumbers: 2)
            }
        }
        
    }
    
    /*
     first create a contact, in the response ContactModel there is parameter nameed "cellphoneNumber"
     in the invitee model to pass to createThread, pass this "cellphoneNumber" and type "TO_BE_USER_CELLPHONE_NUMBER"
     */
    func createNormalThreadWithCellPhoneNumber(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with CellPhoneNumber", lineNumbers: 1)
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithCellphoneNumber) New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    
                    let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
                    self.sendRequest(on: "(on createNormalThreadWithCellphoneNumber)", theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: fakeParams.type, theRequestUniqueId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithCellphoneNumber) there is no CellphoneNumber when addContact with this user (firstName = \(firstName ?? "nil") , cellphoneNumber = \(cellphoneNumber ?? "nil"))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on createNormalThreadWithCellphoneNumber) AddContact with this parameters is Failed!\nfirstName = \(firstName ?? "nil") , cellphoneNumber = \(cellphoneNumber ?? "nil") , lastName = \(lastName ?? "nil")", lineNumbers: 2)
            }
        }
    }
    
    
    /*
     first create a contact, in the response ContactModel there is parameter nameed "id"
     in the invitee model to pass to createThread, pass this "id" and type "TO_BE_USER_CONTACT_ID"
     */
    func createNormalThreadWithContactId(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with contactId", lineNumbers: 1)
        createContactWithContactIdThenCreateThread(on: "(on createNormalThreadWithContactId)", cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.NORMAL.rawValue)
    }
    
    func createChannelThread(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create Channel thread with ContactId", lineNumbers: 1)
        createContactWithContactIdThenCreateThread(on: "(on createChannelThreadWithContactId)", cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.CHANNEL.rawValue)
    }
    
    func createChannelGroupThread(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create ChannelGroup thread with ContactId", lineNumbers: 1)
        createContactWithContactIdThenCreateThread(on: "(on createChannelGroupThreadWithContactId)", cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.CHANNEL_GROUP.rawValue)
    }
    
    func createOwnerGroup(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create OwnerGroup thread with ContactId", lineNumbers: 1)
        createContactWithContactIdThenCreateThread(on: "(on createOwnerGroupWithContactId)", cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.OWNER_GROUP.rawValue)
    }
    
    func createPublicGroup(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create PublicGroup thread with ContactId", lineNumbers: 1)
        createContactWithContactIdThenCreateThread(on: "(on createPublicGroupWithContactId)", cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName, threadType: ThreadTypes.PUBLIC_GROUP.rawValue)
    }
    
    func createContactWithContactIdThenCreateThread(on: String, cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?, threadType: String) {
        
        let addContact = AddContactAutomation(cellphoneNumber: cellphoneNumber, email: email, firstName: firstName, lastName: lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    
                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "\(on) New Contact has been created, now try to create thread with some fake params and this contactId = \(contactId).", lineNumbers: 2)
                    
                    let myInvitee = Invitee(id: "\(contactId)", idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID)")
                    self.sendRequest(on: on, theDescription: fakeParams.description, theImage: self.image, theInvitees: [myInvitee], theMetadata: self.metadata, theTitle: fakeParams.title, theType: threadType, theRequestUniqueId: nil)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "\(on) contact id inside the contact model is not correct! (or it's nil)", lineNumbers: 1)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "AddContact \(on) with this parameters is Failed!\nfirstName = \(firstName ?? "nil") , contactId = \(cellphoneNumber ?? "nil") , lastName = \(lastName ?? "nil")", lineNumbers: 2)
            }
            
        }
        
    }
    
    
    
    
}




