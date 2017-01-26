//
//  IUIViewControllerFactory.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 12/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit

protocol IUIViewControllerFactory {
    func latestRecordViewController() -> LatestRecordViewController
    func newRecordViewController() -> NewRecordViewController
    func showMetricHistoryData() -> ShowMetricHistoricalDataViewController
    func showInsights() -> InsightsViewController
}

final class UIViewControllerFactory {
    let storyboard: UIStoryboard!
    
    init(storyboard: UIStoryboard) {
        self.storyboard = storyboard
    }
}

extension UIViewControllerFactory: IUIViewControllerFactory {
    func latestRecordViewController() -> LatestRecordViewController {
        return storyboard.latestRecordViewController()
    }
    
    func newRecordViewController() -> NewRecordViewController {
        return storyboard.newRecordViewController()
    }
    
    func showMetricHistoryData() -> ShowMetricHistoricalDataViewController {
        return storyboard.showMetricHistoryData()
    }
    
    func showInsights() -> InsightsViewController {
        return storyboard.showInsights()
    }
}

private extension UIStoryboard {
    func latestRecordViewController() -> LatestRecordViewController {
        return instantiateViewController(withIdentifier: "LatestRecordViewController") as! LatestRecordViewController
    }
    
    func newRecordViewController() -> NewRecordViewController {
        return instantiateViewController(withIdentifier: "NewRecordViewController") as! NewRecordViewController
    }
    
    func showMetricHistoryData() -> ShowMetricHistoricalDataViewController {
        return instantiateViewController(withIdentifier: "ShowMetricHistoricalData") as! ShowMetricHistoricalDataViewController
    }
    
    func showInsights() -> InsightsViewController {
        return instantiateViewController(withIdentifier: "InsightsViewController") as! InsightsViewController
    }
}
