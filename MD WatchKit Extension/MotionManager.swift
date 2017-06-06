
import Foundation
import CoreMotion
import WatchKit

protocol MotionManagerDelegate: class {
    func measureUpdate(_ manager: MotionManager, measurementsArr: [[Double]])
    func didUpdateRepsSwingCount(_ manager: MotionManager, reps: Int)

}

class MotionManager {
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .right
    var counter = 0
    var measurementsArr = [[Double]]()
    var startTime = Date()
    // 50hz
    let sampleInterval = 1.0 / 50
    
    // less than 1 second buffer.
    let AccelBuffer = RunningBuffer(size: 45)
    
    let upThresh = 0.17
    let downThresh = -0.10
    
    var lastRep = ""
    var reps = 0
    var repOk = false
    
    var recentDetection = false

    
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
        
        resetAllState()
        
        //start counting time since startupdates
        startTime = Date()

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
        let elapsed = Date().timeIntervalSince(startTime)
        let rotationRateX = deviceMotion.rotationRate.x
        let rotationRateY = deviceMotion.rotationRate.y
        let rotationRateZ = deviceMotion.rotationRate.z
        let gravityX = deviceMotion.gravity.x
        let gravityY = deviceMotion.gravity.y
        let gravityZ = deviceMotion.gravity.z
        let pitch = deviceMotion.attitude.pitch
        let roll = deviceMotion.attitude.roll
        let yaw = deviceMotion.attitude.yaw
        let accelX = deviceMotion.userAcceleration.x
        let accelY = deviceMotion.userAcceleration.y
        let accelZ = deviceMotion.userAcceleration.z
        
        //add measurement attrs to new row of string
        var tempRow = [Double]()
        //rotational
        tempRow.append(rotationRateX)
        tempRow.append(rotationRateY)
        tempRow.append(rotationRateZ)
        //gravity
        tempRow.append(gravityX)
        tempRow.append(gravityY)
        tempRow.append(gravityZ)
        //attitude
        tempRow.append(pitch)
        tempRow.append(roll)
        tempRow.append(yaw)
        //accel
        tempRow.append(accelX)
        tempRow.append(accelY)
        tempRow.append(accelZ)
        
        //magnetic field--not supported
        //tempRow.append(magneticFieldX)
        //tempRow.append(magneticFieldY)
        //tempRow.append(magneticFieldZ)
        //tempRow.append(Double(magneticFieldAccuracy))
        //let magneticFieldAccuracy = deviceMotion.magneticField.accuracy.rawValue
        //let magneticFieldX = deviceMotion.magneticField.field.x
        //let magneticFieldY = deviceMotion.magneticField.field.y
        //let magneticFieldZ = deviceMotion.magneticField.field.z
        
        tempRow.append(elapsed)
        //append row to 2d array of measurements
        measurementsArr.append(tempRow)
        
        if counter==500 {
            measureUpdateDelegate(measurementsArr: measurementsArr)
            counter = 0
            measurementsArr.removeAll()
        }
        
        let currZaccel = deviceMotion.userAcceleration.z
        
        let avgproduct = currZaccel
        
        AccelBuffer.addSample(avgproduct)
        
        if !AccelBuffer.isFull() {
            return
        }
        
        let currMean = AccelBuffer.recentMean()
        
        if (currMean > upThresh) {
            if (lastRep == "")
            {
                up()
            }
            else
            {
                lastRep = ""
            }
            
        } else if currMean < (downThresh) {
            if(lastRep == "up")
            {
                down()
                repOk = true
            }
            else
            {
                lastRep = ""
            }
        }
        
        if(repOk) {
            rep()
            WKInterfaceDevice().play(.notification)
            lastRep = ""
            repOk = false
        }
        
        // Reset after letting the rate settle to catch the return swing.
        if (recentDetection) {
            recentDetection = false
            AccelBuffer.reset()
        }
    }
    
    func resetAllState() {
    AccelBuffer.reset()
        
    recentDetection = false
    updateRepsSwingDelegate()
    }
    
   
    
    func down() {
        if (!recentDetection) {
            lastRep = "down"
            recentDetection = true
        }
    }
    
    func up() {
        if (!recentDetection) {
            lastRep = "up"
            recentDetection = true
        }
    }
    
    func rep() {
        if (recentDetection) {
            lastRep = ""
            reps += 1
            print("reps: \(reps)")
            recentDetection = true
            updateRepsSwingDelegate()
        }
    }

    func measureUpdateDelegate(measurementsArr:[[Double]]) {
        delegate?.measureUpdate(self, measurementsArr:measurementsArr)
    }
    
    
    func updateRepsSwingDelegate() {
        delegate?.didUpdateRepsSwingCount(self, reps:reps)
    }
}
