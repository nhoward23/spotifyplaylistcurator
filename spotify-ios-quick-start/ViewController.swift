//
//  ViewController.swift
//  spotify-ios-quick-start
//
//  Created by Nicole Howard on 6/3/19.
//  Copyright © 2019 Nicole Howard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTSessionManagerDelegate {
    
    var accessToken = ""
    let SpotifyClientID = "e5ee5963d8b34a53ae9c9f74f48c30eb"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )
    lazy var sessionManager: SPTSessionManager = {
        if let tokenSwapURL = URL(string: "https://spotify-ios-quick-start-swap.herokuapp.com/api/token"),
            let tokenRefreshURL = URL(string: "https://spotify-ios-quick-start-swap.herokuapp.com/api/refresh_token") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
            self.configuration.playURI = "spotify:track:20I6sIOMTCkB6w7ryavxtO"
        }
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        return manager
    }()
    
    @IBAction func getSongsButtonPressed(_ sender: Any) {
        print("time to get some gd songz")
        // TODO: change this so it's not just saved in the code

        print("TEST")
        print(accessToken)
        SpotifyAPI.getUserInfo(accessToken: accessToken, completion: { (userOptional) -> Void in
            
            if let user = userOptional {
                print(user.displayName)
            }
            
        })
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let requestedScopes: SPTScope = [.appRemoteControl, .userReadPrivate, .userReadEmail, .userReadBirthDate]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("success", session)
        accessToken = session.accessToken
    }
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("renewed", session)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.sessionManager.application(app, open: url, options: options)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

}

