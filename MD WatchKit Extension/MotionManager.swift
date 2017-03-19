
import Foundation
import CoreMotion
import WatchKit

protocol MotionManagerDelegate: class {
    func xCoordUpdate(_ manager: MotionManager, xCoord: Double)
}

class MotionManager {
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .right
    
    // MARK: Application Specific Constants
    
    //--------------------- not configured yes ----------------------//
    // These constants were derived from data and should be further tuned for your needs.
    let yawThreshold = 1.95 // Radians
    let rateThreshold = 5.5 // Radians/sec
    let resetThreshold = 5.5 * 0.05 // To avoid double counting on the return swing.
    //---------------------------------------------------------------//

    
    // 50hz
    let sampleInterval = 1.0 / 50
    
    weak var delegate: MotionManagerDelegate?
    
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    // MARK: Motion Manager
    
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    // MARK: Motion Processing
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        //pull different measurements
        let rotationRateX = deviceMotion.rotationRate.x
        let rotationRateY = deviceMotion.rotationRate.y
        let rotationRateZ = deviceMotion.rotationRate.z
        let rotationRate = deviceMotion.rotationRate
        
        let xVal:Double = rotationRateX
        
        xCoordUpdateDelegate(xVal: xVal)
    }
    
    func xCoordUpdateDelegate(xVal:Double) {
        delegate?.xCoordUpdate(self, xCoord:xVal)
    }
    
    
}
