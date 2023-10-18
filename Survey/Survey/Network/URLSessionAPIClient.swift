//
//  URLSessionAPIClient.swift
//  Survey
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import Combine
import Foundation

protocol APIClient {
    associatedtype EndpointType: APIEndpoint
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error>
}

class URLSessionAPIClient<EndpointType: APIEndpoint>: APIClient {
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error> {
        var url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        endpoint.parameters?.forEach { url.append(queryItems: [URLQueryItem(name: $0.key, value: $0.value as? String)]) }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode == 400 {
                        throw APIError.errorResponce
                    }
                    throw APIError.invalidResponse
                }
                if data.isEmpty {
                    return "{}".data(using: .utf8) ?? data
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
