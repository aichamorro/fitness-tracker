//
//  NewRecordViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension String {
    var doubleValue: Double? {
        return Double(self.replacingOccurrences(of: ",", with: "."))
    }
}

extension UITextField {
    var textAsDouble: Double? {
        guard let text = self.text, let value = text.doubleValue else { return nil }
        
        return value
    }
}

typealias NewRecordViewModel = (height: UInt, weight: Double, muscle: Double, bodyFat: Double)

final class NewRecordViewController: UIViewController {
    @IBOutlet fileprivate var heightTextField: UITextField!
    @IBOutlet fileprivate var weightTextField: UITextField!
    @IBOutlet fileprivate var muscleTextField: UITextField!
    @IBOutlet fileprivate var bodyFatTextField: UITextField!
    @IBOutlet fileprivate var saveButton: UIButton!
    
    fileprivate let viewDidLoadSubject = PublishSubject<Void>()
    fileprivate let saveSubject = PublishSubject<NewRecordViewModel>()
    
    var interactors: [Any]!
    var disposeBag: DisposeBag!
    
    override func viewDidLoad() {
        saveButton.rx.tap.asObservable().subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            self.saveSubject.asObserver().onNext(self.viewModel)
        }).addDisposableTo(disposeBag)
        
        viewDidLoadSubject.onNext()
    }
}

extension NewRecordViewController: INewRecordView {
    var rx_viewDidLoad: Observable<Void> {
        return viewDidLoadSubject.asObservable()
    }
    
    var rx_actionSave: Observable<NewRecordViewModel> {
        return saveSubject.asObservable()
    }
    
    var viewModel: NewRecordViewModel {
        return (height: height, weight: weight, muscle: musclePercentage, bodyFat: bodyFatPercentage)
    }
    
    var height: UInt {
        get { return heightTextField.text != nil ? UInt(heightTextField.text!)! : 0 }
        set { heightTextField.text = String(format: "%d", newValue) }
    }
    
    var weight: Double {
        get { return weightTextField.text != nil ? weightTextField.textAsDouble! : 0 }
        set { weightTextField.text = String(format: "%.1f", newValue) }
    }
    
    var bodyFatPercentage: Double {
        get { return bodyFatTextField.text != nil ? bodyFatTextField.textAsDouble! : 0 }
        set { bodyFatTextField.text = String(format: "%.1f", newValue) }
    }

    var musclePercentage: Double {
        get { return muscleTextField.text != nil ? muscleTextField.textAsDouble! : 0 }
        set { muscleTextField.text = String(format: "%1.f", newValue) }
    }
    
    func dismiss() {
        actionClose(sender: self)
    }

}

extension NewRecordViewController {
    @IBAction fileprivate func actionClose(sender: Any?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func actionSave(sender: Any?) {
    }
}

extension NewRecordViewController: UITextFieldDelegate {
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