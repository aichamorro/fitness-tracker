//
//  LatestRecordViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift
import URLRouter

class LatestRecordViewController: UITableViewController {
    var interactors: [Any]!
    var disposeBag: DisposeBag!
    var latestRecordView: LatestRecordView!
    var router: URLRouter!
    
    fileprivate let needsRefreshSubject = PublishSubject<Void>()
    fileprivate let previousLatestResult = Variable<LatestRecordViewModel>(LatestRecordViewModel.empty)

    override func viewDidLoad() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellSeparator")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewRecord(sender:)))
        
        latestRecordView.viewModelVariable.asObservable()
            .skip(1)
            .do(onNext: { [weak self] _ in
                self?.needsRefreshSubject.onNext()
            }).subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            }).addDisposableTo(disposeBag)
        
        latestRecordView.viewDidLoad()
    }
    
    func createNewRecord(sender: Any?) {
        _ = router(URL(string: "app://records/new")!) { viewController in
            guard let viewController = viewController as? UIViewController else { fatalError() }
            
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

extension LatestRecordViewController: IShowPreviousLatestResultView {
    var rx_needsRefresh: Observable<Void> {
        return needsRefreshSubject.asObservable()
    }

    var rx_comparisonViewModel: AnyObserver<LatestRecordViewModel> {
        return AnyObserver { [weak self] event in
            guard let `self` = self else { return }
            
            switch event {
            case .next(let element):
                self.previousLatestResult.value = element
                self.tableView.reloadData()
                
            default: break
            }
        }
    }
}

extension LatestRecordViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row % 2 != 0 else {
            return tableView.dequeueReusableCell(withIdentifier: "CellSeparator", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BodyMeasurementMetricCell", for: indexPath) as! LatestRecordMetricCell
        let cellText = cellTextConfiguration(for: indexPath)
        
        cell.name.text = cellText.0
        cell.value.text = cellText.1
        cell.metric.text = cellText.2
        cell.date.text = cellText.3
        
        if indexPath.section == 1 {
            cell.container.backgroundColor = UIColor(red: 0.529, green: 0.176, blue: 0.384, alpha: 1.0)
        }
        
        return cell
    }
    
    func cellTextConfiguration(for indexPath: IndexPath) -> (String, String, String, String) {
        switch (indexPath.section, indexPath.row/2) {
            case (0, 0): return ("Height", String(format: "%d", latestRecordView.viewModel.height), "cm", "\(previousLatestResult.value.height) cm")
            case (0, 1): return ("Weight", String(format: "%.2f", latestRecordView.viewModel.weight), "kg", String(format: "%.2f kg", previousLatestResult.value.weight))
            case (0, 2): return ("Body Fat", String(format: "%.2f", latestRecordView.viewModel.bodyFat), "%", String(format: "%.2f %%", previousLatestResult.value.bodyFat))
            case (0, 3): return ("Muscle", String(format: "%.2f", latestRecordView.viewModel.muscle), "%", String(format: "%.2f %%", previousLatestResult.value.muscle))
            case (1, 0): return ("Body Fat Weight", String(format: "%.2f", latestRecordView.viewModel.bodyFatWeight), "kg", String(format: "%.2f kg",previousLatestResult.value.bodyFatWeight))
            case (1, 1): return ("Muscle Weight", String(format: "%.2f", latestRecordView.viewModel.muscleWeight), "kg", String(format: "%.2f kg",previousLatestResult.value.muscleWeight))
            case (1, 2): return ("Lean Body Weight", String(format: "%.2f", latestRecordView.viewModel.leanBodyWeight), "kg", String(format: "%.2f kg",previousLatestResult.value.leanBodyWeight))
            case (1, 3):
                return ("BMI", String(format: "%.1f", latestRecordView.viewModel.bmi), "", BMIRating.for(bmi: latestRecordView.viewModel.bmi).rawValue)

            default: fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != 0 else { return 20 }
        
        return indexPath.row % 2 == 0 ? 10 : super.tableView(tableView, heightForRowAt: indexPath)
    }
}