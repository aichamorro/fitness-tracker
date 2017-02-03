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
import RxCocoa

final class ShowMetricHistoricalDataViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var graphView: UIGraphView!
    @IBOutlet fileprivate var graphVisualizationSegmentControl: UISegmentedControl!
    
    fileprivate let rx_didReceiveGraphData = PublishSubject<([Double], [Double])>()
    fileprivate let rx_loadGraphData = PublishSubject<Date>()
    fileprivate let rx_loadCurrentWeekSubject = PublishSubject<Void>()
    fileprivate let rx_loadHistoricDataSubject = PublishSubject<Void>()
    
    fileprivate var dateFormatter: DateFormatter!
    
    var bag: RetainerBag!
    let disposeBag = DisposeBag()
    
    var metricData: [MetricDataReading] = []
    var graphData: ([Double], [Double]) = ([],[])
    var selectedMetric: BodyMetric = .weight {
        didSet {
            self.title = selectedMetric.description
        }
    }

    func showNoHistoricalDataWarning() {
        let alert = UIAlertController(title: "Error", message: "There is no data recorded for \(selectedMetric.description)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        present(alert, animated: true, completion: nil)
    }
    
    func update() {
        self.tableView.reloadData()
        self.graphView.reloadData()
    }
    
    override func viewDidLoad() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "EEE, dd MMM yy, hh:mm"
        
        graphView.delegate = self
        graphView.datasource = self
        
        graphVisualizationSegmentControl.rx.value
            .asObservable()
            .bindNext { [weak self] value in
                guard let `self` = self else { return }
                
                switch value {
                    case 0: self.rx_loadCurrentWeekSubject.onNext()
                case 1: self.rx_loadGraphData.onNext(Date.now.adding(days: -7))
                case 2: self.rx_loadGraphData.onNext(Date.now.adding(days: -30))
                case 3: self.rx_loadGraphData.onNext(Date.now.adding(days: -90))
                    default: fatalError()
                }
            }.addDisposableTo(disposeBag)
        
        rx_didReceiveGraphData
            .asObservable()
            .bindNext { [weak self] data in
                guard let `self` = self else { return }
                
                self.graphData = data
                self.graphView.reloadData()
            }.addDisposableTo(disposeBag)
        
        rx_loadCurrentWeekSubject.onNext()
        rx_loadHistoricDataSubject.onNext()
    }
}

extension ShowMetricHistoricalDataViewController: IMetricGraphView, ICurrentWeekGraphView, IMetricHistoryView {
    var rx_loadLatestRecords: Observable<Date> {
        return rx_loadGraphData.asObservable()
    }
    
    var rx_loadCurrentWeekRecords: Observable<Void> {
        return rx_loadCurrentWeekSubject.asObservable()
    }
    
    var rx_graphData: AnyObserver<([Double], [Double])> {
        return rx_didReceiveGraphData.asObserver()
    }
    
    var rx_loadHistoricData: Observable<Void> {
        return rx_loadHistoricDataSubject.asObservable()
    }
}

extension ShowMetricHistoricalDataViewController: UIGraphViewDelegate, UIGraphViewDataSource {
    func data(for dispersionGraph: UIGraphView) -> UIGraphViewSampleData {
        return graphData
    }
    
    func graphView(_ graphView: UIGraphView, shouldAddHorizontalTagFor index: Int) -> Bool {
        return self.graphVisualizationSegmentControl.selectedSegmentIndex > 1 ? (index % 7) == 0 : true
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
