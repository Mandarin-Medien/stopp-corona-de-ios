//
//  NetworkService.swift
//  CoronaContact
//

import Foundation
import Resolver
/**
 Performs network requests

 Can be injected into classes with the `@Injected` property wrapper like so:
 ```
 @Injected var networkService: NetworkService
 ```
 */
final class NetworkService {

    @Injected var appUpdateService: AppUpdateService
    @Injected var rsa: RSASwiftGenerator

    private let client: NetworkClient

    init() {
        self.client = NetworkClient()
        self.client.handleStatusCode = { [weak self] statusCode in
            self?.filterStatusCode(statusCode)
        }
    }

    func fetchConfiguration(completion: @escaping (Result<Data, NetworkError>) -> Void) {
        client.requestPlain(.configuration, completion: completion)
    }

    func fetchInfectionMessages(fromId: String? = nil,
                                addressPrefix: String,
                                completion: @escaping (Result<InfectionMessagesResponse, NetworkError>) -> Void) {
        client.request(.infectionMessages(fromId: fromId, addressPrefix: addressPrefix), completion: completion)
    }

    func sendInfectionInfo(_ infectionInfo: InfectionInfo, completion: @escaping (Result<SuccessResponse, InfectionInfoError>) -> Void) {
        client.request(.infectionInfo(infectionInfo)) { (result: Result<SuccessResponse, NetworkError>) in
            switch result {
                case let .failure((.parsingError(_))):
                    completion(.success(SuccessResponse( timestamp: Date(), status: HTTPStatusCode(statusCode: 200), message: "OK")))
                case let .failure((.unknownError(statusCode, _, _))):
                    completion(.failure(self.parseInfectionInfoError(statusCode: statusCode)))
                case .failure:
                    completion(.failure(self.parseInfectionInfoError(statusCode: nil)))
                case .success(let response):
                    completion(.success(response))
                }
        }
    }
    
    func requestTan(mobileNumber: String, completion: @escaping (Result<RequestTanResponse, DisplayableError>) -> Void) {
        let uuid: String = UIDevice.current.identifierForVendor!.uuidString
        let data = rsa.sha256(data: uuid.data(using: String.Encoding.utf8)!)
 
        var sha256String =  data.hexEncodedString()

        var positionNumber = 0
        for charN in sha256String {
            if charN.isASCII && charN.isNumber {
                let intVal = Int(String(charN)) ?? 0
                var fC : Character?
                var positionChar = 0;

                for char in sha256String {

                    if !char.isNumber {
                        var charVal = Int(char.asciiValue ?? 0) + intVal
                         if charVal > 122 {
                             charVal -= 26
                         }
                         fC = Character(UnicodeScalar(charVal)!)
                         break
                    }
                    positionChar+=1
                }
                if let fCN = fC {
                    let firstPart = sha256String.substring( from:0, length:positionNumber + positionChar + intVal)
                    let secondPart = sha256String.substring(from:positionNumber + positionChar + intVal, length: sha256String.count - positionNumber + positionChar + intVal)

                    sha256String = firstPart! + String(fCN) + secondPart!
                   break
                }
            }
            positionNumber+=1
        }
        
        let requestTan = RequestTan(phoneNumber: sha256String)
        client.request(.requestTan(requestTan)) { (result: Result<RequestTanResponse, NetworkError>) in
            switch result {
            case let .failure((.unknownError(statusCode, _, _))):
              completion(.failure(self.parseTanEror(statusCode: statusCode)))
            case .failure:
              completion(.failure(self.parseTanEror(statusCode: nil)))
            case .success(let response):
              completion(.success(response))
            }
        }
    }
}


extension Data {
   func hexEncodedString() -> String {
       return map { String(format: "%02hhx", $0) }.joined()
   }
}

extension String {
    func toHexEncodedString() -> String {
        return unicodeScalars.map { .init($0.value, radix: 16) } .joined()
    }
}
