//
//  InsertBodyMeasurementRecordViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit

final class InsertBodyMeasurementRecordViewController: UIViewController {
    @IBOutlet fileprivate var heightTextField: UITextField!
    @IBOutlet fileprivate var weightTextField: UITextField!
    @IBOutlet fileprivate var muscleTextField: UITextField!
    @IBOutlet fileprivate var bodyFatTextField: UITextField!
    
    @IBAction func actionClose(sender: Any?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(sender: Any?) {
        self.actionClose(sender: nil)
    }
}

extension InsertBodyMeasurementRecordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterCount = textField.text?.characters.count ?? 0
        guard range.length + range.location <= characterCount else {
            return false
        }
        
        let newLength = characterCount + string.characters.count - range.length
        return newLength <= maxLength(for: textField)
    }
    
    private func maxLength(for textField: UITextField) -> Int {
        return (textField == heightTextField) ? 3 : 4
    }
}
