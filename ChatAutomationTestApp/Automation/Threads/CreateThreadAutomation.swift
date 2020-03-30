//
//  CreateThreadAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK

// ToDo: put the sendRequestSenario in this test (+ using DispatchTime)
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
    let uniqueName:     String?
    let type:           ThreadTypes?
    let requestUniqueId:       String?
    
    typealias callbackStringTypeAlias            = (String, String) -> ()
    typealias callbackServerResponseTypeAlias    = (ThreadModel, String) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(description: String?, image: String?, invitees: [Invitee]?, metadata: String?, title: String?, uniqueName: String?, type: ThreadTypes?, requestUniqueId: String?) {
        
        self.description        = description
        self.image              = image
        self.invitees           = invitees
        self.metadata           = metadata
        self.title              = title
        self.uniqueName         = uniqueName
        self.type               = type
        self.requestUniqueId    = requestUniqueId
    }
    
    
    func create(uniqueId: @escaping callbackStringTypeAlias, serverResponse: @escaping callbackServerResponseTypeAlias) {
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        // if the input parameter didn't filled by the user, first add a contact, then create a thread with this contact
        if ((invitees == nil) || (invitees?.count == 0)) && (title == nil) {
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "there is no invitee or title specify to creat thread, so have to implement all the possible cases to create a thread!!", lineNumbers: 2)
            self.createThreadSenario(threadType: .NORMAL, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .NormalThreadWithUsername, isCompleted: true)
        
        } else {
            // some or all of the parameters are filled by the caller, so send request with this params
            if (title != nil) && (invitees != nil) {
                sendRequest(on: nil, withDescription: description, withInvitees: invitees!, withTitle: title!, withType: type, uniqueName: uniqueName)
            } else {
                // handle that you should fill all these 2 items: title , invitees
                delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "'title' and 'invitees' are empty. you should fill both of these items", lineNumbers: 1)
            }
        }
    }
    
    
    func sendRequest(on: Section?, withDescription: String?, withInvitees: [Invitee], withTitle: String, withType: ThreadTypes?, uniqueName: String?) {
        
        var i = ""
        for item in withInvitees {
            i.append("\(item.formatToJSON()) ,")
        }
        
        delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "on \(on?.rawValue ?? "") send create thread request with this parameters:\n description = \(withDescription ?? "nil") ,\n image = \(self.image ?? "nil") ,\n invitees = \(i) ,\n metadata = \(self.metadata ?? "nil") ,\n title = \(withTitle) ,\n type = \(withType ?? ThreadTypes.NORMAL) ,\n requestUniqueId = \(self.requestUniqueId ?? "nil")", lineNumbers: 6)
        
        let createThreadInput = CreateThreadRequestModel(description:   withDescription,
                                                         image:         self.image,
                                                         invitees:      withInvitees,
                                                         metadata:      self.metadata,
                                                         uniqueName:    uniqueName,
                                                         title:         withTitle,
                                                         type:          withType,
                                                         typeCode:      nil,
                                                         uniqueId:      self.requestUniqueId)
        
        Chat.sharedInstance.createThread(inputModel: createThreadInput, uniqueId: { (createThreadUniqueId) in
            self.uniqueIdCallback?(createThreadUniqueId, "on \(on?.rawValue ?? "user request")")
        }, completion: { (createThreadModel) in
            self.responseCallback?(createThreadModel as! ThreadModel, "on \(on?.rawValue ?? "user request")")
            if let section = on {
                switch (section) {
                case (Section.NormalThreadWithCoreUserId):      self.createThreadSenario(threadType: .NORMAL,       withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .NormalThreadWithUsername,   isCompleted: true)
                case (Section.NormalThreadWithUsername):        self.createThreadSenario(threadType: .NORMAL,       withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .NormalThreadWithCellPhoneNumber, isCompleted: true)
                case (Section.NormalThreadWithCellPhoneNumber): self.createThreadSenario(threadType: .NORMAL,       withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .NormalThreadWithContactId,  isCompleted: true)
                case (Section.NormalThreadWithContactId):       self.createThreadSenario(threadType: .CHANNEL,      withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .ChannelThreadWithContactId, isCompleted: true)
                case (Section.ChannelThreadWithContactId):                   self.createThreadSenario(threadType: .CHANNEL_GROUP, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .ChannelGroupThreadWithContactId,        isCompleted: true)
                case (Section.ChannelGroupThreadWithContactId):              self.createThreadSenario(threadType: .OWNER_GROUP,  withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .OwnerGroupThreadWithContactId,           isCompleted: true)
                case (Section.OwnerGroupThreadWithContactId):                self.createThreadSenario(threadType: .PUBLIC_GROUP, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: .PublicGroupThreadWithContactId,          isCompleted: true)
                default: return
                }
            }
            
        })
        
    }
    
}


