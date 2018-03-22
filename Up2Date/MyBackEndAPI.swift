//
//  MyBackEndAPI.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/16/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import Foundation
import Stripe


internal enum BackEndResult {
    case success([String: Any])
    case failure(BackEndAPI.Error)
}

class BackEndAPI {
    
    enum Error: Swift.Error {
        case http(HTTPURLResponse)
        case system(Swift.Error)
    }

    
    
    func postCreateCustomer(token: STPToken, email: String, completion: @escaping (BackEndResult) -> ()) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://api.stripe.com/v1/customers")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer sk_live_MDAKgNdro4icEVfELFuADCid", forHTTPHeaderField: "Authorization")
        
        let payload = "email=\(email)&description=Customerfor\(email)&source=\(token.tokenId)".data(using: String.Encoding.ascii, allowLossyConversion: false)
        
        //print(payload)
        request.httpBody = payload
        
        let task = session.dataTask(with: request) { (optionalData, optionalResponse, optionalError) in
            
            if let data = optionalData {
                print(data)
                completion(self.processPost(data: data, error: optionalError))
                
                
            } else if let response = optionalResponse {
                let error = Error.http(response as! HTTPURLResponse)
                completion(.failure(error))
                
                
                print("optionalResponse: \(response)")
                
            } else {
                completion(.failure(.system(optionalError!)))
            }
        }
        task.resume()
    }
    
    func postUpdateCustomerCard(token: STPToken, customerId: String, completion: @escaping (BackEndResult) -> ()) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://api.stripe.com/v1/customers/\(customerId)")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer sk_live_MDAKgNdro4icEVfELFuADCid", forHTTPHeaderField: "Authorization")
        
        let payload = "default_source=\(token.tokenId)".data(using: String.Encoding.ascii, allowLossyConversion: false)
        
        //print(payload)
        request.httpBody = payload
        
        let task = session.dataTask(with: request) { (optionalData, optionalResponse, optionalError) in
            
            if let data = optionalData {
                print(data)
                completion(self.processPost(data: data, error: optionalError))
                
                
            } else if let response = optionalResponse {
                let error = Error.http(response as! HTTPURLResponse)
                completion(.failure(error))
                
                
                print("optionalResponse: \(response)")
                
            } else {
                completion(.failure(.system(optionalError!)))
            }
        }
        task.resume()
    }
    
    func postRemoveCustomerCard(customerId: String, completion: @escaping (BackEndResult) -> ()) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://api.stripe.com/v1/customers/\(customerId)")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer sk_live_MDAKgNdro4icEVfELFuADCid", forHTTPHeaderField: "Authorization")
        
        let payload = "default_source=null".data(using: String.Encoding.ascii, allowLossyConversion: false)
        
        //print(payload)
        request.httpBody = payload
        
        let task = session.dataTask(with: request) { (optionalData, optionalResponse, optionalError) in
            
            if let data = optionalData {
                print(data)
                completion(self.processPost(data: data, error: optionalError))
                
                
            } else if let response = optionalResponse {
                let error = Error.http(response as! HTTPURLResponse)
                completion(.failure(error))
                
                
                print("optionalResponse: \(response)")
                
            } else {
                completion(.failure(.system(optionalError!)))
            }
        }
        task.resume()
    }

    
    func postTokenToHeroku(token: STPToken, amount: Int, description: String, email: String, completion: @escaping (BackEndResult) -> ()) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://fashion-server.herokuapp.com/upTwoDate/api.stripe.com")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let payload = try! JSONSerialization.data(withJSONObject: ["amount": amount, "currency": "usd", "description": description, "receipt_email": email, "source": token.tokenId], options: [])
        print(payload)
        request.httpBody = payload
        
        let task = session.dataTask(with: request) { (optionalData, optionalResponse, optionalError) in
            
            if let data = optionalData {
                print(data)
                completion(self.processPost(data: data, error: optionalError))
                
                
            } else if let response = optionalResponse {
                let error = Error.http(response as! HTTPURLResponse)
                completion(.failure(error))
                
                
                print("optionalResponse: \(response)")
                
            } else {
                completion(.failure(.system(optionalError!)))
            }
        }
        task.resume()
    }
    
    func postTokenToHeroku2(customerId: String, amount: Int, description: String, email: String, completion: @escaping (BackEndResult) -> ()) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://fashion-server.herokuapp.com/card/api.stripe.com")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let payload = try! JSONSerialization.data(withJSONObject: ["amount": amount, "currency": "usd", "description": description, "receipt_email": email, "customer": customerId], options: [])
        print(payload)
        request.httpBody = payload
        
        let task = session.dataTask(with: request) { (optionalData, optionalResponse, optionalError) in
            
            if let data = optionalData {
                print(data)
                completion(self.processPost(data: data, error: optionalError))
                
                
            } else if let response = optionalResponse {
                let error = Error.http(response as! HTTPURLResponse)
                completion(.failure(error))
                
                
                print("optionalResponse: \(response)")
                
            } else {
                completion(.failure(.system(optionalError!)))
            }
        }
        task.resume()
    }
    
    func processPost(data: Data, error: Swift.Error?) -> BackEndResult {
        if let object = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
            return .success(object)
        } else {
            return .failure(.system(error!))
        }
    }
}

