//
//  RemoveContactAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK


/*
 if somebody call this method,
 a removeContact request will send
 if the caller of this function filled the id of the contact that it wants to remove, removeContact request will send.
 but if the callers did't send input parameter, it means the caller want's to just test the removeContact functionality
 so the senario will be:
 first addContact by using addContact function that will generate some parameters to add a contact
 when the response of the addContact comes from server,
 we will send removeContact request by using the id of the new contact that we created earlier.
 */
class RemoveContactAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let id: Int?
    
    typealias callbackStringTypeAlias            = (String) -> ()
    typealias callbackServerResponseTypeAlias    = (RemoveContactModel) -> ()
    
    private var uniqueIdCallback: callbackStringTypeAlias?
    private var responseCallback: callbackServerResponseTypeAlias?
    
    init(id: Int?) {
        self.id = id
    }
    
    func create(uniqueId:       @escaping (String) -> (),
                serverResponse: @escaping (RemoveContactModel) -> ()) {
        
        self.uniqueIdCallback = uniqueId
        self.responseCallback   = serverResponse
        
        // the parameter is filled by the client, so send request with this params
        if let contactId = id {
            sendRequest(theId: contactId)
        }
        // if the input parameter didn't filled by the user, first create a contact, then remove it
        else {
            delegate?.newInfo(type: MoreInfoTypes.RemoveContact.rawValue, message: "there is no id specify to block. so first, need to addContact", lineNumbers: 1)
            addContact()
        }
        
    }
    
    
    func sendRequest(theId: Int) {
        
        delegate?.newInfo(type: MoreInfoTypes.RemoveContact.rawValue, message: "Send RemoveContact request with this param:\nid = \(theId)", lineNumbers: 2)
        
        let removeContactInput = RemoveContactsRequestModel(contactId: theId, typeCode: nil, uniqueId: nil)
        
        Chat.sharedInstance.removeContact(inputModel: removeContactInput, uniqueId: { (removeContactUniqueId) in
            self.uniqueIdCallback?(removeContactUniqueId)
        }, completion: { (removeContactServerResponse) in
            self.responseCallback?(removeContactServerResponse as! RemoveContactModel)
        })
    }
    
    
    func addContact() {
        let addContact = AddContactAutomation(cellphoneNumber: nil, email: nil, firstName: nil, lastName: nil)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let contactId = myContact.id {
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveContact.rawValue, message: "new conract has been created, contact id = \(contactId)", lineNumbers: 1)
                    self.sendRequest(theId: contactId)
                } else {
                    // handle error that didn't get contactId in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveContact.rawValue, message: "there is no contactId inside Contact Model", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.RemoveContact.rawValue, message: "there is no Contact Model in response!!", lineNumbers: 1)
            }
        }
    }
    
    
}



