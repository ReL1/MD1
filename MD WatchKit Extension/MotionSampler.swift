
import Foundation
import HealthKit


protocol MotionSamplerDelegate: class {
    func xCoordUpdate(_ manager: MotionSampler, xCoord: Double)
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
 
    func xCoordUpdate(_ manager: MotionManager, xCoord: Double){
        delegate?.xCoordUpdate(self, xCoord: xCoord)
    }

}
