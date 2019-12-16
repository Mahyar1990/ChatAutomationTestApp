//
//  RemoveParticipantAutomation.swift
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
 RemoveParticipantAutomation request will send
 */

class RemoveParticipantAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let content:    [Int]?
    let threadId:   Int?
    let typeCode:   String?
    let requestUniqueId:   String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (RemoveParticipantModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(content: [Int]?, threadId: Int?, typeCode: String?, requestUniqueId: String?) {
        
        self.content            = content
        self.threadId           = threadId
        self.typeCode           = typeCode
        self.requestUniqueId    = requestUniqueId
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.responseCallback   = serverResponse
        
        sendRequestSenario(content: content, threadId: threadId)
        
    }
    
    func sendRequest(participants: [Int], theThreadId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.RemoveParticipant.rawValue, message: "send Request to removeParticipant with this params: \n participants = \(participants) , threadId = \(theThreadId)", lineNumbers: 2)
        
        let removeParticipantInput = RemoveParticipantsRequestModel(participantIds: participants,
                                                                    threadId:       theThreadId,
                                                                    typeCode:       typeCode,
                                                                    uniqueId:       requestUniqueId)
        
        Chat.sharedInstance.removeParticipants(inputModel: removeParticipantInput, uniqueId: { (removeParticipantUniqueId) in
            self.uniqueIdCallback?(removeParticipantUniqueId)
        }, completion: { (removeParticipantServerResponseModel) in
            self.responseCallback?(removeParticipantServerResponseModel as! RemoveParticipantModel)
        })
        
    }
    
    func sendRequestSenario(content: [Int]?, threadId: Int?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            switch (content, threadId) {
            case let (.some(participnats), .some(id)):
                self.sendRequest(participants: participnats, theThreadId: id)
            default:
                self.delegate?.newInfo(type: MoreInfoTypes.RemoveParticipant.rawValue, message: "threadId or Participants to remove are not specified", lineNumbers: 2)
                self.addParticipant()
            }
        }
    }
    
    func addParticipant() {
        delegate?.newInfo(type: MoreInfoTypes.RemoveParticipant.rawValue, message: "Try to add participant", lineNumbers: 1)
        let addParticipant = AddParticipantAutomation(contacts: nil, threadId: nil, typeCode: nil, requestUniqueId: nil)
        addParticipant.create(uniqueId: { _ in }) { (addParticipantResponseModel) in
            if let threadModel = addParticipantResponseModel.thread {
                if let myThreadId = threadModel.id {
                    if let participants = threadModel.participants {
                        if participants.count > 0 {
                            self.sendRequestSenario(content: [participants.first!.id!], threadId: myThreadId)
                        }
                    } else {
                        self.delegate?.newInfo(type: MoreInfoTypes.RemoveParticipant.rawValue, message: "Error: AddParticipant response does not have Participants inside the thread Model!!!!", lineNumbers: 2)
                    }
                } else {
                    self.delegate?.newInfo(type: MoreInfoTypes.RemoveParticipant.rawValue, message: "Error: AddParticipant response does not have threadId inside the thread Model!!!!", lineNumbers: 2)
                }
            } else {
                self.delegate?.newInfo(type: MoreInfoTypes.RemoveParticipant.rawValue, message: "Error: AddParticipant response does not have thread model in it!!!!", lineNumbers: 2)
            }
        }
    }
    
}
