//
//  EyeTrackingViewController.swift
//  DistractionDodge
//
//  Created by Ayush Kumar Singh on 28/12/24.
//

import ARKit
import SwiftUI

/// A view controller that manages eye tracking using ARKit's face tracking capabilities.
///
/// EyeTrackingViewController provides:
/// - Real-time eye gaze detection
/// - Mapping of 3D gaze coordinates to 2D screen coordinates
/// - Eye state monitoring (blink, squint)
/// - Consecutive gaze validation for accuracy
class EyeTrackingViewController: UIViewController, ARSCNViewDelegate {
    // MARK: - Properties
    
    /// Callback to report gaze status changes
    var eyeTrackingCallback: ((Bool) -> Void)?
    
    /// AR scene view for face tracking
    private var sceneView: ARSCNView!
    
    /// Current target center position on screen
    var screenCenter: CGPoint = .zero
    
    /// Current gaze status
    private var isGazeOnTarget: Bool = false
    
    /// Counter for consecutive gaze detections
    private var gazeHistoryCount = 0
    
    /// Required number of consecutive gaze detections for validation
    private let requiredConsecutiveGazes = 2
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        print("ARFaceTracking supported: \(ARFaceTrackingConfiguration.isSupported)")
        screenCenter = view.center
    }
    
    /// Sets up the AR scene view and configuration
    private func setupAR() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.isOpaque = false
        sceneView.alpha = 0
        
        view.addSubview(sceneView)
        view.sendSubviewToBack(sceneView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARFaceTrackingConfiguration.isSupported {
            print("Starting face tracking session...")
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            configuration.maximumNumberOfTrackedFaces = 1
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            print("Face tracking is not supported on this device")
            
            DispatchQueue.main.async {
                self.eyeTrackingCallback?(true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    /// Updates the target position for gaze detection
    /// - Parameter position: New target position on screen
    func updateTargetPosition(_ position: CGPoint) {
        screenCenter = position
    }
    
    /// Determines if the user's gaze is focused on the target
    /// - Parameter faceAnchor: Current face tracking anchor
    /// - Returns: Boolean indicating if gaze is on target
    private func isGazeOnTarget(_ faceAnchor: ARFaceAnchor) -> Bool {
        let lookAtPoint = faceAnchor.lookAtPoint
        let screenSize = UIScreen.main.bounds.size
        let screenX = CGFloat((lookAtPoint.x + 1) / 2) * screenSize.width
        let screenY = CGFloat((-lookAtPoint.y + 1) / 2) * screenSize.height
        let gazePoint = CGPoint(x: screenX, y: screenY)
        let targetRect = CGRect(
            x: screenCenter.x - 80,
            y: screenCenter.y - 80,
            width: 160,
            height: 160
        )
        
        let isLookingAtTarget = targetRect.contains(gazePoint)
        let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 1.0
        let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 1.0
        let leftEyeSquint = faceAnchor.blendShapes[.eyeSquintLeft]?.floatValue ?? 1.0
        let rightEyeSquint = faceAnchor.blendShapes[.eyeSquintRight]?.floatValue ?? 1.0
        
        let eyesWideOpen = leftEyeBlink < 0.2 && rightEyeBlink < 0.2 &&
        leftEyeSquint < 0.3 && rightEyeSquint < 0.3
        
        return isLookingAtTarget && eyesWideOpen
    }
    
    nonisolated func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        Task { @MainActor in
            let currentGaze = isGazeOnTarget(faceAnchor)
            
            if currentGaze {
                gazeHistoryCount += 1
            } else {
                gazeHistoryCount = 0
            }
            
            let newGazeState = gazeHistoryCount >= requiredConsecutiveGazes
            
            if newGazeState != isGazeOnTarget {
                isGazeOnTarget = newGazeState
                DispatchQueue.main.async {
                    self.eyeTrackingCallback?(self.isGazeOnTarget)
                }
            }
        }
    }
}

extension EyeTrackingViewController: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session failed with error: \(error)")
    }
    
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session was interrupted")
    }
    
    nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session interruption ended")
        
        session.run(session.configuration!, options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - SwiftUI Bridge

/// A SwiftUI wrapper for the EyeTrackingViewController
struct EyeTrackingView: UIViewControllerRepresentable {
    /// Callback for gaze updates
    let onGazeUpdate: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> EyeTrackingViewController {
        let viewController = EyeTrackingViewController()
        viewController.eyeTrackingCallback = onGazeUpdate
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: EyeTrackingViewController, context: Context) {
        
    }
}
