//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit

class TableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var students = [StudentInfo]()
    let cellID = "StudentCell"
    
    @IBOutlet weak var listTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getStudentInformationForTable()
        
        // Subscribe to student information refreshed notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentInformationRefreshed:", name: OTMClient.Notifications.StudentInformationDownloaded, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe to notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OTMClient.Notifications.StudentInformationDownloaded, object: nil)
    }
    
    func getStudentInformationForTable() {
        Students.sharedInstance().getStudentInformation() { success, error in
            if success {
                self.students = Students.sharedInstance().students
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.listTableView.reloadData()
                }
            }
            else {
                println("Something bad happened on table")
            }
        }
    }
    
    func studentInformationRefreshed(notification: NSNotification) {
        // Refresh the table when reload button is pressed
        self.listTableView.reloadData()
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return students.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UITableViewCell
        
        // Get the student details
        let firstName = students[indexPath.row].firstName
        let lastName = students[indexPath.row].lastName
        
        // Configure the cell...
        cell.imageView?.image = UIImage(named: "pin_icon")
        cell.textLabel?.text = "\(firstName) \(lastName)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get the student's URL
        let studentURL = students[indexPath.row].mediaURL
        
        // Open safari to the students link
        let newurl = fixLinks(studentURL)
        if let url = NSURL(string: newurl) {
            println(url)
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                println("Something bad happened on table view")
            }
        }
    }
    
    // A lot of people don't include the http part of a link
    // This check see if they have or not. If they haven't automaticly add it
    func fixLinks(urlString: String) -> String
    {
        if urlString.rangeOfString("http://www.") == nil {
            let newString = "http://www." + urlString
            return newString
        }
        return urlString
    }

}
