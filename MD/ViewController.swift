
import UIKit
import WatchConnectivity
import MessageUI

class ViewController: UIViewController , MFMailComposeViewControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var howto:UILabel!
    @IBOutlet weak var howtopicture:UIImageView!
    @IBOutlet weak var leftWristBtn: UIButton!
    @IBOutlet weak var whenDoneBtn: UIButton!
    @IBOutlet weak var rightWristBtn: UIButton!
    @IBOutlet weak var smokeActivityBtn: UIButton!
    @IBOutlet weak var otherActivityBtn: UIButton!
    @IBOutlet weak var fromWatchLabel: UILabel!
    
    var singleMessageMeasures = [[Double]]()
    var allMeasures = [[[Double]]]()
    var id=0
    var stringID = ""
    var counter = 0
    let session = WCSession.default()
    var wristVal = ""
    var activityVal = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(messageRecieved), name: NSNotification.Name(rawValue: "recievedWatchMessage"), object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameField.delegate = self
        nameField.returnKeyType = .done
        self.view.addSubview(nameField)
    }
    
    //take message and insert to global array[][] of Double
    func messageRecieved(info:Notification)
    {
        let message = info.userInfo!
        DispatchQueue.main.sync {
            singleMessageMeasures = message["msg"] as! [[Double]]
            counter = counter + singleMessageMeasures.count
            self.fromWatchLabel.text = "Records transferred: " + String(counter)
            if singleMessageMeasures.count < 500 {
                self.fromWatchLabel.backgroundColor = UIColor.green
                self.fromWatchLabel.text = "Done." + String(counter) + " Records transmitted."
            }
            allMeasures.append(singleMessageMeasures)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftHandPicked(_ sender: Any) {
        wristVal = " Left wrist"
        self.rightWristBtn.isUserInteractionEnabled = false
        self.leftWristBtn.backgroundColor = UIColor.green
        self.rightWristBtn.isHidden = true
    }
    
    @IBAction func rightHandPicked(_ sender: Any) {
        wristVal = " Right wrist"
        self.leftWristBtn.isUserInteractionEnabled = false
        self.rightWristBtn.backgroundColor = UIColor.green
        self.leftWristBtn.isHidden = true
    }
    
    @IBAction func smokingPicked(_ sender: Any) {
        activityVal = " Smoking"
        self.otherActivityBtn.isUserInteractionEnabled = false
        self.smokeActivityBtn.backgroundColor = UIColor.green
        self.otherActivityBtn.isHidden = true
        self.howto.isHidden = false
        self.howtopicture.isHidden = false
        self.whenDoneBtn.isHidden = false
        self.fromWatchLabel.isHidden = false
    }
    
    @IBAction func otherActivityPicked(_ sender: Any) {
        activityVal = " Other"
        self.smokeActivityBtn.isUserInteractionEnabled = false
        self.otherActivityBtn.backgroundColor = UIColor.green
        self.smokeActivityBtn.isHidden = true
        self.howto.isHidden = false
        self.howtopicture.isHidden = false
        self.whenDoneBtn.isHidden = false
        self.fromWatchLabel.isHidden = false
    }
    
    
    @IBAction func buttonClick(_ sender: UIButton) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_yyyy_HH-mm"
        let convertedDate = dateFormatter.string(from: date)
        
        let fileName = convertedDate+"_Measurements.csv"
        let fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "measurementID,rotationX,rotationY,rotationZ,gravityX,gravityY,gravityZ,pitch,roll,yaw,accelX,accelY,accelZ,secondsPassed\n"       
        
        for m in allMeasures {
            //pull row from 2d array
            for x in 0..<m.count {
                //create row and increment the id
                id = id + 1
                stringID = String(id)
                
                //create empty line for csv
                var newLine = ""
                newLine.append(stringID)
                
                //pull data from row and append to new csv line
                for y in 0..<m[x].count {
                    let temp = m[x][y]
                    let stringtemp = "\(temp)"
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
                let partA = "Hi,\n\nThe .csv measurements export is attached\n\n Participant Name:"
                let partB = self.nameField.text! + "\n Activity:" + self.activityVal + "\n Wrist:" + self.wristVal + "\nSent from the MD app"
                emailController.setMessageBody( partA + partB, isHTML: false)
                emailController.addAttachmentData(NSData(contentsOf: fpath!)! as Data, mimeType: "text/csv", fileName: fileName)
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
    


