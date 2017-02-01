//
//  ShowMetricHistoricalDataViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 27/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift
import UIGraphView

final class ShowMetricHistoricalDataViewController: UIViewController, IMetricHistoryView {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var weekGraphView: UIGraphView!
    @IBOutlet private var weekTitleLabel: UILabel!
    @IBOutlet private var monthGraphTitleLabel: UILabel!
    @IBOutlet private var monthGraphView: UIGraphView!
    
    fileprivate let rx_graphDataSubject = PublishSubject<([Double], [Double])>()
    fileprivate let rx_loadHistoricDataSubject = PublishSubject<Void>()
    var rx_loadHistoricData: Observable<Void> {
        return rx_loadHistoricDataSubject.asObservable()
    }
    
    fileprivate var dateFormatter: DateFormatter!
    
    var bag: RetainerBag!
    let disposeBag = DisposeBag()
    
    var selectedMetric: BodyMetric = .weight {
        didSet {
            self.title = selectedMetric.description
        }
    }
    
    var metricData: [MetricDataReading] = []
    var graphData: ([Double], [Double]) = ([],[])
    
    func showNoHistoricalDataWarning() {
        let alert = UIAlertController(title: "Error", message: "There is no data recorded for \(selectedMetric.description)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        present(alert, animated: true, completion: nil)
    }
    
    func update() {
        self.tableView.reloadData()
        self.weekGraphView.reloadData()
        self.monthGraphView.reloadData()
    }
    
    override func viewDidLoad() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "EEE, dd MMM yy, hh:mm"
        
        self.weekTitleLabel.text = "Last 7 days of \(self.title!)"
        weekGraphView.datasource = self
        weekGraphView.delegate = self
        monthGraphView.datasource = self
        monthGraphView.delegate = self
        
        rx_graphDataSubject
            .asObservable()
            .bindNext { [weak self] data in
                guard let `self` = self else { return }
                
                self.graphData = data
                self.weekGraphView.reloadData()
                self.monthGraphView.reloadData()
            }.addDisposableTo(disposeBag)
        rx_loadHistoricDataSubject.onNext()
    }
}

extension ShowMetricHistoricalDataViewController: IMetricGraphView {
    var rx_loadCurrentWeek: Observable<Void> {
        return rx_loadHistoricDataSubject.asObservable()
    }
    
    var rx_graphData: AnyObserver<([Double], [Double])> {
        return rx_graphDataSubject.asObserver()
    }
}

extension ShowMetricHistoricalDataViewController: UIGraphViewDelegate, UIGraphViewDataSource {
    func data(for dispersionGraph: UIGraphView) -> UIGraphViewSampleData {
        return graphData
    }
}

extension ShowMetricHistoricalDataViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metricData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricReadingCell", for: indexPath) as! MetricReadingTableViewCell
        
        cell.valueLabel.text = metricData[indexPath.row].reading
        if let date = metricData[indexPath.row].date as? Date {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
}
