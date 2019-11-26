//
//  UpdateContactAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 1/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK



/*
 if somebody call this method,
 a updateContact request will send
 if the callers did't send input parameters, inputs will fill qoutomatically by this parameters:
 - cellphoneNumber: will a String with 11 characters
 - firstName:       will a String with 4 characters
 - lastName:        will a String with 7 characters
 - email:           will a email by using firstName and lastName that gererated before
 */
class UpdateContactAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let cellphoneNumber: String?
    let email:          String?
    let firstName:      String?
    let id:             Int?
    let lastName:       String?
    
    typealias callbackStringTypeAlias            = (String) -> ()
    typealias callbackServerResponseTypeAlias    = (ContactModel) -> ()
    
    private var uniqueIdCallback: callbackStringTypeAlias?
    private var responseCallback: callbackServerResponseTypeAlias?
    
    init(cellphoneNumber: String?, email: String?, firstName: String?, id: Int?, lastName: String?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.id                 = id
        self.lastName           = lastName
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (ContactModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        // if none of the parameters filled by the user, jenerate fake values and fill the input model to send request
        switch (id, cellphoneNumber, firstName, lastName, email) {
        case let (.some(contactId), .some(contactCellPhone), .some(contactFirstname), .some(contactLastname), .some(contactEmail)):
            let requestModel = UpdateContactsRequestModel(cellphoneNumber:  contactCellPhone,
                                                          email:            contactEmail,
                                                          firstName:        contactFirstname,
                                                          id:               contactId,
                                                          lastName:         contactLastname,
                                                          requestTypeCode:  nil,
                                                          requestUniqueId:  nil)
            sendRequest(updateContactRequest: requestModel)
        default:
            delegate?.newInfo(type: MoreInfoTypes.UpdateContact.rawValue, message: "there is no contact specified to update. so first, need to addContact", lineNumbers: 1)
            addContactThenUpdateIt()
        }
        
    }
    
    
    func sendRequest(updateContactRequest: UpdateContactsRequestModel) {
        
        delegate?.newInfo(type: MoreInfoTypes.UpdateContact.rawValue, message: "Send UpdateContact request with this params:\n id = \(updateContactRequest.id) , cellPhoneNumber = \(updateContactRequest.cellphoneNumber) , email = \(updateContactRequest.email) , firstName = \(updateContactRequest.firstName) , lastName = \(updateContactRequest.lastName)", lineNumbers: 3)
        
        Chat.sharedInstance.updateContact(updateContactsInput: updateContactRequest, uniqueId: { (updateContactsUniqueId) in
            self.uniqueIdCallback?(updateContactsUniqueId)
        }, completion: { (updateContactServerResponse) in
            self.responseCallback?(updateContactServerResponse as! ContactModel)
        })
    }
    
    
    func addContactThenUpdateIt() {
        // 1- addContact
        // 2- update that contact
        
        // 1
        let addContact = AddContactAutomation(cellphoneNumber: nil, email: nil, firstName: nil, lastName: nil)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.UpdateContact.rawValue, message: "new conract has been created, contact id = \(contactId)", lineNumbers: 1)
                    
                    // 2
                    let sharedFaker = Faker.sharedInstance
                    let fakeContact = sharedFaker.generateFakeAddContactParams(cellphoneLength: 10, firstNameLength: 5, lastNameLength: 6)
                    var contact: (cell: String, mail: String, first: String, last: String) = (self.cellphoneNumber ?? fakeContact.cellphoneNumber, self.email ?? fakeContact.email, self.firstName ?? fakeContact.firstName, self.lastName ?? fakeContact.lastName)
                    if (self.cellphoneNumber == "") || (self.cellphoneNumber == " ") {
                        contact.cell = fakeContact.cellphoneNumber
                    }
                    if (self.email == "") || (self.email == " ") {
                        contact.mail = fakeContact.email
                    }
                    if (self.cellphoneNumber == "") || (self.cellphoneNumber == " ") {
                        contact.cell = fakeContact.cellphoneNumber
                    }
                    if (self.lastName == "") || (self.lastName == " ") {
                        contact.last = fakeContact.lastName
                    }
                    let updateContactModel = UpdateContactsRequestModel(cellphoneNumber:    contact.cell,
                                                                        email:              contact.mail,
                                                                        firstName:          contact.first,
                                                                        id:                 contactId,
                                                                        lastName:           contact.last,
                                                                        requestTypeCode:    nil,
                                                                        requestUniqueId:    nil)
                    self.sendRequest(updateContactRequest: updateContactModel)
                    
                } else {
                    // handle error that didn't get contactId in the contact model
                }
            } else {
                // handle error that didn't add Contact Model
            }
        }
        
    }
    
    
    
}
