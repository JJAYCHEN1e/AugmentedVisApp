import ARKit
import SceneKit
import UIKit

class ARVisViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR experience
        resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

        session.pause()
	}

    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true

    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
	func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
		configuration.maximumNumberOfTrackedImages = 1
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
	}

	var plane: SCNPlane?
	var planeNode: SCNNode?
	
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let imageAnchor = anchor as? ARImageAnchor else { return }
		let referenceImage = imageAnchor.referenceImage
		updateQueue.async {
			print("FIRST NODE")
			// Create a plane to visualize the initial position of the detected image.
			let plane = SCNPlane(width: referenceImage.physicalSize.width * 2,
								 height: referenceImage.physicalSize.height * 2)
			let planeNode = SCNNode(geometry: plane)
			planeNode.position = .init(-referenceImage.physicalSize.width * 1.5, 0, -referenceImage.physicalSize.height * 1.5)
			
			self.plane = plane
			self.planeNode = planeNode
			
			planeNode.eulerAngles.x = -.pi / 2
			
			node.addChildNode(planeNode)
		}

		DispatchQueue.main.async {
			let imageName = referenceImage.name ?? ""
			self.statusViewController.cancelAllScheduledMessages()
			self.statusViewController.showMessage("Detected image “\(imageName)”")
		}
	}

	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		guard let imageAnchor = anchor as? ARImageAnchor else { return }
		let referenceImage = imageAnchor.referenceImage
		
		if let planeNode = planeNode {
			if node.isHidden == true, planeNode.parent == node {
				updateQueue.async {
					print("WORLD")
					// But we should manually 'tracking' the new position and orientation.
					let worldP = planeNode.worldPosition
					let worldO = planeNode.worldOrientation
					
					planeNode.removeFromParentNode()
					self.sceneView.scene.rootNode.addChildNode(planeNode)
					planeNode.worldPosition = worldP
					planeNode.worldOrientation = worldO
				}
			} else if node.isHidden == false, planeNode.parent != node {
				updateQueue.async {
					print("NODE")
					
					planeNode.removeFromParentNode()
					node.addChildNode(planeNode)
					
					planeNode.position = .init(-referenceImage.physicalSize.width * 1.5, 0, -referenceImage.physicalSize.height * 1.5)
					planeNode.eulerAngles.x = -.pi / 2
					planeNode.eulerAngles.y = 0
					planeNode.eulerAngles.z = 0
				}
			}
		}
	}

    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
        ])
    }
}
