

import WatchKit
import Foundation
import Dispatch
import WatchConnectivity

class InterfaceController: WKInterfaceController, MotionSamplerDelegate, WCSessionDelegate {
    
    var currMsg = [[Double]]()
    var active = false
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    func measureUpdate(_ manager: MotionSampler, measurementsArr :[[Double]]) {
        /// Serialize the property access and UI updates on the main queue.
        DispatchQueue.main.async {
            self.currMsg = measurementsArr
            self.sendToPhone()
        }
    }

    
    let motionSampler = MotionSampler()
    let session = WCSession.default()
    
    override init() {
        super.init()
        self.motionSampler.delegate = self
    }
    
    @IBAction func sendToPhone()
    {
        self.session.sendMessage(["msg":self.currMsg], replyHandler: nil, errorHandler: nil)
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
