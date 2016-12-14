//
//  ViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 13/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DayLogInputViewController: UIViewController {
    
    @IBOutlet fileprivate var weightTextField: UITextField!
    @IBOutlet fileprivate var heightTextField: UITextField!
    @IBOutlet fileprivate var bodyFatPercentageTextField: UITextField!
    @IBOutlet fileprivate var musclePercentageTextField: UITextField!
    @IBOutlet fileprivate var tapOnViewGestureRecognizer: UITapGestureRecognizer!
    
    private let viewModel = RxViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tapOnViewGestureRecognizer.rx.event.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(false)
        }).addDisposableTo(disposeBag)
        
        weightTextField.delegate = self
        heightTextField.delegate = self
        bodyFatPercentageTextField.delegate = self
        musclePercentageTextField.delegate = self

        weightTextField.rx.text.asObservable()
            .flatMap(flatMapToDouble)
            .filter(filterInvalidValues)
            .bindTo(viewModel.weight)
            .addDisposableTo(disposeBag)
        
        heightTextField.rx.text.asObservable()
            .flatMap(flatMapToInt)
            .filter(filterInvalidValues)
            .bindTo(viewModel.height)
            .addDisposableTo(disposeBag)
        
        bodyFatPercentageTextField.rx.text.asObservable()
            .flatMap(flatMapToDouble)
            .filter(filterInvalidValues)
            .bindTo(viewModel.bodyFat)
            .addDisposableTo(disposeBag)
        
        musclePercentageTextField.rx.text.asObservable()
            .flatMap(flatMapToDouble)
            .filter(filterInvalidValues)
            .bindTo(viewModel.muscle)
            .addDisposableTo(disposeBag)
        
        viewModel.validatesModel.filter { $0 == true } .bindNext { [weak self] _ in
            guard let `self` = self else { return }
//
//            let info = self.viewModel.build()
//            self.bmiLabel.text = textForLabel(.bmi, .none, String(format: "%.2f", info.bmi))
//            self.muscleWeight.text = textForLabel(.muscle, .kg, String(format: "%.2f", info.muscleWeight))
//            self.waterWeight.text = textForLabel(.bodyWater, .kg, "???")
//            self.bodyFatWeight.text = textForLabel(.bodyFat, .kg, String(format: "%.2f", info.bodyFatWeight))
        }.addDisposableTo(disposeBag)
    }
}

extension DayLogInputViewController: UITextFieldDelegate {
    private func measure(for textField: UITextField) -> String {
        switch textField {
        case weightTextField: return "kg"
        case heightTextField: return "cm"
        case bodyFatPercentageTextField: fallthrough
        case musclePercentageTextField: return "%"
        default:
            fatalError("Not Handled")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        textField.text = "\(textField.text ?? "") \(measure(for: textField))"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let value = textField.text {
            guard value.characters.count > 0 else { return }
            
            let index = value.index(value.endIndex, offsetBy: -(measure(for: textField).characters.count))
            
            textField.text = textField.text!.substring(to: index)
        }
    }
}

private extension DayLogInputViewController {
    var rx_weight: Observable<String?> {
        return weightTextField.rx.text.asObservable()
    }
    
    var rx_height: Observable<String?> {
        return heightTextField.rx.text.asObservable()
    }
    
    var rx_bodyFatPercentage: Observable<String?> {
        return bodyFatPercentageTextField.rx.text.asObservable()
    }
    
    var rx_musclePercentage: Observable<String?> {
        return musclePercentageTextField.rx.text.asObservable()
    }
}

private let flatMapToDouble: (String?) -> Observable<Double?> = {
    return $0 != nil ? Observable.just(Double($0!)) : Observable.just(nil)
}

private let flatMapToInt: (String?) -> Observable<UInt?> = {
    return $0 != nil ? Observable.just(UInt($0!)) : Observable.just(nil)
}

private let filterInvalidValues: (Any?) -> Bool = {
    return $0 != nil
}

private struct RxViewModel {
    let height = Variable<UInt?>(nil)
    let weight = Variable<Double?>(nil)
    let bodyFat = Variable<Double?>(nil)
    let muscle = Variable<Double?>(nil)
    
    var validatesModel: Observable<Bool>
    
    init() {
        validatesModel = Observable.combineLatest(weight.asObservable(), height.asObservable(), bodyFat.asObservable(), muscle.asObservable()) { (weight, height, bodyFat, muscle) -> Bool in
            if weight == nil { return false }
            if height == nil { return false }
            if bodyFat == nil { return false }
            if muscle == nil { return false }
            
            return true
        }
    }
    
    func build() -> FitnessInfo {
        return FitnessInfo(weight: Weight(weight.value!), height: Height(height.value!), bodyFatPercentage: (bodyFat.value!/100), musclePercentage: (muscle.value!/100))
    }
}

private enum FormLabel: String {
    case bmi = "BMI"
    case bodyFat = "Grasa"
    case bodyWater = "Agua"
    case muscle = "Músculo"
}

private enum Unit: String {
    case percentage = "%"
    case cm = "cm"
    case kg = "Kg"
    case none = ""
}

private let textForLabel: (FormLabel, Unit, String) -> String = { label, measure, value in
    return "\(label.rawValue): \(value) \(measure.rawValue)"
}

