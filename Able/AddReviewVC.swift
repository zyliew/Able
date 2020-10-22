//
//  AddReviewVC.swift
//  Able
//
//  Created by Ziyi Liew on 21/10/20.
//

import UIKit
import Firebase
import Cosmos
import TinyConstraints

class AddReviewVC: UIViewController {
    var ref: DatabaseReference!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    lazy var cosmosView: CosmosView = {
        var view = CosmosView()
        
        view.settings.filledImage = UIImage(named: "RatingStarFilled")?.withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = UIImage(named: "RatingStarEmpty")?.withRenderingMode(.alwaysOriginal)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(cosmosView)
        let point = CGPoint(x: -130, y: -230)
        cosmosView.centerInSuperview(offset: point, priority: .defaultHigh, isActive: true, usingSafeArea: true)
        
        cosmosView.didFinishTouchingCosmos = { rating in
            print("Rated: \(rating)")
        }
        
        guard let thisUid = Auth.auth().currentUser?.uid else { return }
        setUsername(uid: thisUid)
    }
    
    @IBAction func submitReview(_ sender: Any) {
        // add to Realtime database user/uid/reviews/posteruid/
        let ratingNumber = cosmosView.rating
        if let reviewText = textView.text {
            uploadReview(ratingNumber: ratingNumber, reviewText: reviewText, postUid: Auth.auth().currentUser!.uid)
        } else {
            uploadReview(ratingNumber: ratingNumber, reviewText: "", postUid: Auth.auth().currentUser!.uid)
        }
    }
}

extension AddReviewVC {
    func setUsername(uid: String) {
        ref = Database.database().reference()
       
        ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let getData = snapshot.value as? [String:Any] {
                let username = (getData["username"] as? String)!
                self.usernameLabel.text = username
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func uploadReview(ratingNumber: Double, reviewText: String, postUid: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref = Database.database().reference()
        
        ref.child("user").child(postUid).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            if let getData = snapshot.value as? [String:Any] {
                let reviewCount = (getData["numReviews"] as? Int)! + 1
                let newReview = self.ref.child("user").child(postUid).child("reviews").child("review\(reviewCount)")
                newReview.child("posterId").setValue(uid)
                newReview.child("rating").setValue(ratingNumber)
                newReview.child("post").setValue(reviewText)
                self.ref.child("user").child(postUid).child("reviews").child("numReviews").setValue(reviewCount)
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
}
