//
//  InsightsViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 12/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift

final class InsightsViewController: UICollectionViewController {
    fileprivate var insights: [FitnessInfoInsightViewModel] = []
    var bag: RetainerBag!
    
    lazy var rx_insightsLazy: AnyObserver<[FitnessInfoInsightViewModel]> = AnyObserver { [weak self] event in
        guard let `self` = self else { return }
        
        if !event.isStopEvent, let element = event.element {
            self.insights = element
            self.collectionView?.reloadData()
        }
    }
}

extension InsightsViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return insights.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.insightCardTableViewCell, for: indexPath)!
        
        cell.title.text = insights[indexPath.row].title
        cell.weight.text = Formats.BodyMeasurements.WithUnit.weight(insights[indexPath.row].weight)
        cell.bodyFatWeight.text = Formats.BodyMeasurements.WithUnit.bodyFatWeight(insights[indexPath.row].bodyFatWeight)
        cell.muscleWeight.text = Formats.BodyMeasurements.WithUnit.muscleWeight(insights[indexPath.row].muscleWeight)
        cell.waterPercentage.text = Formats.BodyMeasurements.WithUnit.waterPercentage(insights[indexPath.row].waterPercentage)

        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        
        return cell
    }
}

extension InsightsViewController: IInsightsView {
    var rx_insights: AnyObserver<[FitnessInfoInsightViewModel]> {
        return rx_insightsLazy
    }
}
