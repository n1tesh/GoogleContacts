//
//  ViewController.swift
//  GoogleContacts
//
//  Created by Nitesh I on 04/05/17.
//  Copyright © 2017 Nitesh. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController {

    @IBOutlet weak var signInButton: GIDSignInButton!
    fileprivate var networkController : NetworkController!
    fileprivate var accessToken : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupGoogleLogin()

    }

    private func setupGoogleLogin(){
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/contacts.readonly")
        //        GIDSignIn.sharedInstance().signInSilently()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print(error.localizedDescription)
        }else{
            print(user.profile.name)
            print(user.profile.imageURL(withDimension: 60))
            print(user.profile.email)
            
            _ = ["email":"", "login_from": "gplus", "device_id": "", "device_platform": "", "contacts": ["email":"asd","name":"ddd", "image":"URL"]]
            
            let accessToken = user.authentication.accessToken
            self.networkController = NetworkController(accessToken: accessToken!)
            loadContacts()
            GIDSignIn.sharedInstance().signOut()
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    public func loadContacts() {
        let contactsURL : NSURL = NSURL(string: "https://www.google.com/m8/feeds/contacts/default/thin?max-results=10000")!
        self.networkController.sendRequestToURL(url: contactsURL, completion: { (data, response, error) -> () in
            if (response?.statusCode == 200 && error == nil) {
                self.parseData(data: data!)
            } else {
            }
        })
    }
    
    func parseData(data: Data){
        let xml = SWXMLHash.parse(data)
        print(xml["feed"]["entry"][0].all.count)
        //        print(xml["feed"]["entry"][0]["gd:email"].value(ofAttribute: "address"))
        do {
            let nodes: [GoogleContacts] = try xml["feed"].value()
            print(nodes)
            
        } catch let error {
            print(error)
        }
        
    }
    
}
