//
//  HomeScreenView.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

struct HomeScreenViewModel {
    let weight: Double
    let height: UInt
    let bodyFat: Double
    let muscle: Double
    
    static func empty() -> HomeScreenViewModel {
        return HomeScreenViewModel(weight: 0, height: 0, bodyFat: 0, muscle: 0)
    }
}

protocol IHomeScreenView: class {
    var viewModel: HomeScreenViewModel { get set }
    var rx_viewDidLoad: Observable<Void> { get }

    func viewDidLoad()
}

extension IHomeScreenView {
    var rx_viewModel: AnyObserver<HomeScreenViewModel> {
        return AnyObserver() { event in
            switch event {
            case .next(let element): self.viewModel = HomeScreenViewModel(weight: element.weight,
                                                                          height: element.height,
                                                                          bodyFat: element.bodyFat,
                                                                          muscle: element.muscle)
            default: break
            }
        }
    }
}

class HomeScreenView: IHomeScreenView {
    var viewModelVariable = Variable<HomeScreenViewModel>(HomeScreenViewModel.empty())
    var viewModel: HomeScreenViewModel {
        get { return viewModelVariable.value }
        set { viewModelVariable.value = newValue }
    }
    
    var viewDidLoadSubject = PublishSubject<Void>()
    var rx_viewDidLoad: Observable<Void> {
        return viewDidLoadSubject.asObservable()
    }
    
    func viewDidLoad() {
        viewDidLoadSubject.asObserver().onNext()
    }
}
