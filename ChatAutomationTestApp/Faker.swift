//
//  Faker.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/8/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK


class Faker {
    
    static let sharedInstance = Faker()
    
    private init() {
        
    }
    
    func generateFakeCreateThread() -> (description: String, title: String, type: String, message: String) {
        let description:    String?
        let title:          String?
        let type:           String?
        let message:        String?
        
        description = generateNameAsString(withLength: 13)
        title       = generateNameAsString(withLength: 10)
        type        = ThreadTypes.NORMAL.rawValue
        message     = generateNameAsString(withLength: 20)
        
        return (description!, title!, type!, message!)
    }
    
    
    func generateFakeGetContactParams() -> (count: Int, offset: Int) {
        var localCount:  Int = 1
        var localOffset: Int = 0
        
        localCount  = generateNumberAsInt(from: 1, to: 20)
        localOffset = generateNumberAsInt(from: 0, to: 20)
        return (localCount, localOffset)
    }
    
    
    func generateFakeAddContactParams(cellphoneLength: Int?, firstNameLength: Int?, lastNameLength: Int?) -> (cellphoneNumber: String, email: String, firstName: String, lastName: String) {
        let cellphoneNumber: String?
        let email:          String?
        let firstName:      String?
        let lastName:       String?
        
        cellphoneNumber = generateNumberAsString(withLength: cellphoneLength ?? 11)
        firstName       = generateNameAsString(withLength: firstNameLength ?? 4)
        lastName        = generateNameAsString(withLength: lastNameLength ?? 7)
        email           = generateEmailAsString(withName: "\(firstName!).\(lastName!)", withoutNameWithLength: 8)
        
        return (cellphoneNumber!, email!, firstName!, lastName!)
    }
    
    
    let pouriaAsContact: (cellphoneNumber: String, email: String, firstName: String, lastName: String) = ("09387181694", "p.pahlevani@gmail.com", "Pooria", "Pahlevani")
    
    let mehdiAsContact: (cellphoneNumber: String, email: String, firstName: String, lastName: String) = ("09368640180", "mehdi@gmail.com", "Mehdi", "Akbarian")
    
    let MohsenAsContact: (cellphoneNumber: String, email: String, firstName: String, lastName: String) = ("09363261694", "mohsen.malekan@gmail.com", "Mohsen", "Malekan")
    
    let ArvinAsContact: (cellphoneNumber: String, email: String, firstName: String, lastName: String) = ("09363448861", "Arvin.Rokni@gmail.com", "Arvin", "Rokni")
    
    let MehranAsContact: (cellphoneNumber: String, email: String, firstName: String, lastName: String) = ("09363448861", "Mehran.HasanZadeh@gmail.com", "Mehran", "HasanZadeh")
}




extension Faker {
    
    func generateNameAsString(withLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func generateNumberAsString(withLength length: Int) -> String {
        let letters = "0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func generateEmailAsString(withName: String?, withoutNameWithLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let atSighn = String((0...4).map{ _ in letters.randomElement()! })
        let dot     = String((0...2).map{ _ in letters.randomElement()! })
        var emailName = ""
        if let name = withName {
            emailName = name
        } else {
            emailName = String((0...length-1).map{ _ in letters.randomElement()! })
        }
        return emailName + "@" + atSighn + "." + dot
    }
    
    func generateNumberAsInt(from: Int, to: Int) -> Int {
        let randomNumber = Int.random(in: from ... to)
        return randomNumber
    }
    
}
