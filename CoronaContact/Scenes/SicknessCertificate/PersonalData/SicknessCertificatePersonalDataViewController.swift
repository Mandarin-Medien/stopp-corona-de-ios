//
//  SicknessCertificatePersonalDataViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SicknessCertificatePersonalDataViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators {

    private var keyboardAdjustingBehavior: KeyboardAdjustingBehavior?

    @IBOutlet weak var scrollView: UIScrollView!

    var viewModel: SicknessCertificatePersonalDataViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        let behavior = KeyboardAdjustingBehavior(scrollView: scrollView)
        behavior.keyboardPadding = 40
        keyboardAdjustingBehavior = behavior

        title = "sickness_certificate_personal_data_title".localized
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        viewModel?.composePersonalData = {
            return PersonalData(mobileNumber: "")
        }
        
        showActivity()
        viewModel?.goToNext(completion: { [weak self] in
            self?.hideActivity()
        })
    }
}