extension CreateThreadAutomation {
    
    func createThread(ofType: ThreadTypes, withCoreUserId: Int?, withCellPhoneNumber: String?, withUsername: String?, withContactId: Int?, withUniqueName: String?, on section: Section) {
        
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        
        switch (withCoreUserId, withCellPhoneNumber, withUsername, withContactId) {
        case let (.some(id), .none, .none, .none):
            let myInvitee = Invitee(id: "\(id)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_ID)
            self.sendRequest(on: section, withDescription: fakeParams.description, withInvitees: [myInvitee], withTitle: fakeParams.title, withType: fakeParams.type, uniqueName: withUniqueName)
            
        case let (.none, .some(cell), .none, .none):
            let myInvitee = Invitee(id: "\(cell)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CELLPHONE_NUMBER)
            self.sendRequest(on: section, withDescription: fakeParams.description, withInvitees: [myInvitee], withTitle: fakeParams.title, withType: fakeParams.type, uniqueName: withUniqueName)
            
        case let (.none, .none, .some(name), .none):
            let myInvitee = Invitee(id: "\(name)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_USERNAME)
            self.sendRequest(on: section, withDescription: fakeParams.description, withInvitees: [myInvitee], withTitle: fakeParams.title, withType: fakeParams.type, uniqueName: withUniqueName)
            
        case let (.none, .none, .none, .some(id)):
            let myInvitee = Invitee(id: "\(id)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CONTACT_ID)
            self.sendRequest(on: section, withDescription: fakeParams.description, withInvitees: [myInvitee], withTitle: fakeParams.title, withType: ofType, uniqueName: withUniqueName)
            
        default: return
        }
        
    }
}


extension CreateThreadAutomation {
    func createThreadSenario(threadType: ThreadTypes, withCoreUserId: Int?, withUsername: String?, withCellPhoneNumber: String?, withContactId: Int?, section: Section, isCompleted: Bool) {
        
        switch (threadType, withCoreUserId, withUsername, withCellPhoneNumber, withContactId, section, isCompleted) {
        case (.NORMAL,  .none, .none, .none, .none, .NormalThreadWithCoreUserId, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with userId", lineNumbers: 1)
            addContact(on: section)
        case let (.NORMAL, .some(id), .none, .none, .none, .NormalThreadWithCoreUserId, _ ):
            createThread(ofType: threadType, withCoreUserId: id, withCellPhoneNumber: nil, withUsername: nil, withContactId: nil, withUniqueName: nil, on: section)
            
        case (.NORMAL,  .none, .none, .none, .none, .NormalThreadWithUsername, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with Username", lineNumbers: 1)
            addContact(on: section)
        case let (.NORMAL, .none, .some(name), .none, .none, .NormalThreadWithUsername, _ ):
            createThread(ofType: threadType, withCoreUserId: nil, withCellPhoneNumber: nil, withUsername: name, withContactId: nil, withUniqueName: nil, on: section)
            
        case (.NORMAL,  .none, .none, .none, .none, .NormalThreadWithCellPhoneNumber, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with CellPhoneNumber", lineNumbers: 1)
            addContact(on: section)
        case let (.NORMAL, .none, .none, .some(cell), .none, .NormalThreadWithCellPhoneNumber, _ ):
            createThread(ofType: threadType, withCoreUserId: nil, withCellPhoneNumber: cell, withUsername: nil, withContactId: nil, withUniqueName: nil, on: section)
            
        case (.NORMAL,  .none, .none, .none, .none, .NormalThreadWithContactId, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create NORMAL thread with contactId", lineNumbers: 1)
            addContact(on: section)
        case let (.NORMAL, .none, .none, .none, .some(id), .NormalThreadWithContactId, _ ):
            createThread(ofType: threadType, withCoreUserId: nil, withCellPhoneNumber: nil, withUsername: nil, withContactId: id, withUniqueName: nil, on: section)
        
        case (.CHANNEL, .none, .none, .none, .none, .ChannelThreadWithContactId, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create CHANNEL thread with ContactId", lineNumbers: 1)
            addContact(on: section)
        case let (.CHANNEL, .none, .none, .none, .some(id), .ChannelThreadWithContactId, _):
            createThread(ofType: threadType, withCoreUserId: nil, withCellPhoneNumber: nil, withUsername: nil, withContactId: id, withUniqueName: nil, on: section)
            
        case (.CHANNEL_GROUP, .none, .none, .none, .none, .ChannelGroupThreadWithContactId, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create CHANNEL_GROUP thread with ContactId", lineNumbers: 1)
            addContact(on: section)
        case let (.CHANNEL_GROUP, .none, .none, .none, .some(id), .ChannelGroupThreadWithContactId, _):
            createThread(ofType: threadType, withCoreUserId: nil, withCellPhoneNumber: nil, withUsername: nil, withContactId: id, withUniqueName: Faker.sharedInstance.generateNameAsString(withLength: 15), on: section)
            
        case (.OWNER_GROUP, .none, .none, .none, .none, .OwnerGroupThreadWithContactId, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create OWNER_GROUP thread with ContactId", lineNumbers: 1)
            addContact(on: section)
        case let (.OWNER_GROUP, .none, .none, .none, .some(id), .OwnerGroupThreadWithContactId, _):
            createThread(ofType: threadType, withCoreUserId: nil, withCellPhoneNumber: nil, withUsername: nil, withContactId: id, withUniqueName: nil, on: section)
            
        case (.PUBLIC_GROUP, .none, .none, .none, .none, .PublicGroupThreadWithContactId, true):
            delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "try to create PUBLIC_GROUP thread with ContactId", lineNumbers: 1)
            addContact(on: section)
        case let (.PUBLIC_GROUP, .none, .none, .none, .some(id), .PublicGroupThreadWithContactId, _):
            createThread(ofType: threadType, withCoreUserId: nil, withCellPhoneNumber: nil, withUsername: nil, withContactId: id, withUniqueName: Faker.sharedInstance.generateNameAsString(withLength: 15), on: section)
            
        default: return
        }
    }
}


extension CreateThreadAutomation {
    
    func addContact(on: Section) {
        
        let mehdi = Faker.sharedInstance.mehdiAsContact
        let addContact = AddContactAutomation(cellphoneNumber: mehdi.cellphoneNumber, email: mehdi.email, firstName: mehdi.firstName, lastName: mehdi.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                self.createThread(on: on, withContact: myContact)
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "AddContact (on \(on.rawValue) with this parameters is Failed!\nfirstName = \(mehdi.firstName) , cellphoneNumber = \(mehdi.cellphoneNumber) , lastName = \(mehdi.lastName)", lineNumbers: 2)
            }
        }
        
    }
    
    
    func createThread(on: Section, withContact myContact: Contact) {
        switch (on) {
        case (Section.NormalThreadWithCoreUserId):
            if let linkeUser = myContact.linkedUser {
                if let linkUserId = linkeUser.coreUserId {
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue) New Contact has been created, now try to create thread with some fake params and this user id = \(linkUserId).", lineNumbers: 2)
                    self.createThreadSenario(threadType: ThreadTypes.NORMAL, withCoreUserId: linkUserId, withUsername: nil, withCellPhoneNumber: nil, withContactId: nil, section: on, isCompleted: false)
                } else {
                    // handle error that didn't get linkUserId in the linkedUser model of Contact
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue) This user is register but it doesn't have coreUserId in it's Model!)", lineNumbers: 1)
                }
            } else {
                // handle error that didn't get linkUser model of Contact
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue) This user is not registered! (doesn't have LinkUser Model inside the server response...)", lineNumbers: 1)
            }
            
        case (Section.NormalThreadWithUsername):
            if let linkeUser = myContact.linkedUser {
                if let linkedUsername = linkeUser.username {
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue)) New Contact has been created, now try to create thread with some fake params and this username = \(linkedUsername).", lineNumbers: 2)
                    self.createThreadSenario(threadType: ThreadTypes.NORMAL, withCoreUserId: nil, withUsername: linkedUsername, withCellPhoneNumber: nil, withContactId: nil, section: on, isCompleted: false)
                } else {
                    // handle error that didn't get linkUserId in the linkedUser model of Contact
                    self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue) This user is register but it doesn't have username in it's Model!)", lineNumbers: 1)
                }
                
            } else {
                // handle error that didn't get linkUser model of Contact
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue)) This user is not registered! (doesn't have LinkUser Model inside the server response...)", lineNumbers: 1)
            }
            
        case (Section.NormalThreadWithCellPhoneNumber):
            if let cellphoneNumber = myContact.cellphoneNumber {
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue)) New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                self.createThreadSenario(threadType: ThreadTypes.NORMAL, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: cellphoneNumber, withContactId: nil, section: on, isCompleted: false)
            } else {
                // handle error that didn't get contact id in the contact model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "(on \(on.rawValue)) there is no CellphoneNumber when addContact with this user (firstName = \(myContact.firstName) , cellphoneNumber = \(myContact.cellphoneNumber))!", lineNumbers: 2)
            }
            
