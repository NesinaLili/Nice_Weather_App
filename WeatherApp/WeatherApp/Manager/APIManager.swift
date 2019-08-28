//
//  APIManager.swift
//  WeatherApp
//
//  Created by Лилия on 8/25/19.
//  Copyright © 2019 Liliia. All rights reserved.
//

import Foundation

typealias JSONTask = URLSessionDataTask
typealias JSONcomplectionHandler = ([String: AnyObject]?, HTTPURLResponse?, Error?) -> Void

protocol JSONDecodable {
    init?(JSON: [String: AnyObject])
}

protocol FinalURLPoint {
    var baseURL: URL { get }
    var path: String { get }
    var request: URLRequest { get }
}

enum APIResult<T> {
    case Success(T)
    case Failure(Error)
}

protocol APIManager {
    
    var  sessionConfiguration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
//    func JSONTaskWith(request: URLRequest, complectionHandler: JSONcomplectionHandler) -> JSONTask
    func fetch<T: JSONDecodable>(request: URLRequest, parse: @escaping ([String: AnyObject]) -> T?, complectionHandler: @escaping (APIResult<T>) -> Void)
}

extension APIManager {
    func JSONTaskWith(request: URLRequest, complectionHandler: @escaping JSONcomplectionHandler) -> JSONTask {
       
        let dataTask = session.dataTask(with: request) { (data, response, error) in
           
            guard let HTTPResponse = response as? HTTPURLResponse else {
               
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("MissingHTTPResponseError", comment: "")
                ]
                
                
                let error = NSError(domain: MyNetworkingErrorDomain, code: 100, userInfo: userInfo)
                
                
               complectionHandler(nil, nil, error)
                
                return
            }
        
            if data == nil {
                if let error = error {
                    complectionHandler(nil, HTTPResponse, error)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        complectionHandler(json, HTTPResponse, nil)
                    } catch let error as NSError {
                        complectionHandler(nil, HTTPResponse, error)
                    }
                default:
                    print("We have got response status \(HTTPResponse.statusCode)")
                }
            }
        
        }
        return dataTask
    }
    
    func fetch<T>(request: URLRequest, parse: @escaping ([String: AnyObject]) -> T?, complectionHandler:  @escaping (APIResult<T>) -> Void) {
        
        let dataTask = JSONTaskWith(request: request) { (json, response, error) in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        complectionHandler(.Failure(error))
                    }
                    return
                }
                
                if let value = parse(json) {
                    complectionHandler(.Success(value))
                } else {
                    let error = NSError(domain: MyNetworkingErrorDomain, code: 200, userInfo: nil)
                    complectionHandler(.Failure(error))
                }
            }
        }
        dataTask.resume()
    }
    
}
