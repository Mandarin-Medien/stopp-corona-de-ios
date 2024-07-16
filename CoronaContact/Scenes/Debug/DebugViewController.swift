//
// DebugViewController.swift
// CoronaContact
//

import UIKit
import Reusable
import SwiftRichString
import Resolver

class DebugViewController: UIViewController, StoryboardBased, ViewModelBased, Reusable {
    @Injected private var crypto: CryptoService

    var viewModel: DebugViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()

    }

    @IBAction func close(_ sender: Any) {
        viewModel?.close()
    }

    @IBAction func shareLogButtonTapped(_ sender: Any) {
        viewModel?.shareLog()
    }

    @IBAction func resetLogButtonTapped(_ sender: Any) {
        viewModel?.resetLog()
    }

    @IBAction func addHandshakeAction(_ sender: Any) {
        viewModel?.addHandShakes()
    }

    @IBAction func addRedInfectionMessage(_ sender: Any) {
        viewModel?.addRedInfectionMessage()
    }

    @IBAction func addYellowInfectionMessage(_ sender: Any) {
        viewModel?.addYellowInfectionMessage()
    }

    @IBAction func scheduleTestNotifications(_ sender: Any) {
        viewModel?.scheduleTestNotifications()
    }

    @IBAction func attestSickness(_ sender: Any) {
        viewModel?.attestSickness()
    }

    @IBAction func isUnderSelfMonitoringTapped(_ sender: Any) {
        UserDefaults.standard.isUnderSelfMonitoring = true
        UserDefaults.standard.performedSelfTestAt = Date()
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }

    @IBAction func isProbablySickTapped(_ sender: Any) {
        UserDefaults.standard.isProbablySick = true
        UserDefaults.standard.isProbablySickAt = Date()
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }
}
