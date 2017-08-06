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

private let DefaultGraphViewOption = 0

typealias Adapter<T, V> = (T) -> V
typealias FitnessInfoAdatper<T> = Adapter<[IFitnessInfo], T>
typealias MetricDataReading = (date: NSDate?, reading: String)

internal func FitnessInfoToGraphDataAdapter(bodyMetric: BodyMetric) -> FitnessInfoAdatper<([Double], [Double])> {
    let calendar = Calendar.current

    return { data in
        var dates: [Double] = []
        var readings: [Double] = []

        data.forEach { info in
            let alignedDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: info.date! as Date)!
            dates.append(alignedDate.timeIntervalSinceReferenceDate)
            readings.append(info.value(for: bodyMetric).doubleValue)
        }

        return (dates, readings)
    }
}

internal func FitnessInfoToMetricDataReading(bodyMetric: BodyMetric) -> FitnessInfoAdatper<[MetricDataReading]> {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 1

    return { fitnessInfoRecords in
        return fitnessInfoRecords.map {
            return ($0.date, formatter.string(from: $0.value(for: bodyMetric))!)
        }
    }
}

final class ShowMetricHistoricalDataViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var graphView: UIGraphView!
    @IBOutlet fileprivate var graphVisualizationSegmentControl: UISegmentedControl!

    fileprivate let rx_didReceiveGraphData = PublishSubject<[IFitnessInfo]>()
    fileprivate let rx_loadGraphData = PublishSubject<Date>()
    fileprivate let rx_removeReadingSubject = PublishSubject<IFitnessInfo>()
    fileprivate let rx_loadHistoricDataSubject = PublishSubject<Void>()
    fileprivate var dateFormatter: DateFormatter!

    var bag: RetainerBag!
    let disposeBag = DisposeBag()

    fileprivate var tableViewData: [MetricDataReading] = []
    fileprivate var graphData: ([Double], [Double]) = ([], [])
    fileprivate let rx_metricDataVariable = Variable<[IFitnessInfo]>([])

    fileprivate var graphDataAdapter: FitnessInfoAdatper<([Double], [Double])>!
    fileprivate var metricDataAdapter: FitnessInfoAdatper<[MetricDataReading]>!

    var selectedMetric: BodyMetric = .weight {
        didSet {
            self.title = selectedMetric.description
        }
    }

    func showNoHistoricalDataWarning() {
        let alert = UIAlertController(title: LocalizableStrings.HistoricalData.Errors.Dialog.title(),
                                      message: LocalizableStrings.HistoricalData.Errors.noData(metric: selectedMetric.description),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizableStrings.HistoricalData.Errors.Dialog.Ok(),
                                      style: .default,
                                      handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        present(alert, animated: true, completion: nil)
    }

    func update() {
        self.tableView.reloadData()
        self.graphView.reloadData()
    }

    func reloadGraphData(value: Int? = nil) {
        let selectedIndex: Int = value ?? graphVisualizationSegmentControl.selectedSegmentIndex

        switch selectedIndex {
        case 0: self.showCurrentWeekInGraph()
        case 1: self.showLastSevenDaysInGraph()
        case 2: self.showLastMontInGraph()
        case 3: self.showLastThreeMonthsInGraph()
        case 4: self.showLastYearInGraph()
        default: fatalError()
        }

    }

    override func viewDidLoad() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "EEE, dd MMM yy, hh:mm"

        graphDataAdapter = FitnessInfoToGraphDataAdapter(bodyMetric: self.selectedMetric)
        graphView.delegate = self
        graphView.datasource = self

        metricDataAdapter = FitnessInfoToMetricDataReading(bodyMetric: self.selectedMetric)

        graphVisualizationSegmentControl.rx.value
            .asObservable()
            .bindNext { [weak self] value in
                guard let `self` = self else { return }

                self.reloadGraphData(value: value)
            }.addDisposableTo(disposeBag)

        rx_didReceiveGraphData
            .asObservable()
            .do(onNext: { [weak self] data in
                guard let `self` = self else { return }

                self.graphData = self.graphDataAdapter(data)
            }).subscribe (onNext: { [weak self] _ in
                self?.graphView.reloadData()
            }).addDisposableTo(disposeBag)

        showCurrentWeekInGraph()
        rx_loadHistoricDataSubject.onNext()
    }

    private func showCurrentWeekInGraph() {
        let calendar = Calendar.current

        rx_loadGraphData.onNext(Calendar.current.weekInterval(of: calendar.now as NSDate)!.start)
    }

    private func showLastSevenDaysInGraph() {
        rx_loadGraphData.onNext(Calendar.current.date(addingDays: -7, to: Calendar.current.startOfToday))
    }

    private func showLastMontInGraph() {
        rx_loadGraphData.onNext(Calendar.current.date(addingDays: -30, to: Calendar.current.startOfToday))
    }

    private func showLastThreeMonthsInGraph() {
        rx_loadGraphData.onNext(Calendar.current.date(addingDays: -90, to: Calendar.current.startOfToday))
    }

    private func showLastYearInGraph() {
        rx_loadGraphData.onNext(Calendar.current.date(addingDays: -365, to: Calendar.current.startOfToday))
    }
}

