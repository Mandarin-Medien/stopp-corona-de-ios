//
//  MessageUpdateService.swift
//  CoronaContact
//

import Foundation
import Resolver
import Firebase

class MessageUpdateService {
    @Injected private var network: NetworkService
    @Injected private var crypto: CryptoService
    private var isUpdating = false

    func update() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            if self?.crypto.getPublicKey() != nil {
                self?.requestUpdate(lastDownloadedMessage: UserDefaults.standard.lastDownloadedMessage)
            }
        }
    }

    private func requestUpdate(lastDownloadedMessage: Int) {
        let firestore: Firestore = Firestore.firestore()

        guard let addressPrefix = crypto.getMyPublicKeyPrefix() else {
            return
        }

        guard !isUpdating else { return }
        isUpdating = true

        var ref: Query = firestore.collection("messages").whereField("pre", isEqualTo: addressPrefix)

        if lastDownloadedMessage != 0 {
            ref = ref.whereField("cAt", isGreaterThan: lastDownloadedMessage)
        }

        ref.getDocuments { (querySnapshot: QuerySnapshot?, _) in
            if querySnapshot != nil {
                DispatchQueue.global(qos: .default).async { self.handleResult(querySnapshot!) }
            }
        }
    }

    private func handleResult(_ result: QuerySnapshot) {
        var needToFetchMoreAfter = 0

        if result.count > 0 {
            var incomingMessages: [IncomingInfectionMessage] = []

            for document in result.documents {
                let data = document.data()

                let cAt = data["cAt"]! as? Int
                let message = data["content"]! as? String

                incomingMessages.append(IncomingInfectionMessage(identifier: cAt!, message: message!))
            }

            crypto.parseIncomingInfectionWarnings(incomingMessages) { result in
                if case .success(let lastMessage) = result {
                    if lastMessage > 0 {
                        UserDefaults.standard.lastDownloadedMessage = lastMessage
                        needToFetchMoreAfter = lastMessage
                    }
                }
            }
        }

        isUpdating = false
        if needToFetchMoreAfter > 0 {
            requestUpdate(lastDownloadedMessage: needToFetchMoreAfter)
        }
    }
}
