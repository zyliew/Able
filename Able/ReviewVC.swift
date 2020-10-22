//
//  ReviewVC.swift
//  Able
//
//  Created by Ziyi Liew on 21/10/20.
//

import UIKit
import Firebase

class ReviewVC: UIViewController {
    var ref: DatabaseReference!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // retrieve rating from Firebase realtime database
        setRating(uid: Auth.auth().currentUser!.uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setRating(uid: Auth.auth().currentUser!.uid)
    }

}

extension ReviewVC {
    
    func setRating(uid: String) {
        ref = Database.database().reference()
        ref.child("user").child(uid).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            if let getData = snapshot.value as? [String:Any] {
                let numReviews = (getData["numReviews"] as? Int)!
                var rating = 0.0
                if numReviews != 0 {
                    for i in 1...numReviews {
                        let currentId = (getData["review\(i)"] as? [String:Any])!
                        let ratingTemp = (currentId["rating"] as? Double)!
                        rating = ratingTemp + rating
                    }
                    rating = rating / Double(numReviews)
                    self.ratingLabel.text = String(format: "%.1f", rating)
                } else {
                    self.ratingLabel.text = "No Ratings"
                }
            } else {
                self.ratingLabel.text = "No Ratings"
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
}
