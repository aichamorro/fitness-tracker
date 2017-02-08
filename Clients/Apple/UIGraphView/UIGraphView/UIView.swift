//
//  UIView.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 31/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
    
    var isSubview: Bool {
        return superview != nil
    }
}
