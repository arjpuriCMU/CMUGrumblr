//
//  IntroViewController.swift
//  Grumblr
//
//  Created by Arjun Puri on 12/1/14.
//  Copyright (c) 2014 Adhish Ramkumar. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet var grumblrTitle: UILabel!
    @IBOutlet var dropletImage: UIImageView!
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animateWithDuration(4.0, animations: {
            self.dropletImage.center = CGPoint(x: self.dropletImage.center.x,y: self.dropletImage.center.y + 60)
            })
      
  
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
