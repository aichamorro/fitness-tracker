//
//  ShowMetricHistoricalDataViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 27/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift

final class ShowMetricHistoricalDataViewController: UITableViewController, IMetricHistoryView {
    private let rx_loadHistoricDataSubject = PublishSubject<Void>()
    var rx_loadHistoricData: Observable<Void> {
        return rx_loadHistoricDataSubject.asObservable()
    }
    
    fileprivate var dateFormatter: DateFormatter!
    
    var bag: RetainerBag!
    
    var selectedMetric: BodyMetric = .weight {
        didSet {
            self.title = selectedMetric.description
        }
    }
    
    var metricData: [MetricDataReading] = []
    func showNoHistoricalDataWarning() {
        let alert = UIAlertController(title: "Error", message: "There is no data recorded for \(selectedMetric.description)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        present(alert, animated: true, completion: nil)
    }
    
    func update() {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd MMM yy, hh:mm"
        
        rx_loadHistoricDataSubject.onNext()
    }
}

extension ShowMetricHistoricalDataViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metricData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricReadingCell", for: indexPath) as! MetricReadingTableViewCell
        
        cell.valueLabel.text = metricData[indexPath.row].reading
        if let date = metricData[indexPath.row].date as? Date {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
}
