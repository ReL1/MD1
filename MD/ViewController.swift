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

    @IBOutlet weak var fromWatchLabel: UILabel!
    var singleMessageMeasures = [[Double]]()
    var allMeasures = [[[Double]]]()
    var id=0
    var stringID = ""
    var counter = 0
    let session = WCSession.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(messageRecieved), name: NSNotification.Name(rawValue: "recievedWatchMessage"), object: nil)
    }
    
    //take message and insert to global array[][] of Double
    func messageRecieved(info:Notification)
    {
        let message = info.userInfo!
        DispatchQueue.main.sync {
            self.fromWatchLabel.text = "records transferred"
            singleMessageMeasures = message["msg"] as! [[Double]]
            counter = counter + singleMessageMeasures.count
            self.fromWatchLabel.text = String(counter)
            allMeasures.append(singleMessageMeasures)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        let fileName = "Measurements.csv"
        let fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "ID,x,y,z\n"
        
        for m in allMeasures {
            //pull row from 2d array
            for var x in 0..<m.count {
                //create row and increment the id
                id = id + 1
                stringID = String(id)
                
                //create empty line for csv
                var newLine = ""
                newLine.append(stringID)
                
                //pull data from row and append to new csv line
                for var y in 0..<m[x].count {
                    var temp = m[x][y]
                    var stringtemp = "\(temp)"
                    newLine.append(","+stringtemp)
                }
                newLine.append("\n")
                
                csvText.append(newLine)
        }
    }
        
        do {
            try csvText.write(to: fpath!, atomically: true, encoding: String.Encoding.utf8)
            //1st option - email
            if MFMailComposeViewController.canSendMail() {
                let emailController = MFMailComposeViewController()
                emailController.mailComposeDelegate = self
                emailController.setToRecipients([])
                emailController.setSubject("New measurements export")
                emailController.setMessageBody("Hi,\n\nThe .csv measurements export is attached\n\n\nSent from the MD app", isHTML: false)
                emailController.addAttachmentData(NSData(contentsOf: fpath!)! as Data, mimeType: "text/csv", fileName: "Measurements.csv")
                present(emailController, animated: true, completion: nil)
            }
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
    


