//
//  SpotifyAPI.swift
//  spotify-ios-quick-start
//
//  Created by Nicole Howard on 6/6/19.
//  Copyright © 2019 Nicole Howard. All rights reserved.
//

import Foundation

struct SpotifyAPI {
    
    static func getUserInfo(accessToken: String, completion: @escaping (User?) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me")
        var request = URLRequest(url: url!)
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // inside completion handler
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("We got some data")
                print(dataString)
                if let user = parseUserData(fromData: data) {
                    DispatchQueue.main.async {
                        completion(user)
                    }
                }
            }
            else {
                if let error = error {
                    print("Error getting photos JSON response \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            
        }
        task.resume()
    }
    
    //TODO: get the image! 
    static func parseUserData(fromData data: Data) -> User? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDict = jsonObject as? [String: Any], let name = jsonDict["display_name"] as? String, let id = jsonDict["id"] as? String, let uri = jsonDict["uri"] as? String else {
                print("didn't work")
                return nil
            }
            print(jsonDict)
            return User(uri: uri, imageUrl: "", displayName: name, id: id)
            
        } catch {
            print("couldnt make json object")
        }
        return nil
    }
}
