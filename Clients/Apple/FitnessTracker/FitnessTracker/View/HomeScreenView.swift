//
//  HomeScreenView.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IHomeScreenView {
    var rx_weight: AnyObserver<Double> { get }
    var rx_height: AnyObserver<UInt> { get }
    var rx_bodyFatPercentage: AnyObserver<Double> { get }
    var rx_musclePercentage: AnyObserver<Double> { get }
    var rx_viewDidLoad: Observable<Void> { get }
}

struct HomeScreenView {
    let weight = PublishSubject<Double>()
    let height = PublishSubject<UInt>()
    let bodyFatPercentage = PublishSubject<Double>()
    let musclePercentage = PublishSubject<Double>()
    let viewDidLoad = PublishSubject<Void>()
}

extension HomeScreenView: IHomeScreenView {
    var rx_weight: AnyObserver<Double> { return weight.asObserver() }
    var rx_height: AnyObserver<UInt> { return height.asObserver() }
    var rx_bodyFatPercentage: AnyObserver<Double> { return bodyFatPercentage.asObserver() }
    var rx_musclePercentage: AnyObserver<Double> { return musclePercentage.asObserver() }
    var rx_viewDidLoad: Observable<Void> { return viewDidLoad.asObservable() }
}
