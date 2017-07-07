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

final class UIViewControllerFactory: IUIViewControllerFactory {
    func latestRecordViewController() -> LatestRecordViewController {
        return R.storyboard.main.latestRecordViewController()!
    }

    func newRecordViewController() -> NewRecordViewController {
        return R.storyboard.main.newRecordViewController()!
    }

    func showMetricHistoryData() -> ShowMetricHistoricalDataViewController {
        return R.storyboard.main.showMetricHistoricalData()!
    }

    func showInsights() -> InsightsViewController {
        return R.storyboard.main.insightsViewController()!
    }
}
