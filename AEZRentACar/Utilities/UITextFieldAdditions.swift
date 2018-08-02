//
//  UITextFieldAdditions.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 6/2/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit

var key: Void?

class UITextFieldAdditions: NSObject {
    var readonly: Bool = false
}

extension UITextField {
    var readonly: Bool {
        get {
            return self.getAdditions().readonly
        } set {
            self.getAdditions().readonly = newValue
        }
    }
    
    private func getAdditions() -> UITextFieldAdditions {
        var additions = objc_getAssociatedObject(self, &key) as? UITextFieldAdditions
        if additions == nil {
            additions = UITextFieldAdditions()
            objc_setAssociatedObject(self, &key, additions!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return additions!
    }
    
    open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        if ((action == #selector(UIResponderStandardEditActions.paste(_:)) || (action == #selector(UIResponderStandardEditActions.cut(_:)))) && self.readonly) {
            return nil
        }
        return super.target(forAction: action, withSender: sender)
    }
}

class AEZTextField : UITextField {
    
    var shouldAddLeftSpace = false
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        if shouldAddLeftSpace {
            return bounds.insetBy(dx: 22, dy: 0)
        }
        return bounds
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if shouldAddLeftSpace {
            return bounds.insetBy(dx: 22, dy: 0)
        }
        return bounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if shouldAddLeftSpace {
            return bounds.insetBy(dx: 22, dy: 0)
        }
        return bounds
    }
}
