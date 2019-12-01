//
//  UploadImageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 2/22/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import UIKit

class UploadImageAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let image:          UIImage?
    let fileName:       String?
    let threadId:       Int?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackProgressTypeAlias         = (Float) -> ()
    typealias callbackServerResponseTypeAlias   = (UploadImageModel) -> ()
    
    private var uniqueIdCallback:   callbackStringTypeAlias?
    private var progressCallback:   callbackProgressTypeAlias?
    private var responseCallback:   callbackServerResponseTypeAlias?
    
    init(image: UIImage?, fileName: String?, threadId: Int?, uniqueId: String?) {
        
        self.image              = image
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
        
        if let myImage = image {
            prepareImageToUpload(theImage: myImage)
        } else {
            delegate?.newInfo(type: MoreInfoTypes.UploadImage.rawValue, message: "there is no image specified to upload", lineNumbers: 1)
            prepareImageToUpload(theImage: nil)
        }
        
    }
    
    func sendRequest(theData: Data, theFileName: String) {
        delegate?.newInfo(type: MoreInfoTypes.UploadImage.rawValue, message: "send Request UploadImage with this params:\n fileName = \(theFileName)", lineNumbers: 2)
        
        let uploadImageInput = UploadImageRequestModel(dataToSend:      theData,
                                                       fileExtension:   nil,
                                                       fileName:        theFileName,
                                                       fileSize:        nil,
                                                       originalFileName: nil,
                                                       threadId:        threadId,
                                                       xC:              nil,
                                                       yC:              nil,
                                                       hC:              nil,
                                                       wC:              nil,
                                                       typeCode:        nil,
                                                       uniqueId:        requestUniqueId)
        
        Chat.sharedInstance.uploadImage(uploadImageInput: uploadImageInput, uniqueId: { (uploadImageUniqueId) in
            self.uniqueIdCallback?(uploadImageUniqueId)
        }, progress: { (uploadImageProgress) in
            self.progressCallback?(uploadImageProgress)
        }, completion: { (uploadImageServerResponse) in
            self.responseCallback?(uploadImageServerResponse as! UploadImageModel)
        })
        
    }
    
    
    func prepareImageToUpload(theImage: UIImage?) {
        
        if let image = theImage {
            if let data = image.jpegData(compressionQuality: 1) {
                delegate?.newInfo(type: MoreInfoTypes.UploadImage.rawValue, message: "Image has picked from user correctly", lineNumbers: 1)
                sendRequest(theData: data, theFileName: fileName ?? "Image\(Faker.sharedInstance.generateNameAsString(withLength: 3))")
            }
        } else {
            let image = UIImage(named: "pic")
            if let data = image?.jpegData(compressionQuality: 1) {
                delegate?.newInfo(type: MoreInfoTypes.UploadImage.rawValue, message: "image has piced from Assets, prepare it to upload", lineNumbers: 1)
                sendRequest(theData: data, theFileName: fileName ?? "Image\(Faker.sharedInstance.generateNameAsString(withLength: 3))")
            }
        }
        
    }
    
}
