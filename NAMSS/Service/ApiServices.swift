//
//  ApiServices.swift
//  SchoolApp
//
//  Created by Hemant Raj  Singh on 2/20/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

func getData( url:String)->String{
    let requestUrl:URL = URL(string: url)!
    var urlRequest:URLRequest = URLRequest(url:requestUrl as URL)
    urlRequest.httpMethod = "GET"
    let session = URLSession.shared
    var jsonDataString:String = ""
    let task = session.dataTask(with: urlRequest) { (data, response, responseError) in
        DispatchQueue.main.async {
            do{
                if let error = responseError{
                    print(error)
                    jsonDataString = "error"
                }else if let jsonData = data{
                    let data1 = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data:data1, encoding:String.Encoding.utf8)
                    jsonDataString = convertedString!
                }
            }
            catch{
                jsonDataString = "error"
            }
        }
    };
    
    task.resume()
    
    return jsonDataString
    
}

func postData( url:String,jsonString:String)->String{
    let requestUrl:URL = URL(string: url)!
    var request:URLRequest = URLRequest(url:requestUrl as URL)
    request.httpMethod = "POST"
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["Content-Type"] = "application/json"
    request.allHTTPHeaderFields = headers
    
    let data = jsonString.data(using: String.Encoding.utf8)
        request.httpBody = data
    print (data!)
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    var jsonDataString:String = ""
    let task = session.dataTask(with: request) { (data, response, responseError) in
        DispatchQueue.main.async {
            do{
                if let error = responseError{
                    print(error)
                    jsonDataString = "error"
                }else if let jsonData = data{
                    let data1 = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data:data1, encoding:String.Encoding.utf8)
                    jsonDataString = convertedString!
                }
            }
            catch{
                jsonDataString = "error"
            }
        }
    };
    
    task.resume()
    
    return jsonDataString
    
}

func fnGetApi(url:String, completionHandler: @escaping (Bool,JSON)->Void) -> Void{
    
    var res:JSON? = nil
    Alamofire.request(url, method: .get)
        .validate { request, response, data in
            return .success
        }
        .responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    res = JSON(value)
                    if(res!["ExceptionType"].stringValue == "" && res!["Message"].stringValue == ""){
                        completionHandler(true,res ?? [])
                    }else{
                        completionHandler(false,res ?? [])
                    }
                }
            case .failure(let error):
                print(error)
                completionHandler(false,res ?? [])
            }
    }
}

func fnPostApi(url:String, completionHandler: @escaping (Bool,JSON)->Void) -> Void{
    
    var res:JSON? = nil
    Alamofire.request(url, method: .post)
        .validate { request, response, data in
            return .success
        }
        .responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    res = JSON(value)
                    if(res!["ExceptionType"].stringValue == "" && res!["Message"].stringValue == ""){
                        completionHandler(true,res ?? [])
                    }else{
                        completionHandler(false,res ?? [])
                    }
                }
            case .failure(let error):
                print(error)
                completionHandler(false,res ?? [])
            }
    }
}

func fnPostApiWithJson(url:String, json:JSON, completionHandler: @escaping (Bool,JSON)->Void) -> Void{
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    do{
    request.httpBody = try json.rawData()
    }
    catch{
        
    }
    
    var res:JSON? = nil
    Alamofire.request(request)
        .validate { request, response, data in
            return .success
        }
        .responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    res = JSON(value)
                    if(res!["ExceptionType"].stringValue == "" && res!["Message"].stringValue == ""){
                        completionHandler(true,res ?? [])
                    }else{
                        completionHandler(false,res ?? [])
                    }
                }
            case .failure(let error):
                print(error)
                completionHandler(false,res ?? [])
            }
    }
}



