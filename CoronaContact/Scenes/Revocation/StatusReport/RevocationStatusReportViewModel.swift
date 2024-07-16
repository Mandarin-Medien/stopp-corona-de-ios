//
//  RevocationStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    dateFormatter.dateFormat = "revocation_report_status_date_format".localized
    return dateFormatter.string(from: date)
}

class RevocationStatusReportViewModel: ViewModel {

    @Injected private var flowController: RevocationFlowController

    weak var coordinator: RevocationStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    var dateLabel: String? {
        guard let date = UserDefaults.standard.isProbablySickAt else {
            return nil
        }

        return dateString(date)
    }

    init(with coordinator: RevocationStatusReportCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }

        flowController.submit { [weak self] result in
            completion()

            switch result {
            case .failure(let error):
                self?.coordinator?.showErrorAlert(
                    title: error.displayableError.title,
                    error: error.displayableError.description,
                    closeAction: { _ in
                        if error.personalDataInvalid {
                            self?.coordinator?.goBackToPersonalData()
                        } else if error.tanInvalid {
                            self?.coordinator?.goBackToTanConfirmation()
                        }
                    }
                )
            case .success:
                self?.coordinator?.showConfirmation()
            }
        }
    }

    func reportButtonTapped() {
        coordinator?.showConfirmation()
    }
}
