//
//  HomeScreenViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift

class HomeScreenViewController: UITableViewController {
    var interactor: IHomeScreenInteractor!
    var disposeBag: DisposeBag!
    var homeScreenView: HomeScreenView!

    override func viewDidLoad() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellSeparator")

        homeScreenView.viewModelVariable.asObservable()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            }).addDisposableTo(disposeBag)
        
        homeScreenView.viewDidLoad()
    }
}

extension HomeScreenViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row % 2 != 0 else {
            return tableView.dequeueReusableCell(withIdentifier: "CellSeparator", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BodyMeasurementMetricCell", for: indexPath) as! HomeScreenMetricCell
        cell.date.text = "Today, 13:30"
        
        var cellText: (name: String, value: String, metric: String)!
        switch indexPath.row/2 {
        case 0: cellText = ("Height", String(format: "%d", homeScreenView.viewModel.height), "cm")
        case 1: cellText = ("Weight", String(format: "%.1f", homeScreenView.viewModel.weight), "kg")
        case 2: cellText = ("Body Fat", String(format: "%.1f", homeScreenView.viewModel.bodyFat), "%")
        case 3: cellText = ("Muscle", String(format: "%.1f", homeScreenView.viewModel.muscle), "%")
        default: fatalError()
        }
        
        cell.metric.text = cellText.metric
        cell.name.text = cellText.name
        cell.value.text = cellText.value
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != 0 else { return 20 }
        
        return indexPath.row % 2 == 0 ? 10 : super.tableView(tableView, heightForRowAt: indexPath)
    }
}
