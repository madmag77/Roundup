import Foundation

protocol RestTransport {
    func get<S: Decodable, D>(endpoint: String, transform: @escaping (S)->(D), callback: @escaping (Response<D>) -> ())
    func put(endpoint: String, body: Data, callback: @escaping (Response<Int>) -> ())
}

struct RestTransportImpl: RestTransport {
    private let baseUrl = "https://api-sandbox.starlingbank.com/api/v2/"
    
    // TODO: Should be aquired from user login procedure
    private let token = "Bearer HERE YOU NEED TO COPY PASTE YOU SANDBOX TOKEN"
    
    // TODO: better to inject in order to test this struct
    private let session = URLSession.shared
    
    /// S - source network entity, D - destination/required domain entity
    func get<S: Decodable, D>(endpoint: String, transform: @escaping (S)->(D), callback: @escaping (Response<D>) -> ()) {
        let url = URL(string: baseUrl + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
         
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
       
        session.dataTask(with: request, completionHandler: { data, response, error in

            if error != nil || data == nil {
                callback(.error(.noNetwork))
                return
            }

            guard let response = response as? HTTPURLResponse,
                let mime = response.mimeType,
                mime == "application/json",
                let body = data,
                response.statusCode < 500
            else {
                 callback(.error(.serverError))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            switch response.statusCode {
                case 200..<300:
                   do {
                       let res = try decoder.decode(S.self, from: body)
                       callback(.success(transform(res)))
                   } catch {
                       callback(.error(.serverError))
                   }
                   return
                case 403:
                do {
                    let error = try decoder.decode(AuthError.self, from: body)
                    callback(.error(.clientError(ClientError(errors: [ErrorDescription(message: error.error)], success: false))))
                } catch {
                    callback(.error(.serverError))
                }
                return
               case 400..<500:
                   do {
                       let error = try decoder.decode(ClientError.self, from: body)
                       callback(.error(.clientError(error)))
                   } catch {
                       callback(.error(.serverError))
                   }
                   return
               default:
                    // Fail fast
                   fatalError("Shouldn't be such an error code")
            }
        }).resume()
    }
    
    func put(endpoint: String, body: Data, callback: @escaping (Response<Int>) -> ()) {
        let url = URL(string: baseUrl + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        session.uploadTask(with: request, from: body, completionHandler: { (data, response, error) in
            if error != nil || data == nil {
                callback(.error(.noNetwork))
                return
            }
            guard let response = response as? HTTPURLResponse,
                let mime = response.mimeType,
                mime == "application/json",
                let body = data,
                response.statusCode < 500
            else {
                 callback(.error(.serverError))
                return
            }

            switch response.statusCode {
                case 200..<300:
                    // For now we don't need to parse the answer body
                    callback(.success(response.statusCode))
                   return
               case 400..<500:
                   do {
                       let error = try JSONDecoder().decode(ClientError.self, from: body)
                       callback(.error(.clientError(error)))
                   } catch {
                       callback(.error(.serverError))
                   }
                   return
               default:
                   fatalError("Shouldn't be such an error code")
            }
        }).resume()
    }
}
