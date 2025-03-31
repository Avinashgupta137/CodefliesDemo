//
//  ApiClient.swift
//   PB TV OTT
//
//  Created by Avinash on 17/11/24.
//

import Foundation
import Alamofire

class ApiClient: NSObject {
    
    static var shared = ApiClient()
    private var ongoingRequests: [DataRequest] = []
    
    private override init() {}
    
    private func addRequest(_ request: DataRequest) {
        ongoingRequests.append(request)
    }
    
    private func removeRequest(_ request: DataRequest) {
        if let index = ongoingRequests.firstIndex(of: request) {
            ongoingRequests.remove(at: index)
        }
    }
    
    func callHttpMethod<T: Decodable>(
        apiendpoint: String,
        method: ApiMethod,
        param: [String: Any],
        model: T.Type,
        isMultipart: Bool = false, // Flag for multipart requests
        images: [String: Data] = [:], // Image data dictionary
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let fullUrl = (Constant.BASEURL + apiendpoint).trimmingCharacters(in: .whitespacesAndNewlines)
        print("API Endpoint: \(fullUrl)\nParams: \(param)\nMethod: \(method)")
        
        var apiMethod: HTTPMethod = .get
        switch method {
        case .get: apiMethod = .get
        case .post: apiMethod = .post
        case .put: apiMethod = .put
        case .delete: apiMethod = .delete
        }
        
        let headers = setHeader()
        
        if isMultipart {
            // Using Alamofire for multipart requests
            AF.upload(
                multipartFormData: { multipartFormData in
                    // Append text parameters
                    for (key, value) in param {
                        if let stringValue = value as? String {
                            multipartFormData.append(Data(stringValue.utf8), withName: key)
                        }
                    }
                    
                    // Append images
                    for (key, imageData) in images {
                        multipartFormData.append(imageData, withName: key, fileName: "\(key).jpg", mimeType: "image/jpeg")
                    }
                },
                to: fullUrl,
                method: .post,
                headers: headers
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    self.handleResponse(data: data, model: model, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Regular request handling
            let encoding: ParameterEncoding = apiMethod == .post ? JSONEncoding.default : URLEncoding.queryString
            let request = AF.request(fullUrl, method: apiMethod, parameters: param, encoding: encoding, headers: headers)
            
            self.addRequest(request)
            request.response { response in
                self.removeRequest(request)
                guard let data = response.data else {
                    let error = NSError(domain: "No Data", code: 500, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                if let error = response.error {
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                self.handleResponse(data: data, model: model, completion: completion)
            }
        }
    }

    private func createMultipartBody(parameters: [String: Any], boundary: String) -> Data {
        var body = Data()

        for (key, value) in parameters {
            if let dataValue = value as? Data { // Binary data (e.g., image, file)
                let filename = "\(key).jpg" // Adjust extension based on the data type
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(dataValue)
                body.append("\r\n".data(using: .utf8)!)
            } else if let stringValue = value as? String { // Text parameters
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(stringValue)\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    
    private func handleResponse<T: Decodable>(
        data: Data,
        model: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            let decodedResponse = try JSONDecoder().decode(model, from: data)
            completion(.success(decodedResponse))
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    
    func cancelAllRequests() {
        for request in ongoingRequests {
            request.cancel()
        }
        ongoingRequests.removeAll()
    }
    
    func callHttpMethod<T: Decodable>(
        apiendpoint: String,
        method: ApiMethod,
        param: [String: Any],
        model: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var apiMethod: HTTPMethod = .get
        var urlEncoding: ParameterEncoding = URLEncoding.queryString
        let header = setHeader()
        switch method {
        case .delete:
            return
        case .put:
            apiMethod = .put
        case .post:
            apiMethod = .post
        case .get:
            apiMethod = .get
        }
        
        if apiMethod == .post {
            urlEncoding = JSONEncoding.default
        } else {
            urlEncoding = URLEncoding.queryString
        }
        
        let fullUrl = (Constant.BASEURL + apiendpoint).trimmingCharacters(in: .whitespacesAndNewlines)
        print("Api:--", fullUrl)
        print("Param:--", param)
        print("Method:--", apiMethod.rawValue)
        print("Header Request:--\n", header ,"\n --------------")
        
        let request = AF.request(fullUrl, method: apiMethod, parameters: param, encoding: urlEncoding, headers: header)
        self.addRequest(request)
        
        request.response { response in
            self.removeRequest(request)
            print("Response:--", response.response?.statusCode ?? 00)
            
            switch response.result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("\(apiendpoint) Pretty-printed JSON response:")
                            print(jsonString)
                        }
                      
                    } else {
                        print("Invalid JSON format")
                    }
                    let decodedResponse = try JSONDecoder().decode(model, from: data!)
                    completion(.success(decodedResponse))
                } catch {
                    print("JSON Serialization error: \(error as NSError)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let afError = error.asAFError, afError.isExplicitlyCancelledError {
                    print("Request cancelled: \(error.localizedDescription)")
                    
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func callmethodMultipart<T: Decodable>(
        apiendpoint: String,
        method: ApiMethod,
        param: [String: Any],
        model: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ){
      
        var apiMethod: HTTPMethod = .get
        var urlEncoding: ParameterEncoding = URLEncoding.queryString
        let header = setHeader()
        switch method {
        case .delete:
            return
        case .put:
            apiMethod = .put
        case .post:
            apiMethod = .post
        case .get:
            apiMethod = .get
        }
        
        if apiMethod == .post {
            urlEncoding = JSONEncoding.default
        } else {
            urlEncoding = URLEncoding.queryString
        }
        
        let fullUrl = (Constant.BASEURL + apiendpoint).trimmingCharacters(in: .whitespacesAndNewlines)
        print("Api:--", fullUrl)
        print("Param:--", param)
        print("Method:--", apiMethod.rawValue)
        print("Header Request:--\n", header ,"\n --------------")

        AF.upload(multipartFormData: createBodyWithParameters(parameters: param),to: fullUrl,headers: header)
            .uploadProgress  { progress in
                      print("Upload Progress: \(progress.fractionCompleted)")
                  }
            .response { response in
                // self.removeRequest(requests)
               
                print("Response:--", response.response?.statusCode ?? 00)
                
                switch response.result {
                case .success(let data):
               
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("\(apiendpoint) Pretty-printed JSON response:")
                            print(jsonString)
                        }
                      
                    } else {
                        print("Invalid JSON format")
                    }
                    let decodedResponse = try JSONDecoder().decode(model, from: data!)
                    completion(.success(decodedResponse))
                } catch {
                    print("JSON Serialization error: \(error as NSError)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let afError = error.asAFError, afError.isExplicitlyCancelledError {
                    print("Request cancelled: \(error.localizedDescription)")
                    
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    
    func setHeader() -> HTTPHeaders {
        let customerKey = "ck_c3f9f46df11d46c20de4b520a4fd296abbe25031"
        let customerSecret = "cs_605d01d018d960b70a4221818edd3404384aec85"
        
 
        let credentials = "\(customerKey):\(customerSecret)"
        if let credentialData = credentials.data(using: .utf8) {
            let base64Credentials = credentialData.base64EncodedString()
            let headers: HTTPHeaders = [
                "Authorization": "Basic \(base64Credentials)",
                "Content-Type": "application/json"
            ]
            return headers
        }
        
        return [:] 
    }
    
    
    func createBodyWithParameters(parameters: [String: Any], fileURL: URL? = nil, filename: String? = nil) -> MultipartFormData {
        _ = Data()
        var multipartData = MultipartFormData()
        for (key, value) in parameters {
            if value is NSArray {
                let str = APIManager.json(from: (value as AnyObject))
                multipartData.append((str?.data(using: .utf8)!)!, withName: key )
            } else {
                multipartData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key )
            }
        }
        return multipartData
    }
}


enum ApiMethod {
    case get, post, put, delete
}

enum CustomError: Error {
    case someError
    case anotherError(String)
}

class APIManager: NSObject {
    
    class func json(from object: AnyObject) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    

}
