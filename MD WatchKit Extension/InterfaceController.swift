

import WatchKit
import Foundation
import Dispatch
import WatchConnectivity

class InterfaceController: WKInterfaceController, MotionSamplerDelegate, WCSessionDelegate {
    
    var toDisp = ""
    
    func xCoordUpdate(_ manager: MotionSampler, xCoord :Double) {
        /// Serialize the property access and UI updates on the main queue.
        DispatchQueue.main.async {
            self.xCoord = "\(xCoord)"
            self.toDisp = self.xCoord
            self.sendToPhone()
        }
    }

    
    let motionSampler = MotionSampler()
    var active = false
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    var xCoord = ""
    let session = WCSession.default()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecievePhoneData), name: NSNotification.Name(rawValue: "recievedPhoneData"),object:nil)
        
    }
    
    override init() {
        super.init()
        self.motionSampler.delegate = self
    }
    
    @IBAction func sendToPhone()
    {
        self.session.sendMessage(["msg":toDisp], replyHandler: nil, errorHandler: nil)
    }
    
    func didRecievePhoneData(info:Notification)
    {
        let msg = info.userInfo!
        self.messageLabel.setText(msg["msg"] as? String)
    }
    
    // MARK: WKInterfaceController
    override func willActivate() {
        super.willActivate()
        active = true
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }
    
    // MARK: Interface Bindings
    @IBAction func start() {
        
        self.titleLabel.setText("Sampling started")
        motionSampler.startSampling()
        
    }
    
    @IBAction func stop() {
       self.titleLabel.setText("Sampling stopped")
        motionSampler.stopSampling()
    }
    
   
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?)
    {
        
    }
    
}