        case .PublicGroupThreadWithContactId, .ChannelGroupThreadWithContactId:
            if let contactId = myContact.id {
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "\(on.rawValue) New Contact has been created, now try to create thread with some fake params and this contactId = \(contactId).", lineNumbers: 2)
                switch on {
                case .ChannelGroupThreadWithContactId:   self.createThreadSenario(threadType: ThreadTypes.CHANNEL_GROUP, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: contactId, section: on, isCompleted: false)
                case .PublicGroupThreadWithContactId:    self.createThreadSenario(threadType: ThreadTypes.PUBLIC_GROUP, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: contactId, section: on, isCompleted: false)
                default: return
                }
            } else {
                // handle error that didn't get contact id in the contact model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "\(on.rawValue) contact id inside the contact model is not correct! (or it's nil)", lineNumbers: 1)
            }
            
        case .NormalThreadWithContactId, .ChannelThreadWithContactId, .OwnerGroupThreadWithContactId/*, .ChannelGroupThread, .PublicGroupThread*/:
            if let contactId = myContact.id {
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "\(on.rawValue) New Contact has been created, now try to create thread with some fake params and this contactId = \(contactId).", lineNumbers: 2)
                switch on {
                case .NormalThreadWithContactId:    self.createThreadSenario(threadType: ThreadTypes.NORMAL, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: contactId, section: on, isCompleted: false)
                case .ChannelThreadWithContactId:                self.createThreadSenario(threadType: ThreadTypes.CHANNEL, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: contactId, section: on, isCompleted: false)
                case .OwnerGroupThreadWithContactId:             self.createThreadSenario(threadType: ThreadTypes.OWNER_GROUP, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: contactId, section: on, isCompleted: false)
//                case .ChannelGroupThread:           self.createThreadSenario(threadType: ThreadTypes.CHANNEL_GROUP, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: contactId, section: on, isCompleted: false)
//                case .PublicGroupThread:            self.createThreadSenario(threadType: ThreadTypes.PUBLIC_GROUP, withCoreUserId: nil, withUsername: nil, withCellPhoneNumber: nil, withContactId: contactId, section: on, isCompleted: false)
                default: return
                }
            } else {
                // handle error that didn't get contact id in the contact model
                self.delegate?.newInfo(type: MoreInfoTypes.CreateThread.rawValue, message: "\(on.rawValue) contact id inside the contact model is not correct! (or it's nil)", lineNumbers: 1)
            }
        }
    }
    
    
}



extension CreateThreadAutomation {
    
    enum Section: String {
        case NormalThreadWithCoreUserId         = "createNormalThreadWithCoreUserId"
        case NormalThreadWithUsername           = "createNormalThreadWithUsername"
        case NormalThreadWithCellPhoneNumber    = "createNormalThreadWithCellPhoneNumber"
        case NormalThreadWithContactId          = "createNormalThreadWithContactId"
        
        case ChannelThreadWithContactId         = "createChannelThreadWithContactId"
        case ChannelGroupThreadWithContactId    = "createChannelGroupThreadWithContactId"
        case OwnerGroupThreadWithContactId      = "createOwnerGroupThreadWithContactId"
        case PublicGroupThreadWithContactId     = "createPublicGroupThreadWithContactId"
    }
    
}

