//
//  SelfTestingHintViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingHintViewModel: ViewModel {

    @Injected private var notificationService: NotificationService
    var defaults = UserDefaults.standard

    weak var coordinator: SelfTestingHintCoordinator?

    init(with coordinator: SelfTestingHintCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        defaults.performedSelfTestAt = Date()

        if defaults.isUnderSelfMonitoring {
            defaults.isUnderSelfMonitoring = false
            notificationService.removeSelfTestReminderNotification()
            NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
        }
    }

    func returnToMain() {
        coordinator?.popToRoot()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
