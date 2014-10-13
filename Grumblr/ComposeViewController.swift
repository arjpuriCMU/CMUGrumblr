//
//  ComposeViewController.swift
//  Grumblr
//
//  Created by Adhish Ramkumar on 10/12/14.
//  Copyright (c) 2014 Adhish Ramkumar. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet var newPostView: UITextView! = UITextView()
    @IBOutlet var remainingCharLabel: UILabel! = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        newPostView.layer.borderColor = UIColor.blackColor().CGColor
        newPostView.layer.borderWidth = 0.5
        newPostView.layer.cornerRadius = 5
        newPostView.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func savePost(sender: AnyObject) {
        var post: PFObject = PFObject(className: "Post")
        post["content"] = newPostView.text
        post["poster"] = PFUser.currentUser()
        post.saveInBackground()
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
