//
//  ViewController.swift
//  MD
//
//  Created by ariel nitzan on 14/03/2017.
//  Copyright © 2017 ariel nitzan. All rights reserved.
//

import UIKit
import WatchConnectivity
import MessageUI

class ViewController: UIViewController , MFMailComposeViewControllerDelegate{

    @IBOutlet weak var toWatchField: UITextField!
    @IBOutlet weak var fromWatchLabel: UILabel!
    var measurements = [String]()
    var currX = ""
    var id=0
    var stringID = ""
    let session = WCSession.default()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        NotificationCenter.default.addObserver(self, selector: #selector(messageRecieved), name: NSNotification.Name(rawValue: "recievedWatchMessage"), object: nil)
        
    }

    @IBAction func sendToWatchTapped(sender: UIButton)
    {
        if self.session.isPaired == true && self.session.isWatchAppInstalled == true {
            self.session.sendMessage(["msg":self.toWatchField.text!], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func messageRecieved(info:Notification)
    {
        let message = info.userInfo!
        DispatchQueue.main.sync {
            self.fromWatchLabel.text = message["msg"] as? String
            currX = (message["msg"] as? String)!
            id = id + 1
            stringID = String(id)
            measurements += [stringID+","+currX]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        let fileName = "Tasks.csv"
        let fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "ID,xVal\n"
        
        for currMeasure in measurements {
            let newLine = "\(currMeasure)\n"
            csvText.append(newLine)
        }
        
        do {
            try csvText.write(to: fpath!, atomically: true, encoding: String.Encoding.utf8)
            //1st option - email
            if MFMailComposeViewController.canSendMail() {
                let emailController = MFMailComposeViewController()
                emailController.mailComposeDelegate = self
                emailController.setToRecipients([])
                emailController.setSubject("data export")
                emailController.setMessageBody("Hi,\n\nThe .csv data export is attached\n\n\nSent from the MD app", isHTML: false)
                
                emailController.addAttachmentData(NSData(contentsOf: fpath!)! as Data, mimeType: "text/csv", fileName: "Tasks.csv")

                
                present(emailController, animated: true, completion: nil)
            }
                
            //2nd option - anything but email
            /**let vc = UIActivityViewController(activityItems: [fpath], applicationActivities: [])
             vc.excludedActivityTypes = [
             UIActivityType.assignToContact,
             UIActivityType.saveToCameraRoll,
             UIActivityType.postToFlickr,
             UIActivityType.postToVimeo,
             UIActivityType.postToTencentWeibo,
             UIActivityType.postToTwitter,
             UIActivityType.postToFacebook,
             UIActivityType.openInIBooks
             ]
             present(vc, animated: true, completion: nil)**/
            }catch {
                print("Failed to fetch feed data, critical error: \(error)")
            }
    }
    
    //func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    //    controller.dismiss(animated: true, completion: nil)
    //}
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            // Dismiss the mail compose view controller.
            controller.dismiss(animated: true, completion: nil)
    }
}
    