extension ShowMetricHistoricalDataViewController: IMetricGraphView, IMetricHistoryView {
    var rx_loadLatestRecords: Observable<Date> {
        return rx_loadGraphData.asObservable()
    }

    var rx_graphData: AnyObserver<[IFitnessInfo]> {
        return rx_didReceiveGraphData.asObserver()
    }

    var rx_loadHistoricData: Observable<Void> {
        return rx_loadHistoricDataSubject.asObservable()
    }

    var rx_metricData: AnyObserver<[IFitnessInfo]> {
        return AnyObserver { [unowned self] event in
            switch event {

            case .next(let element):
                self.rx_metricDataVariable.value = element
                self.tableViewData = self.metricDataAdapter(element)

            default:
                break
            }
        }
    }

    func reload() {
        reloadGraphData()
    }
}

extension ShowMetricHistoricalDataViewController: RemoveReadingView {
    var rx_removeReading: Observable<IFitnessInfo> {
        return rx_removeReadingSubject.asObservable()
    }
}

extension ShowMetricHistoricalDataViewController: UIGraphViewDelegate, UIGraphViewDataSource {
    func data(for dispersionGraph: UIGraphView) -> UIGraphViewSampleData {
        return graphData
    }

    func graphView(_ graphView: UIGraphView, shouldAddHorizontalTagFor index: Int) -> Bool {
        if self.graphVisualizationSegmentControl.selectedSegmentIndex == 4 {
            return index % 30 == 0
        }

        return self.graphVisualizationSegmentControl.selectedSegmentIndex > 1 ? (index % 7) == 0 : true
    }

    func graphView(_ graphView: UIGraphView, horizontalTagFor index: Int) -> String {
        let timeInterval = graphData.0[index]
        let date = Date(timeIntervalSinceReferenceDate: timeInterval)
        let day = Calendar.current.component(.day, from: date)

        return "\(day)"
    }
}

extension ShowMetricHistoricalDataViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rx_metricDataVariable.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.metricReadingCell, for: indexPath)!

        cell.valueLabel.text = tableViewData[indexPath.row].reading
        if let date = tableViewData[indexPath.row].date as Date? {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(
            title: LocalizableStrings.HistoricalData.RemoveWarning.title(),
            message: LocalizableStrings.HistoricalData.RemoveWarning.message(),
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(
            title: LocalizableStrings.HistoricalData.RemoveWarning.yes(),
            style: UIAlertActionStyle.default,
            handler: { _ in
                let recordToRemove = self.rx_metricDataVariable.value[indexPath.row]

                self.removeRecord(recordToRemove)
        }))

        alert.addAction(UIAlertAction(title: LocalizableStrings.HistoricalData.RemoveWarning.no(), style: .destructive, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func removeRecord(_ record: IFitnessInfo) {
        rx_removeReadingSubject.onNext(record)
    }
}
