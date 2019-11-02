//
//  Extensions.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 4/2/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import UIKit


extension UIColor {
    
    func intToRGB(red: Int, green: Int, blue: Int, alpha: CGFloat?) -> UIColor {
        let r: CGFloat = CGFloat(red / 255)
        let g: CGFloat = CGFloat(green / 255)
        let b: CGFloat = CGFloat(blue / 255)
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha ?? 1)
    }
    
    
    func hexToRGB(hex: String, alpha: CGFloat?) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha ?? 1)
    }
    
}



extension UIViewController {
    
    class MZInputTextField: UITextField {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.placeholder = "Input"
            self.textAlignment = .center
            self.layer.cornerRadius = 5
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.gray.cgColor
            self.autocapitalizationType = UITextAutocapitalizationType.none
            self.autocorrectionType = UITextAutocorrectionType.no
            self.backgroundColor = UIColor.init().hexToRGB(hex: "#dfe6e9", alpha: 1)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    
    class MZPickerView: UIPickerView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.init().hexToRGB(hex: "#b2bec3", alpha: 1)
            self.layer.cornerRadius = 2
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class MZRunButton: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.setTitle("Run", for: UIControl.State.normal)
            self.backgroundColor = UIColor.init().hexToRGB(hex: "#0984e3", alpha: 1)
            self.layer.cornerRadius = 2
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.shadowColor = UIColor.init().hexToRGB(hex: "#74b9ff", alpha: 1).cgColor
            self.layer.shadowOpacity = 1
            self.layer.shadowRadius = 1
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class MZLogView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.init().hexToRGB(hex: "#b2bec3", alpha: 1)
            self.layer.cornerRadius = 5
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.shadowColor = UIColor.darkGray.cgColor
            self.layer.shadowOpacity = 2
            self.layer.shadowRadius = 1
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    }
    
    
    class MZCollectionView: UICollectionView {
        
        override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
            super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    
}


