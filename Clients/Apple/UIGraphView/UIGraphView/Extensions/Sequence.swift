//
//  Sequence.swift
//  UIGraphView
//
//  Created by Alberto Chamorro on 29/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: Comparable {
    var range: Range<Iterator.Element>? {
        let sortedSequence = sorted(by: <)
        guard let first = sortedSequence.first, let last = sortedSequence.last else {
            return nil
        }
        
        return Range(uncheckedBounds: (first, last))
    }
}
