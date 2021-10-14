import ARKit
import SceneKit
import UIKit
import SwiftCSV
import SwiftUI

class ARVisViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
	
	let augmentedViewWidth: CGFloat = 1920.0
	let augmentedViewHeight: CGFloat = 1080.0
	
	var maxAugmentedViewWH: CGFloat {
		get {
			max(augmentedViewWidth, augmentedViewHeight)
		}
	}
    
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
		configuration.maximumNumberOfTrackedImages = 0
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
	}
	
	func createHostingController(for node: SCNNode) {
		DispatchQueue.main.async {
			let viewController = UIViewController()
			viewController.view.frame = CGRect(x: 0, y: 0, width: self.maxAugmentedViewWH, height: self.maxAugmentedViewWH)
			viewController.view.isOpaque = false
			viewController.view.backgroundColor = .clear
			
			let lineChartHostingVC = UIHostingController(rootView: LineChartContainerView(dataSources: SampleDataHelper.catSevNumOrderedSeries))
			lineChartHostingVC.view.frame = CGRect(x: 0, y: self.maxAugmentedViewWH / 4, width: self.augmentedViewWidth, height: self.augmentedViewHeight)
			
			viewController.view.addSubview(lineChartHostingVC.view)
			
			self.show(viewController: viewController, on: node)
		}
	}
	
	func show(viewController: UIViewController, on node: SCNNode) {
		
		let material = SCNMaterial()
		material.diffuse.contents = viewController.view
		node.geometry?.materials = [material]
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
			
			let planeWidth = referenceImage.physicalSize.width * 4
			let planeHeight = planeWidth
			
			let plane = SCNPlane(width: planeWidth, height: planeHeight)
			let planeNode = SCNNode(geometry: plane)
//			planeNode.position = .init(-referenceImage.physicalSize.width * 1.5, 0, -referenceImage.physicalSize.height * 1.5)
			planeNode.position = .init(0, 0, 0)
			self.createHostingController(for: planeNode)
			
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
					
//					planeNode.position = .init(-referenceImage.physicalSize.width * 1.5, 0, -referenceImage.physicalSize.height * 1.5)
					planeNode.position = .init(0, 0, 0)
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
