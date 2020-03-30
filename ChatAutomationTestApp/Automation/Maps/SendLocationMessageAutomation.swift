//
//  SendLocationMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import UIKit
import SwiftyJSON

class SendLocationMessageAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let lat:            Double?
    let lon:            Double?
    var content:        String?
    var threadId:       Int?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackProgressTypeAlias         = (Float) -> ()
    typealias callbackServerResponseTypeAlias   = (SendMessageModel) -> ()
    
    private var uniqueIdCallback:           callbackStringTypeAlias?
    private var uploadProgressCallback:     callbackProgressTypeAlias?
    private var downloadProgressCallback:   callbackProgressTypeAlias?
    private var serverSentResponse:     callbackServerResponseTypeAlias?
    private var serverDeliverResponse:  callbackServerResponseTypeAlias?
    private var serverSeenResponse:     callbackServerResponseTypeAlias?
    
    init(lat: Double?, lon: Double?, content: String?, threadId: Int?) {
        
        self.lat                = lat
        self.lon                = lon
        self.content            = content
        self.threadId           = threadId
    }
    
    func create(uniqueId:               @escaping callbackStringTypeAlias,
                downloadProgress:       @escaping callbackProgressTypeAlias,
                uploadProgress:         @escaping callbackProgressTypeAlias,
                serverSentResponse:     @escaping callbackServerResponseTypeAlias,
                serverDeliverResponse:  @escaping callbackServerResponseTypeAlias,
                serverSeenResponse:     @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback           = uniqueId
        self.uploadProgressCallback     = uploadProgress
        self.downloadProgressCallback   = downloadProgress
        self.serverSentResponse         = serverSentResponse
        self.serverDeliverResponse      = serverDeliverResponse
        self.serverSeenResponse         = serverSeenResponse
        
        sendRequestSenario(contactId: content, threadId: threadId)
        
    }
    
    func sendRequestSenario(contactId: String?, threadId: Int?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- send request
        
        switch (contactId, threadId) {
        case (.none, .none):
            addContact()
            
        case let (.some(id), .none):
            createThread(withContactId: id)
            
        case let (_ , .some(id)):
            sendRequest(toThreadId: id)
            
        }
    }
    
    // 1
    func addContact() {
        let arvin = Faker.sharedInstance.ArvinAsContact
        let addContact = AddContactAutomation(cellphoneNumber: arvin.cellphoneNumber, email: arvin.email, firstName: arvin.firstName, lastName: arvin.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.SendLocationMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contact id = \(id).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: "\(id)", threadId: self.threadId)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.SendLocationMessage.rawValue, message: "there is no id when addContact with this user (firstName = \(arvin.firstName) , cellphoneNumber = \(arvin.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.SendLocationMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(arvin.firstName) , cellphoneNumber = \(arvin.cellphoneNumber) , lastName = \(arvin.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withContactId contactId: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(contactId)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, uniqueName: nil, type: ThreadTypes.PUBLIC_GROUP, requestUniqueId: nil)
        var i = ""
        for item in createThread.invitees! {
            i.append("\(item.formatToJSON()) ,")
        }
        delegate?.newInfo(type: MoreInfoTypes.SendLocationMessage.rawValue, message: "try to create new PublicGroup thread with this parameters: \n description = \(createThread.description!),\n invitees = \(i),\n title = \(createThread.title!),\n type = \(createThread.type!)", lineNumbers: 6)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                self.delegate?.newInfo(type: MoreInfoTypes.SendLocationMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    // 3
    func sendRequest(toThreadId: Int) {
        let myContent = content ?? "This is a dummy message"
        delegate?.newInfo(type: MoreInfoTypes.SendLocationMessage.rawValue, message: "send Request SendLocationMessage with this params:\n lat = \(lat ?? 36.310886959563085),\n lon = \(lon ?? 59.53563741408013),\n messageText = \(myContent),\n threadId = \(threadId ?? 0))", lineNumbers: 2)
        
        let locationMessageInput = SendLocationMessageRequestModel(mapStaticCenterLat:  lat ?? 36.310886959563085,
                                                                   mapStaticCenterLng:  lon ?? 59.53563741408013,
                                                                   mapStaticHeight:     500,
                                                                   mapStaticType:       "standard-night",
                                                                   mapStaticWidth:      800,
                                                                   mapStaticZoom:       15,
                                                                   sendMessageImageName: "staticLocationPic",
                                                                   sendMessageXC:       nil,
                                                                   sendMessageYC:       nil,
                                                                   sendMessageHC:       nil,
                                                                   sendMessageWC:       nil,
                                                                   sendMessageThreadId: toThreadId,
                                                                   sendMessageContent:  content,
                                                                   sendMessageMetadata: nil,
                                                                   sendMessageRepliedTo: nil,
                                                                   sendMessageTypeCode: nil,
                                                                   typeCode:            nil,
                                                                   uniqueId:            nil)
        Chat.sharedInstance.sendLocationMessage(inputModel: locationMessageInput, downloadProgress: { (downloadProgress) in
            self.downloadProgressCallback?(downloadProgress)
        }, uploadUniqueId: { _ in
        }, uploadProgress: { (uploadFileProgress) in
            self.uploadProgressCallback?(uploadFileProgress)
        }, messageUniqueId: { (sentLocationMessageUniqueId) in
            self.uniqueIdCallback?(sentLocationMessageUniqueId)
        }, onSent: { (sent) in
            self.serverDeliverResponse?(sent as! SendMessageModel)
        }, onDelivere: { (deliver) in
            self.serverDeliverResponse?(deliver as! SendMessageModel)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! SendMessageModel)
        })
        
    }
    
}
