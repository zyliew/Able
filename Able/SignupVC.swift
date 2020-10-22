//
//  SignupVC.swift
//  Able
//
//  Created by Andre Tran on 10/9/20.
//

import UIKit
import Firebase
import FirebaseDatabase


class SignupVC: UIViewController {

    @IBOutlet weak var displayError: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    
    let ref: DatabaseReference! = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayError.textColor = .red
    }
    
    // sign up with Firebase
    @IBAction func signUpButton(_ sender: Any) {
        let email = emailField.text!
        let password = passwordField.text!
        Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
            if let error = error as NSError? {
                displayMessage(text: "Error: \(error.localizedDescription)", color: .red)
            } else {
                displayMessage(text: "Signed Up Successfully", color: .black)
                let uid: String = Auth.auth().currentUser!.uid
                //add data to database
                ref.child("user/\(uid)").setValue([
                    "username": "@" + usernameField.text!,
                    "name": usernameField.text!,
                    "city": cityField.text!,
                    "state": stateField.text!,
                    "notifications": true
                ])
                
                goHomeScreen()
            }
        }
    }
    
    // display sign up error messages
    func displayMessage(text: String, color: UIColor){
        self.displayError.textColor = color
        self.displayError.text = text
    }
    
    // go to home screen after successful sign up
    func goHomeScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageVC")
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}
