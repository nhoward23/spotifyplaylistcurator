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
            if let data = data /*, let dataString = String(data: data, encoding: .utf8) */{
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
            
            // if we made it here then we have successfully parsed the json
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
    
    // this needs to have the completion handler that is run when a playlist is received.
    // this will have main loop that is run until all saved songs are received.
    static func generatePlaylist(withNextURL next: String?, start: Bool, completion: @escaping (Playlist?) -> Void) {
        
        // if start if true, generate the request by "hand"
        
        // else start is false, the process has already begun
        
        // if next is nil, then we are done.
        
            // call completion with the playlist object
        
        // else, we still need to retrieve more songs.
        
            // use the next url to fetch the saved songs.
            // in completion append the lists to playlist object
        
        
    }
    
    static func generateRequest(withNext next: String, accessToken: String) -> URLRequest? {
        
        guard let url = URL(string: next) else {
            print("There are no more requests needed.")
            return nil
        }
        // request stuff
        var request = URLRequest(url: url)
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    static func runFetchSavedSongsTask(withRequest request: URLRequest, accessToken: String, masterPlaylist: Playlist, completion: @escaping (Playlist) -> Void) {
        // start the session
        var newPlaylist = Playlist(songIDs: [], songPopularities: [], datesAdded: [], next: "")
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // in callback, was there an error?
            if let error = error { print("There was an error with the Fetching the Saved Songs Request: ", error) }
            
            // get the data
            if let data = data, let partialPlaylist = parsePlaylistData(data: data) {
                
                // Add the partial playlist to the master playlist
                newPlaylist.songIDs = masterPlaylist.songIDs + partialPlaylist.songIDs
                newPlaylist.songPopularities = masterPlaylist.songPopularities + partialPlaylist.songPopularities
                newPlaylist.datesAdded = masterPlaylist.datesAdded + partialPlaylist.datesAdded
                newPlaylist.next = partialPlaylist.next
                
//                // Do we need to run the request again?
//                guard let url = URL(string: newPlaylist.next) else {
//                    print("There are no more songs to retrive.")
//                    // may have to change this
//                    return
//                }
                
                // Yes, yes we do
                print("Running Request.")
                guard let newRequest = generateRequest(withNext: newPlaylist.next, accessToken: accessToken) else { return }
                runFetchSavedSongsTask(withRequest: newRequest, accessToken: accessToken, masterPlaylist: newPlaylist, completion: {(playlist) -> Void in
                    
                    print("Recieved a portion of the Saved Songs.")
                    completion(playlist)
                })
                
            // ParsingPlaylistData failed. This should end the recursive call.
            } else {
                print("Partial Playlist was not generated.")
                // fire the completion to end recusive retrieval.
                completion(masterPlaylist)
            }
        }
        task.resume()
    }

    
    // initiation
    static func fetchSavedSongs(accessToken: String, completion: @escaping (Playlist?) -> Void) {
        
        // Set up the url and request
        let baseURL = URL(string: "https://api.spotify.com/v1/me/tracks")
        var components = URLComponents(url: baseURL!, resolvingAgainstBaseURL: true)
        let queryItemLimit = URLQueryItem(name: "limit", value: "50")
        let queryItemOffset = URLQueryItem(name: "offset", value: "0")
        components!.queryItems = [queryItemLimit, queryItemOffset]
        let url = components!.url!
        var request = URLRequest(url: url)
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        // Begin retrieval of all saved songs.
        runFetchSavedSongsTask(withRequest: request, accessToken: accessToken, masterPlaylist: Playlist(songIDs: [], songPopularities: [], datesAdded: [], next: ""), completion: {(masterPlaylist) -> Void in
            
            // callback has been fired. Song Retrieval process has completed.
            print("Saved Song retrieval is complete.")
            
            // fire this call back to get playlist to ViewController.
            DispatchQueue.main.async {
                completion(masterPlaylist)
            }
        })
    }
    
    static func parsePlaylistData(data: Data) -> Playlist? {
        do {
            //TODO: doesn't retrieve the songs if nextURL is null, so we need to update this function.
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDict = json as? [String : Any], let offset = jsonDict["offset"] as? Int, let total = jsonDict["total"] as? Int, let nextURL = jsonDict["next"] as? String, let songs = jsonDict["items"] as? [[String: Any]] else {
                print("Next url was not found.")
                return nil
            }
            //print(total)
            //print(offset)
            print("next: ", nextURL)
            
            // loop through the songs and add it to the playlist object
            var playlistPortion = Playlist(songIDs: [], songPopularities: [], datesAdded: [], next: nextURL)
            for song in songs {
                // need the date added, popularity, and the id for each song
                if let date = song["added_at"] as? String, let trackDict = song["track"] as? [String : Any], let id = trackDict["id"] as? String, let popularity = trackDict["popularity"] as? Int {
                    // add these properties to the arrays
                    playlistPortion.songIDs.append(id)
                    playlistPortion.songPopularities.append(popularity)
                    playlistPortion.datesAdded.append(date)
                } else {
                    print("There was an error retrieving song information.")
                }
            }
            //print(playlistPortion)
            return playlistPortion
            
        } catch {
            print("Couldn't make JSON object from data.")
        }
        return nil
    }
}
