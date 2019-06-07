//
//  ViewController.swift
//  spotify-ios-quick-start
//
//  Created by Nicole Howard on 6/3/19.
//  Copyright © 2019 Nicole Howard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTSessionManagerDelegate {
    
    
    // MARK: - Spotify Variable Configurations
    
    /*
     user_id: the users spotify id
     accessToken: the current token to use to interface with Spotify's API
     SpotifyClientID: the id for this application
     SpotifyRedirectURL: the url for this application
     configuration: configuration properties for the Spotify Session Manager
     sessionManager: manages session such as authentication
    */
    var user_id = ""
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
    
    
    // MARK: - IB Outlets
    @IBOutlet var welcomeLabel: UILabel!
    
    
    // MARK: - IB Action Functions
    
    /*
     getSongsButtonPressed() WORK IN PROGRESS
    */
    @IBAction func getSongsButtonPressed(_ sender: Any) {
        print("time to get some gd songz")
    }
    
    /*
     loginButtonPressed(_ sender: Any)
     desc: this function initiated the Spotify session and authenticates and authorizes user with given scope.
     note: sessionManager callbacks are called depending on the success of the authorization
    */
    @IBAction func loginButtonPressed(_ sender: Any) {
        let requestedScopes: SPTScope = [.appRemoteControl, .userReadPrivate, .userReadEmail, .userReadBirthDate]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    }
    
    
    // MARK: - SPTSessionManagerDelegate functions
    /*
     sessionManager(manager, didInitiate)
     desc: the session has been initiated with a success. immediately gets user info and updates welcome label
    */
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        // set the accessToken property to the current accessToken given by session
        print("success", session)
        accessToken = session.accessToken
        
        // get the user's information and set userID property
        SpotifyAPI.getUserInfo(accessToken: accessToken, completion: { (userOptional) -> Void in
            if let user = userOptional {
                print(user.displayName)
                self.welcomeLabel.text = "Welcome, " + user.displayName + "!"
                self.user_id = user.id
            }
        })
    }
    
    /*
     sessionManager(manager, error)
     desc: callback runs when the session fails.
    */
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("fail", error)
    }
    
    //TODO: need to use the refresh token every 60 minutes so they don't have to keep logging in
    /*
     sessionManager(manage, session) runs when a session is renewed.
    */
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("renewed", session)
    }
    
    /*
     Once a user successfully returns to your application, we’ll need to notify
     sessionManager about it by implementing the following method:
    */
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.sessionManager.application(app, open: url, options: options)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

