//
//  TimeLineTableViewController.swift
//  Grumblr
//
//  Created by Adhish Ramkumar on 10/12/14.
//  Copyright (c) 2014 Adhish Ramkumar. All rights reserved.
//

import UIKit

class TimeLineTableViewController: UITableViewController, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var logging: UIButton!
    var timeLineData:NSMutableArray = NSMutableArray()
    var hasUser:Bool = false
    var logError:Bool = false
    
    @IBOutlet var searchBar: UISearchBar!
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        var query = PFUser.query()
        query.whereKey("username", equalTo: searchBar.text)
        query.getFirstObjectInBackgroundWithBlock({ (user:PFObject!, error:NSError!) -> Void in
            if(user != nil) {
                if((user as PFUser).username != PFUser.currentUser().username) {
                    searchBar.text = nil
                    var follow: PFObject = PFObject(className: "Follow")
                    follow["target"] = (user as PFUser).username
                    follow["follower"] = PFUser.currentUser().username
                    follow.saveInBackground()
                    var loginAlert: UIAlertController = UIAlertController(title: "Success: Followed User", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    loginAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
                        alertAction in
                        self.loadData()
                    }))
                    self.presentViewController(loginAlert, animated: true, completion: nil)
                } else {
                    var loginAlert: UIAlertController = UIAlertController(title: "Error: You cannot follow yourself", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    loginAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
                        alertAction in
                        self.loadData()
                    }))
                    self.presentViewController(loginAlert, animated: true, completion: nil)
                }
            } else {
                var loginAlert: UIAlertController = UIAlertController(title: "Error: User not found", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                loginAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
                    alertAction in
                    self.loadData()
                }))
                self.presentViewController(loginAlert, animated: true, completion: nil)
            }
        })
    }

    @IBAction func logout(sender: UIButton) {
        self.logging.setTitle("login", forState: UIControlState.Normal)
        self.logging.sizeToFit()
        hasUser = false
        self.timeLineData.removeAllObjects()
        self.loadData();
        PFUser.logOut()
        viewDidAppear(true)
    }
    
    func loadData(){
        timeLineData.removeAllObjects()
        if (hasUser){
            var findTimeLineData: PFQuery = PFQuery(className: "Post")
            var followsQuery = PFQuery(className: "Follow")
            followsQuery.whereKey("follower", equalTo: PFUser.currentUser().username)
            followsQuery.findObjectsInBackgroundWithBlock{
                (follows:[AnyObject]!, error: NSError!) ->Void in
                
                if (error == nil){
                    var followsUsernames:NSMutableArray = NSMutableArray()
                    for follow in follows {
                        followsUsernames.addObject((follow as PFObject)["target"])
                    }
                    findTimeLineData.whereKey("posterUsername", containedIn: followsUsernames)
                    findTimeLineData.findObjectsInBackgroundWithBlock{
                        (objects:[AnyObject]!, error: NSError!) ->Void in
                        
                        if (error == nil){
                            for object in objects{
                                self.timeLineData.addObject(object)
                            }
                            let array: NSArray = self.timeLineData.reverseObjectEnumerator().allObjects
                            self.timeLineData.removeAllObjects()
                            self.timeLineData.addObjectsFromArray(array)
                            
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
      
        if ((PFUser.currentUser()) == nil){
            var titleStr = "Sign Up / Login"
            if(self.logError) {
                titleStr = "Error Logging in. Try again!"
            }
            var loginAlert: UIAlertController = UIAlertController(title: titleStr, message: "Please sign up or login", preferredStyle: UIAlertControllerStyle.Alert)
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Username"
            })
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Password"
                textfield.secureTextEntry = true
            })
            loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextField: UITextField = textFields.objectAtIndex(0) as UITextField
                let passwordTextField: UITextField = textFields.objectAtIndex(1) as UITextField
                
                PFUser.logInWithUsernameInBackground(usernameTextField.text, password: passwordTextField.text){
                    (user:PFUser!, error:NSError!)-> Void in
                    if ((user) != nil){
                        self.logError = false
                        self.logging.setTitle("logout", forState: UIControlState.Normal)
                        //self.logging.sizeToFit()
                        self.hasUser=true
                        self.loadData()
                    }
                    else{
                        self.logError = true
                        println("Login Failed!")
                        self.hasUser=false
                        self.viewDidAppear(true)
                    }
                }
            
            }))
            loginAlert.addAction(UIAlertAction(title: "Sign up", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextField: UITextField = textFields.objectAtIndex(0) as UITextField
                let passwordTextField: UITextField = textFields.objectAtIndex(1) as UITextField
                
                var poster: PFUser = PFUser()
                poster.username = usernameTextField.text
                poster.password = passwordTextField.text
                poster.signUpInBackgroundWithBlock({
                    (success:Bool!, error: NSError!)-> Void in
                    if (error == nil){
                        self.logError = false
                        var imagePicker:UIImagePickerController = UIImagePickerController()
                        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                        imagePicker.delegate = self
                        self.presentViewController(imagePicker, animated: true, completion: nil)
                        println("Sign up successful")
                        self.logging.setTitle("logout", forState: UIControlState.Normal)
                        //self.logging.sizeToFit()
                        self.hasUser=true
                        self.loadData()
                    }
                    else{
                        self.logError = true
                        println(error.userInfo?["error"])
                        self.hasUser=false
                        self.viewDidAppear(true)
                    }
                    
                })
                
            }))
            
            self.presentViewController(loginAlert, animated: true, completion: nil)
        }
        else{
            println("yoloolosidfa")
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
        let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        let scaledImage = self.scaleImageWith(pickedImage, and: CGSizeMake(100, 100))
        let imageData = UIImagePNGRepresentation(scaledImage)
        let imageFile:PFFile = PFFile(data:imageData)
        PFUser.currentUser().setObject(imageFile, forKey: "profilePic")
        PFUser.currentUser().saveInBackground()
        picker.dismissViewControllerAnimated(true,nil)
    }
    
    func scaleImageWith(image:UIImage, and newSize:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override func viewDidLoad() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        if(!self.hasUser) {
            PFUser.logOut()
        }
        self.searchBar.delegate = self
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return timeLineData.count
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell {
        let cell:PostTableViewCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath!) as PostTableViewCell
        
        cell.postTextView.alpha = 0
        cell.timeStampLabel.alpha = 0
        cell.username.alpha = 0
        let post: PFObject = self.timeLineData.objectAtIndex(indexPath!.row)as PFObject
        cell.postTextView.text = post.objectForKey("content") as String
        
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var findPoster: PFQuery = PFUser.query()
        findPoster.whereKey("objectId", equalTo: post.objectForKey("poster").objectId)
        findPoster.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) -> Void in
            if (error == nil){
                let user: PFUser = (objects as NSArray).lastObject as PFUser
                cell.username.text = user.username
                cell.timeStampLabel.text = dateFormatter.stringFromDate(post.createdAt)
                cell.profileImageView.alpha = 0
                let profilePic:PFFile = user["profilePic"] as PFFile
                profilePic.getDataInBackgroundWithBlock{
                    (imageData:NSData!, error:NSError!)->Void in
                    
                    if(error==nil) {
                        let image = UIImage(data: imageData)
                        cell.profileImageView.image = image
                    }
                }
                UIView.animateWithDuration(0.5, animations: {
                    cell.postTextView.alpha = 1
                    cell.timeStampLabel.alpha = 1
                    cell.username.alpha = 1
                    cell.profileImageView.alpha = 1
                })
            }
        }

        return cell
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
