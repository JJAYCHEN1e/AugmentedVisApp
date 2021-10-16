import ARKit
import SceneKit
import SwiftCSV
import SwiftUI
import UIKit
import DequeModule

class ARVisViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet var blurView: UIVisualEffectView!

    let augmentedViewWidth: CGFloat = 1920.0 / 2
    let augmentedViewHeight: CGFloat = 1080.0 / 2

    let padding: CGFloat = 16.0
    let qrCodeSize: CGFloat = 240.0
    let graphWidth: CGFloat = 1920.0
    let graphHeight: CGFloat = 1080.0

    var maxAugmentedViewWH: CGFloat {
        max(augmentedViewWidth, augmentedViewHeight)
    }

    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        children.lazy.compactMap { $0 as? StatusViewController }.first!
    }()

    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")

    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        sceneView.session
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
        configuration.automaticImageScaleEstimationEnabled = true
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
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
            lineChartHostingVC.view.backgroundColor = .clear
            lineChartHostingVC.view.frame = CGRect(x: 0, y: (self.maxAugmentedViewWH - self.augmentedViewHeight) / 2, width: self.augmentedViewWidth, height: self.augmentedViewHeight)

            viewController.view.addSubview(lineChartHostingVC.view)

            self.show(viewController: viewController, on: node)
        }
    }

    func show(viewController: UIViewController, on node: SCNNode) {
        let material = SCNMaterial()
        material.diffuse.contents = viewController.view
        node.geometry?.materials = [material]
    }

    var plane = SCNPlane()
    var planeNode = SCNNode()
    var dumbNode = SCNNode()

    var dumbNodeLastEulerAnglesDeque = Deque<SCNVector3>()
    var dumbNodeLastPositionDeque = Deque<SCNVector3>()
    var dumbNodeLastStablePositionSample = SCNVector3()

    var isPositionAndEulerAnglesValid: Bool {
        let maxEulerAnglesXRange = abs(dumbNodeLastEulerAnglesDeque.max { $0.x < $1.x }!.x - dumbNodeLastEulerAnglesDeque.min { $0.x < $1.x }!.x)
        let maxEulerAnglesYRange = abs(dumbNodeLastEulerAnglesDeque.max { $0.y < $1.y }!.y - dumbNodeLastEulerAnglesDeque.min { $0.y < $1.y }!.y)
        let maxEulerAnglesZRange = abs(dumbNodeLastEulerAnglesDeque.max { $0.z < $1.z }!.z - dumbNodeLastEulerAnglesDeque.min { $0.z < $1.z }!.z)

        // TODO: - Magic Numebr `0.0015` Should be Relative to Reference Image's Physical size I think.
        if maxEulerAnglesXRange < 0.02, maxEulerAnglesYRange < 0.02, maxEulerAnglesZRange < 0.02 {
            if dumbNodeLastPositionDeque.allSatisfy({ abs($0.x - dumbNodeLastStablePositionSample.x) > 0.0015 }) ||
                dumbNodeLastPositionDeque.allSatisfy({ abs($0.y - dumbNodeLastStablePositionSample.y) > 0.0015 }) ||
                dumbNodeLastPositionDeque.allSatisfy({ abs($0.z - dumbNodeLastStablePositionSample.z) > 0.0015 }) {
                dumbNodeLastStablePositionSample = dumbNodeLastPositionDeque.last!
                return true
            }
        }

        return false
    }

    // MARK: - ARSCNViewDelegate (Image detection results)

    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage

        let imageSize = referenceImage.physicalSize.width * imageAnchor.estimatedScaleFactor

        let sizeScale = qrCodeSize / imageSize

        let planeWidth = graphWidth / sizeScale
        let planeHeight = planeWidth

        let dumbNodePosition = SCNVector3(-((graphWidth + qrCodeSize) / 2 + padding) / sizeScale, 0, -(graphHeight - qrCodeSize) / 2 / sizeScale)

        updateQueue.async {
            print("FIRST NODE")

            self.plane.width = planeWidth
            self.plane.height = planeHeight
            self.planeNode.geometry = self.plane
            self.createHostingController(for: self.planeNode)

            node.addChildNode(self.dumbNode)
            self.dumbNode.position = dumbNodePosition
            self.dumbNode.eulerAngles.x = -.pi / 2
            self.dumbNodeLastEulerAnglesDeque.append(self.dumbNode.eulerAngles)
            self.dumbNodeLastPositionDeque.append(self.dumbNode.position)
            self.dumbNodeLastStablePositionSample = self.dumbNode.position

            self.planeNode.setWorldTransform(self.dumbNode.worldTransform)
            self.sceneView.scene.rootNode.addChildNode(self.planeNode)
        }

        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }

    func renderer(_: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage

        let imageSize = referenceImage.physicalSize.width * imageAnchor.estimatedScaleFactor

        let sizeScale = qrCodeSize / imageSize

        let planeWidth = graphWidth / sizeScale
        let planeHeight = planeWidth

        let dumbNodePosition = SCNVector3(-((graphWidth + qrCodeSize) / 2 + padding) / sizeScale, 0, -(graphHeight - qrCodeSize) / 2 / sizeScale)

        if imageAnchor.isTracked {
//            print(node.position.x - dumbNodeLastStablePositionSample.x)

            if dumbNodeLastEulerAnglesDeque.count == 5 {
                _ = dumbNodeLastEulerAnglesDeque.popFirst()
            }

            if dumbNodeLastPositionDeque.count == 3 {
                _ = dumbNodeLastPositionDeque.popFirst()
            }

            dumbNodeLastEulerAnglesDeque.append(node.eulerAngles)
            dumbNodeLastPositionDeque.append(node.position)

            if isPositionAndEulerAnglesValid {
//                print("👆满足!")
                updateQueue.async {
                    self.plane.width = planeWidth
                    self.plane.height = planeHeight
                    self.dumbNode.position = dumbNodePosition

                    self.planeNode.setWorldTransform(self.dumbNode.worldTransform)
                }
            }
        }

    }

}
