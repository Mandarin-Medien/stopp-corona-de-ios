//
//  SelfTestingSuspicionViewModel.swift
//  CoronaContact
//

import Foundation

class SelfTestingSuspicionViewModel: ViewModel {
    weak var coordinator: SelfTestingSuspicionCoordinator?

    init(with coordinator: SelfTestingSuspicionCoordinator) {
        self.coordinator = coordinator
    }

    func returnToMain() {
        coordinator?.popToRoot()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
