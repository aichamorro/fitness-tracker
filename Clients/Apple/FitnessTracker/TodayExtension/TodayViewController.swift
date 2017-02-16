
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Alberto Chamorro on 23/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit
import NotificationCenter
import RxSwift

private func LatestRecordPresenter(interactor: AnyInteractor<Void, IFitnessInfo>, view: ILatestRecordView, disposeBag: DisposeBag) {
    
    interactor.rx_output.map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .subscribe(onNext: { view.viewModel = $0 })
        .addDisposableTo(disposeBag)

    view.rx_viewDidLoad
        .subscribe(onNext: {interactor.rx_input.onNext()})
        .addDisposableTo(disposeBag)
}

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet private var heightLabel: UILabel!
    @IBOutlet private var weightLabel: UILabel!
    @IBOutlet private var bodyFatWeightLabel: UILabel!
    @IBOutlet private var muscleWeightLabel: UILabel!
    @IBOutlet private var waterPercentageLabel: UILabel!
    
    private var interactor: AnyInteractor<Void, IFitnessInfo>!
    private let disposeBag = DisposeBag()
    fileprivate let viewDidLoadSubject = PublishSubject<Void>()
    
    var viewModel: LatestRecordViewModel = LatestRecordViewModel.empty {
        didSet {
            updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoreDataStackInitializer({ managedObjectContext in
            NSLog("Core Data Stack initialized correctly")
            
            self.interactor = FindLatestRecord(repository: CoreDataInfoRepository(managedObjectContext: managedObjectContext))
            LatestRecordPresenter(interactor: self.interactor, view: self, disposeBag: self.disposeBag)
        }, { error in
            fatalError(error as! String)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateView() {
        heightLabel.text = String(format: "%d", viewModel.height)
        weightLabel.text = String(format: "%.2f", viewModel.weight)
        bodyFatWeightLabel.text = String(format: "%.2f", viewModel.bodyFatWeight)
        muscleWeightLabel.text = String(format: "%.2f", viewModel.muscleWeight)
        waterPercentageLabel.text = String(format: "%.2f", viewModel.water)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        viewDidLoadSubject.onNext()
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController: ILatestRecordView {
    var rx_viewDidLoad: Observable<Void> {
        return viewDidLoadSubject.asObservable()
    }
    
    var rx_didSelectMetric: Observable<BodyMetric> {
        fatalError("Did select metric is not available for Today Extensions")
    }
}
