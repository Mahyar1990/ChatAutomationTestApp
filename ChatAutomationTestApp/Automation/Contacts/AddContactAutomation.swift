//
//  AddContactAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK



/*
 if somebody call this method,
 a addContact request will send
 if the callers did't send input parameters, inputs will fill qoutomatically by this parameters:
 - cellphoneNumber: will a String with 11 characters
 - firstName:       will a String with 4 characters
 - lastName:        will a String with 7 characters
 - email:           will a email by using firstName and lastName that gererated before
 */
class AddContactAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let cellphoneNumber: String?
    let email:          String?
    let firstName:      String?
    let lastName:       String?
    
    typealias callbackStringTypeAlias            = (String) -> ()
    typealias callbackServerResponseTypeAlias    = (ContactModel) -> ()
    
    private var uniqueIdCallback: callbackStringTypeAlias?
    private var responseCallback: callbackServerResponseTypeAlias?
    
    init(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.lastName           = lastName
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (ContactModel) -> ()) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        // if none of the parameters filled by the user, jenerate fake values and fill the input model to send request
        switch (cellphoneNumber, email, firstName, lastName) {
        case (.none, .none, .none, .none), ("", "", "", ""):
            let fakeParams = Faker.sharedInstance.generateFakeAddContactParams(cellphoneLength: 11, firstNameLength: 4, lastNameLength: 7)
            delegate?.newInfo(type: MoreInfoTypes.AddContact.rawValue, message: "generate fake values to add contact as:\ncellPhoneNumber = \(fakeParams.cellphoneNumber) , email = \(fakeParams.email) , firstName = \(fakeParams.firstName) , lastName = \(fakeParams.lastName)", lineNumbers: 3)
            sendRequest(theCellphoneNumber: fakeParams.cellphoneNumber, theEmail: fakeParams.email, theFirstName: fakeParams.firstName, theLastName: fakeParams.lastName)
            
        // some or all of the parameters are filled by the client, so send request with this params
        default:
            sendRequest(theCellphoneNumber: cellphoneNumber, theEmail: email, theFirstName: firstName, theLastName: lastName)
        }
        
    }
    
    
    func sendRequest(theCellphoneNumber: String?, theEmail: String?, theFirstName: String?, theLastName: String?) {
        
        delegate?.newInfo(type: MoreInfoTypes.AddContact.rawValue, message: "Send AddContact request with this params:\ncellPhoneNumber = \(theCellphoneNumber ?? "nil") , email = \(theEmail ?? "nil") , firstName = \(theFirstName ?? "nil") , lastName = \(theLastName ?? "nil")", lineNumbers: 3)
        
        let addContactInput = AddContactRequestModel(cellphoneNumber:  theCellphoneNumber,
                                                      email:            theEmail,
                                                      firstName:        theFirstName,
                                                      lastName:         theLastName,
                                                      typeCode:         nil,
                                                      uniqueId:         nil)
        Chat.sharedInstance.addContact(inputModel: addContactInput, uniqueId: { (addContactsUniqueId) in
            self.uniqueIdCallback?(addContactsUniqueId)
        }, completion: { (addContactServerResponse) in
            self.responseCallback?(addContactServerResponse as! ContactModel)
        })
    }
    
    
}

