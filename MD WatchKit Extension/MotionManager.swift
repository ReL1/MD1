
import Foundation
import CoreMotion
import WatchKit

protocol MotionManagerDelegate: class {
    func measureUpdate(_ manager: MotionManager, measurementsArr: [[Double]])
}

class MotionManager {
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .right
    var counter = 0
    var measurementsArr = [[Double]]()
    
    // 50hz
    let sampleInterval = 1.0 / 50
    
    weak var delegate: MotionManagerDelegate?
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    func startUpdates() {
        counter = 0
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
            measureUpdateDelegate(measurementsArr: measurementsArr)
            counter = 0
            motionManager.stopDeviceMotionUpdates()
        }
    }
      
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        //pull different measurements
        counter = counter + 1
        let rotationRateX = deviceMotion.rotationRate.x
        let rotationRateY = deviceMotion.rotationRate.y
        let rotationRateZ = deviceMotion.rotationRate.z
        
        //add measurement attrs to new row of string
        var tempRow = [Double]()
        tempRow.append(rotationRateX)
        tempRow.append(rotationRateY)
        tempRow.append(rotationRateZ)

        //append row to 2d array of measurements
        measurementsArr.append(tempRow)
        
        if counter==500 {
            measureUpdateDelegate(measurementsArr: measurementsArr)
            counter = 0
            measurementsArr.removeAll()
        }
    }
    
    func measureUpdateDelegate(measurementsArr:[[Double]]) {
        delegate?.measureUpdate(self, measurementsArr:measurementsArr)
    }
    
    
}
