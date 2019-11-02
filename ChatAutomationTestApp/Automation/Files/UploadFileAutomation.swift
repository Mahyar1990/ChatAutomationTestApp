//
//  UploadFileAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/22/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import UIKit

class UploadFileAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let data:           Data?
    let fileName:       String?
    let threadId:       Int?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackProgressTypeAlias         = (Float) -> ()
    typealias callbackServerResponseTypeAlias   = (UploadFileModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var progressCallback:   callbackProgressTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(data: Data?, fileName: String?, threadId: Int?, uniqueId: String?) {
        
        self.data               = data
        self.fileName           = fileName
        self.threadId           = threadId
        self.requestUniqueId    = uniqueId
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                progress:       @escaping callbackProgressTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias) {
        
        self.uniqueIdCallback   = uniqueId
        self.progressCallback   = progress
        self.responseCallback   = serverResponse
        
        if let myData = data {
            sendRequest(theData: myData, theFileName: fileName ?? "Image\(Faker.sharedInstance.generateNameAsString(withLength: 3))")
        } else {
            delegate?.newInfo(type: MoreInfoTypes.UploadFile.rawValue, message: "there is no data specified to upload", lineNumbers: 1)
            prepareDataToUpload()
        }
    }
    
    func sendRequest(theData: Data, theFileName: String) {
        delegate?.newInfo(type: MoreInfoTypes.UploadFile.rawValue, message: "send Request UploadFile with this params:\n fileName = \(theFileName)", lineNumbers: 2)
        
        let uploadFileInput = UploadFileRequestModel(dataToSend: theData,
                                                     fileExtension: nil,
                                                     fileName: theFileName,
                                                     fileSize: nil,
                                                     originalFileName: nil,
                                                     threadId: threadId,
                                                     uniqueId: nil)
        
        Chat.sharedInstance.uploadFile(uploadFileInput: uploadFileInput, uniqueId: { (uploadFileUniqueId) in
//        myChatObject?.uploadFile(uploadFileInput: uploadFileInput, uniqueId: { (uploadFileUniqueId) in
            self.uniqueIdCallback?(uploadFileUniqueId)
        }, progress: { (uploadFileProgress) in
            self.progressCallback?(uploadFileProgress)
        }, completion: { (uploadFileServerResponse) in
            self.responseCallback?(uploadFileServerResponse as! UploadFileModel)
        })
        
    }
    
    
    func prepareDataToUpload() {
        let image = UIImage(named: "pic")
        if let data = image?.jpegData(compressionQuality: 1) {
            delegate?.newInfo(type: MoreInfoTypes.UploadFile.rawValue, message: "data has piced from Assets, prepare it to upload", lineNumbers: 1)
            sendRequest(theData: data, theFileName: fileName ?? "Image\(Faker.sharedInstance.generateNameAsString(withLength: 3))")
        }
    }
    
}
