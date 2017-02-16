//
//  Interactor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 16/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

public protocol InteractorType {
    associatedtype I
    associatedtype O

    var rx_input: AnyObserver<I> { get }
    var rx_output: Observable<O> { get }
}

public class AnyInteractor<InElementType, OutElementType>: InteractorType {
    public typealias O = OutElementType
    public typealias I = InElementType
    public typealias UseCaseImpl = (InElementType) -> Observable<OutElementType>
    
    private let rx_outputSubject = PublishSubject<OutElementType>()
    private let disposeBag = DisposeBag()
    
    public var rx_output: Observable<OutElementType> {
        return rx_outputSubject.asObservable()
    }
    
    public var rx_input: AnyObserver<InElementType> {
        return AnyObserver { event in
            switch event {
            case .next(let element):
                self.executeUseCaseWithInput(element)
                        .subscribe(onNext: { result in
                            self.rx_outputSubject.onNext(result)
                        }).addDisposableTo(self.disposeBag)
            default:
                // NOTE: Interactors shouldn't receive onCompleted or onError
                break
            }
        }
    }
    
    let executeUseCaseWithInput: UseCaseImpl
    init(_ useCase: @escaping UseCaseImpl) {
        self.executeUseCaseWithInput = useCase
    }
}