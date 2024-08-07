//
//  NetworkClient.swift
//  CoronaContact
//

import Foundation
import Moya

/**
 Low level network interface to Moya.

 Do not use directly, use `NetworkService` instead.
 */
final class NetworkClient {

    typealias PayloadCompletion<Payload> = (_ result: Result<Payload, NetworkError>) -> Void

    var handleStatusCode: ((Int) -> Void)?

    private let provider = MoyaProvider<NetworkEndpoint>(session: NetworkSession.session())
    private let log = LoggingService.self

    func requestPlain(_ target: NetworkEndpoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        provider.request(target) { [weak self] result in
            switch result {
            case .success(let response):
                self?.handleStatusCode?(response.statusCode)

                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    completion(.success(filteredResponse.data))
                    self?.log.verbose(response.detailedDebugDescription, context: .network)

                } catch let error {
                    let statusCode = HTTPStatusCode(statusCode: response.statusCode)
                    if statusCode == .notModified {
                        completion(.failure(.notModifiedError))
                        return
                    }

                    let errorResponse = response.parseError()

                    completion(.failure(.unknownError(statusCode, error, errorResponse)))
                    self?.log.error(response.detailedDebugDescription, context: .network)
                }

            case .failure(let error):
                self?.log.error(error.detailedDebugDescription, context: .network)
                self?.handleStatusCode?(error.errorCode)

                let errorResponse = error.response?.parseError()
                let statusCode = HTTPStatusCode(statusCode: error.errorCode)

                completion(.failure(.unknownError(statusCode, error, errorResponse)))
            }
        }
    }

    func request<Payload: Decodable>(_ target: NetworkEndpoint, completion: @escaping (Result<Payload, NetworkError>) -> Void) {
        provider.request(target) { [weak self] result in
            switch result {
            case .success(let response):

                self?.handleStatusCode?(response.statusCode)

                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let parsedResponse: Result<Payload, NetworkError> = filteredResponse.parseJSON()
                    completion(parsedResponse)
                    self?.log.verbose(response.detailedDebugDescription, context: .network)

                } catch let error {
                   let statusCode = HTTPStatusCode(statusCode: response.statusCode)
                   if statusCode == .notModified {
                       completion(.failure(.notModifiedError))
                       return
                   }

                   let errorResponse = response.parseError()

                   completion(.failure(.unknownError(statusCode, error, errorResponse)))
                   self?.log.error(response.detailedDebugDescription, context: .network)
               }

            case .failure(let error):
                self?.log.error(error.detailedDebugDescription, context: .network)
                self?.handleStatusCode?(error.errorCode)

                let errorResponse = error.response?.parseError()
                let statusCode = HTTPStatusCode(statusCode: error.errorCode)

                completion(.failure(.unknownError(statusCode, error, errorResponse)))
            }
        }
    }
}

private extension Response {

    var detailedDebugDescription: String {
        var output = [String]()

        // Response presence check
        if let responseUrl = response?.url {
            output.append("URL: \(responseUrl.absoluteString).")
        } else {
            output.append("Received empty network response.")
        }

        output.append("Status Code: \(statusCode), Data Length: \(data.count)")

        return output.joined(separator: " ")
    }
}

private extension MoyaError {

    var detailedDebugDescription: String {
        if let moyaResponse = response {
            return moyaResponse.detailedDebugDescription
        }

        return errorDescription ?? ""
    }
}
