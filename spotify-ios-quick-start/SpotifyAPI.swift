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
                print("Data was recieved from API call.")
                
                if let user = parseUserData(fromData: data) {
                    DispatchQueue.main.async {
                        completion(user)
                    }
                }
            }
            else {
                if let error = error {
                    print("Error getting JSON response \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            
        }
        task.resume()
    }
    
    
    static func parseUserData(fromData data: Data) -> User? {
        do {
            // extract the information that we need
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDict = jsonObject as? [String: Any], let photoObject = jsonDict["images"] as? [[String: Any]], let name = jsonDict["display_name"] as? String, let id = jsonDict["id"] as? String, let uri = jsonDict["uri"] as? String else {
                print("Couldn't parse JSON user data.")
                return nil
            }
            // extract the info from the photo JSON array, get the first image URL
            guard let firstPhotoDict = photoObject[0] as? [String: Any], let firstPhotoURL = firstPhotoDict["url"] as? String else {
                print("Couldn't retreive photo url.")
                return User(uri: uri, imageUrl: nil, displayName: name, id: id)
            }
            
            print("Successfully created a user object")
            return User(uri: uri, imageUrl: firstPhotoURL, displayName: name, id: id)
            
        } catch {
            print("Couldn't make JSON objec from data.")
        }
        return nil
    }
    
    static func fetchImage(fromURLString: String, completion: @escaping (UIImage?) -> Void) {
        let url = URL(string: fromURLString)!
        // now we want to get Data back from a request using this url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                print("we got a UIImage!!")
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            else {
                if let error = error {
                    print("Error getting an image \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}
