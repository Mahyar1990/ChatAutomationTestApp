//
//  SendFileMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import UIKit
import SwiftyJSON

class SendFileMessageAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    var content:        String?
    var data:           Data?
    let fileName:       String?
    var threadId:       Int?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackProgressTypeAlias         = (Float) -> ()
    typealias callbackServerResponseTypeAlias   = (SendMessageModel) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var progressCallback:       callbackProgressTypeAlias?
    private var serverSentResponse:     callbackServerResponseTypeAlias?
    private var serverDeliverResponse:  callbackServerResponseTypeAlias?
    private var serverSeenResponse:     callbackServerResponseTypeAlias?
    
    init(content: String?, data: Data?, fileName: String?, threadId: Int?, uniqueId: String?) {
        
        self.content            = content
        self.data               = data
        self.fileName           = fileName
        self.threadId           = threadId
        self.requestUniqueId    = uniqueId
    }
    
    func create(uniqueId:               @escaping callbackStringTypeAlias,
                progress:               @escaping callbackProgressTypeAlias,
                serverSentResponse:     @escaping callbackServerResponseTypeAlias,
                serverDeliverResponse:  @escaping callbackServerResponseTypeAlias,
                serverSeenResponse:     @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback       = uniqueId
        self.progressCallback       = progress
        self.serverSentResponse     = serverSentResponse
        self.serverDeliverResponse  = serverDeliverResponse
        self.serverSeenResponse     = serverSeenResponse
        
        sendRequestSenario(contactId: content, threadId: threadId, data: data)
        
    }
    
    func sendRequestSenario(contactId: String?, threadId: Int?, data: Data?) {
        // 1- add contact
        // 2- create thread with this contact
        // 3- uploadFile
        // 4- send request
        
        switch (contactId, threadId, data) {
        case (.none, .none, _):                     addContact()
        case let (.some(id), .none, _):             createThread(withContactId: id)
        case (_ , .some(_), .none):                 prepareDataToUpload()
        case let (_ , .some(tId), .some(myData)):   sendRequest(theData: myData, toThreadId: tId)
        }
    }
    
    // 1
    func addContact() {
        let arvin = Faker.sharedInstance.ArvinAsContact
        let addContact = AddContactAutomation(cellphoneNumber: arvin.cellphoneNumber, email: arvin.email, firstName: arvin.firstName, lastName: arvin.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let id = myContact.id {
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this contact id = \(id).", lineNumbers: 2)
                    self.sendRequestSenario(contactId: "\(id)", threadId: self.threadId, data: self.data)
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "there is no id when addContact with this user (firstName = \(arvin.firstName) , cellphoneNumber = \(arvin.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(arvin.firstName) , cellphoneNumber = \(arvin.cellphoneNumber) , lastName = \(arvin.lastName)", lineNumbers: 2)
            }
        }
    }
    
    // 2
    func createThread(withContactId contactId: String) {
        let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
        let myInvitee = Invitee(id: "\(contactId)", idType: INVITEE_VO_ID_TYPES.TO_BE_USER_CONTACT_ID)
        let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: ThreadTypes.PUBLIC_GROUP, requestUniqueId: nil)
        var i = ""
        for item in createThread.invitees! {
            i.append("\(item.formatToJSON()) ,")
        }
        delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "try to create new PublicGroup thread with this parameters: \n description = \(createThread.description!),\n invitees = \(i),\n title = \(createThread.title!),\n type = \(createThread.type!)", lineNumbers: 6)
        createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
            if let id = createThreadModel.thread?.id {
                self.threadId = id
                self.delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                self.sendRequestSenario(contactId: nil, threadId: id, data: self.data)
                
            } else {
                // handle error, there is no id in the Conversation model
            }
        })
    }
    
    // 3
    func prepareDataToUpload() {
        delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "there is no data specified to upload", lineNumbers: 1)
        let image = UIImage(named: "pic")
        if let data = image?.jpegData(compressionQuality: 1) {
            delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "data has picked from Assets, prepare it to upload", lineNumbers: 1)
            sendRequestSenario(contactId: nil, threadId: self.threadId, data: data)
        }
    }
    
    // 4
    func sendRequest(theData: Data, toThreadId: Int) {
        let myFileName =  self.fileName ?? "Image\(Faker.sharedInstance.generateNameAsString(withLength: 3))"
        let myContent = content ?? "This is a dummy message"
        delegate?.newInfo(type: MoreInfoTypes.SendFileMessage.rawValue, message: "send Request SendFileMessage with this params:\n messageText = \(myContent),\n threadId = \(threadId ?? 0), fileName = \(myFileName)", lineNumbers: 2)
        
        let fileMessageInput = SendFileMessageRequestModel(fileName:    myFileName,
                                                           imageName:   nil,
                                                           xC:          nil,
                                                           yC:          nil,
                                                           hC:          nil,
                                                           wC:          nil,
                                                           threadId:    toThreadId,
                                                           content:     myContent,
                                                           metadata:    nil,
                                                           repliedTo:   nil,
                                                           fileToSend:  theData,
                                                           imageToSend: nil,
                                                           typeCode:    nil,
                                                           uniqueId:    nil)
        
        Chat.sharedInstance.sendFileMessage(inputModel: fileMessageInput, uniqueId: { (sentFileMessageUniqueId) in
            self.uniqueIdCallback?(sentFileMessageUniqueId)
        }, uploadProgress: { (uploadFileProgress) in
            self.progressCallback?(uploadFileProgress)
        }, onSent: { (sent) in
            self.serverDeliverResponse?(sent as! SendMessageModel)
        }, onDelivered: { (deliver) in
            self.serverDeliverResponse?(deliver as! SendMessageModel)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! SendMessageModel)
        })
        
    }
    
}
