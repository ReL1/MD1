
import Foundation


protocol MotionSamplerDelegate: class {
    func measureUpdate(_ manager: MotionSampler, measurementsArr:[[Double]])
}

class MotionSampler: MotionManagerDelegate {
    // MARK: Properties
    let motionManager = MotionManager()
    
    weak var delegate: MotionSamplerDelegate?
    
    // MARK: Initialization
    
    init() {
        motionManager.delegate = self
    }
    
    // MARK: WorkoutManager
    
    func startSampling() {

        //start device motion updates
        motionManager.startUpdates()
    }
    
    func stopSampling() {
        
        
        // Stop the device motion updates 
        motionManager.stopUpdates()
        
        // Clear the workout session.
    }
 
    func measureUpdate(_ manager: MotionManager, measurementsArr: [[Double]]){
        delegate?.measureUpdate(self, measurementsArr: measurementsArr)
    }

}
