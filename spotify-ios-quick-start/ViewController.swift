//
//  ViewController.swift
//  spotify-ios-quick-start
//
//  Created by Nicole Howard on 6/3/19.
//  Copyright © 2019 Nicole Howard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("hi")
        
//        let url = URL(string: "https://spotify-ios-quick-start-swap.herokuapp.com/api/token")
//
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//
//        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
//            print("in callback")
//            if let res = response {
//                print(res)
//            }
//            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print("Data:")
//                print(dataString)
//            }
//            if let err = err {
//                print("Err")
//                print(err)
//            }
//        }
//        task.resume()
    }
    
    let SpotifyClientID = "e5ee5963d8b34a53ae9c9f74f48c30eb"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    


}

