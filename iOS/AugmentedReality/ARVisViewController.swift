import ARKit
import SceneKit
import SwiftCSV
import SwiftUI
import UIKit
import DequeModule
import Combine

class ARVisViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet var blurView: UIVisualEffectView!

    let augmentedViewWidth: CGFloat = ImageGenerateHelper.graphWidth
    let augmentedViewHeight: CGFloat = ImageGenerateHelper.graphHeight

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

    @ObservedObject var viewModel = LineChartContainerViewModel(dataSources: SampleDataHelper.catSevNumOrderedSeries)

    private var subscribers: Set<AnyCancellable> = []

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.session.delegate = self

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }

        subscribers.insert(viewModel.$realTimeTrackingEnabled.sink(receiveValue: {
            if !$0 {
                if self.planeNode.parent != self.dumbNode {
                    self.updateQueue.async {
                        self.planeNode.removeFromParentNode()
                        self.dumbNode.addChildNode(self.planeNode)
                    }
                }
            }
        }))
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

    private func createHostingController(for node: SCNNode) {
        DispatchQueue.main.async {
            let viewController = UIViewController()
            viewController.view.frame = CGRect(x: 0, y: 0, width: self.maxAugmentedViewWH, height: self.maxAugmentedViewWH)
            viewController.view.isOpaque = false
            viewController.view.backgroundColor = .clear

//            let lineChartHostingVC = UIHostingController(rootView: LineChart(viewModel: self.viewModel))
            let lineChartHostingVC = UIHostingController(rootView: PieChart_Previews.previews)
            lineChartHostingVC.view.backgroundColor = .white
            lineChartHostingVC.view.frame = CGRect(x: 0, y: (self.maxAugmentedViewWH - self.augmentedViewHeight) / 2, width: self.augmentedViewWidth, height: self.augmentedViewHeight)

            viewController.view.addSubview(lineChartHostingVC.view)

            self.show(viewController: viewController, on: node)
        }
    }

    private func show(viewController: UIViewController, on node: SCNNode) {
        let material = SCNMaterial()
        material.diffuse.contents = viewController.view
        node.geometry?.materials = [material]
    }

    private var plane = SCNPlane()
    private var planeNode = SCNNode()

    // 当 `ARImageAnchor` 对应的 `SCNNode` 被隐藏时，将图表节点转移至该节点下。
    private var dumbNode = SCNNode()

    private var dumbNodeLastEulerAnglesDeque = Deque<SCNVector3>()
    private var dumbNodeLastPositionDeque = Deque<SCNVector3>()
    private var dumbNodeLastStableEulerAnglesSample = SCNVector3()
    private var dumbNodeLastStablePositionSample = SCNVector3()

    private func updateDumbNodeSample() {
//        print("Euler angle: \(dumbNodeLastEulerAnglesDeque.last!)")
        if isEulerAnglesValid {
//            print("👆满足")
            dumbNodeLastStableEulerAnglesSample = dumbNodeLastEulerAnglesDeque.last!
            dumbNode.eulerAngles = dumbNodeLastStableEulerAnglesSample
        }

//        print("Position: \(dumbNodeLastPositionDeque.last!)")
        if isPositionValid {
//            print("👆满足")
            dumbNodeLastStablePositionSample = dumbNodeLastPositionDeque.last!
            dumbNode.position = dumbNodeLastStablePositionSample
        }
    }

    private var isEulerAnglesValid: Bool {
        let maxEulerAnglesXRange = abs(dumbNodeLastEulerAnglesDeque.max { $0.x < $1.x }!.x - dumbNodeLastEulerAnglesDeque.min { $0.x < $1.x }!.x)
        let maxEulerAnglesYRange = abs(dumbNodeLastEulerAnglesDeque.max { $0.y < $1.y }!.y - dumbNodeLastEulerAnglesDeque.min { $0.y < $1.y }!.y)
        let maxEulerAnglesZRange = abs(dumbNodeLastEulerAnglesDeque.max { $0.z < $1.z }!.z - dumbNodeLastEulerAnglesDeque.min { $0.z < $1.z }!.z)

        if maxEulerAnglesXRange < 0.02, maxEulerAnglesYRange < 0.02, maxEulerAnglesZRange < 0.02 {
            return true
        }

        return false
    }

    private var isPositionValid: Bool {

        // TODO: - Magic Numebr `0.001` Should be Relative to Reference Image's Physical size I think.
        let maxPositionXRange = abs(dumbNodeLastPositionDeque.max { $0.x < $1.x }!.x - dumbNodeLastPositionDeque.min { $0.x < $1.x }!.x)
        let maxPositionYRange = abs(dumbNodeLastPositionDeque.max { $0.y < $1.y }!.y - dumbNodeLastPositionDeque.min { $0.y < $1.y }!.y)
        let maxPositionZRange = abs(dumbNodeLastPositionDeque.max { $0.z < $1.z }!.z - dumbNodeLastPositionDeque.min { $0.z < $1.z }!.z)

        if maxPositionXRange < 0.001, maxPositionYRange < 0.001, maxPositionZRange < 0.001 {
            return true
        }

        return false
    }

    private var supplementaryViewsAdded = false
    private func setupSupplementaryViews(initPosition: SCNVector3) {
        guard supplementaryViewsAdded == false else { return }

        supplementaryViewsAdded = true
        
        let generatedViewInfoComponent = SampleViewInfoComponentHelper.sampleViewInfoComponent
        let settingViewController = UIHostingController(rootView: generatedViewInfoComponent.view)
        
//        let settingViewController = UIHostingController(rootView: ARVisSettingView(items: $viewModel.dataSources, realTimeTrackingEnabled: $viewModel.realTimeTrackingEnabled))
        settingViewController.view.backgroundColor = .clear
        view.addSubview(settingViewController.view)

        let width: CGFloat = 325
        let height: CGFloat = 280
        let padding: CGFloat = 16
        let originX = view.frame.size.width - width - padding
        let originY = view.frame.size.height - height - padding
        let rect = CGRect(x: originX, y: originY, width: width, height: height)
        let transform: CGAffineTransform =
            .identity
            .translatedBy(x: CGFloat(initPosition.x) - originX - width / 2, y: CGFloat(initPosition.y) - originY - height / 2)
            .scaledBy(x: 0.5, y: 0.5)

        settingViewController.view.alpha = 0
        settingViewController.view.frame = rect
        settingViewController.view.transform = transform
        DispatchQueue.main.async {
            UIViewPropertyAnimator(duration: 0.7, curve: .easeInOut) {
                settingViewController.view.alpha = 1
                settingViewController.view.transform = .identity
                settingViewController.view.layoutIfNeeded()
            }.startAnimation()
        }
    }

    // MARK: - ARSCNViewDelegate (Image detection results)

    private func updatePosAndRot(for node: SCNNode, imageAnchor: ARImageAnchor) {
        let referenceImage = imageAnchor.referenceImage
        let imageSize = referenceImage.physicalSize.width * imageAnchor.estimatedScaleFactor

        let qrCodeSize = ImageGenerateHelper.qrCodeSize
        let graphWidth = ImageGenerateHelper.graphWidth
        let graphHeight = ImageGenerateHelper.graphHeight
        let padding = ImageGenerateHelper.padding

        let sizeScale = qrCodeSize / imageSize

        let planeWidth = graphWidth / sizeScale
        let planeHeight = planeWidth

        if let plane = node.geometry as? SCNPlane {
            plane.width = planeWidth
            plane.height = planeHeight
        }

        let position = SCNVector3(-((graphWidth + qrCodeSize) / 2 + padding) / sizeScale, 0, -(graphHeight - qrCodeSize) / 2 / sizeScale)
        let eulerAngles = SCNVector3(-CGFloat.pi / 2, 0, 0)
        node.position = position
        node.eulerAngles = eulerAngles
    }

    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        let referenceImage = imageAnchor.referenceImage

        self.dumbNodeLastPositionDeque.append(node.position)
        self.dumbNodeLastEulerAnglesDeque.append(node.eulerAngles)
        self.dumbNodeLastStablePositionSample = node.position
        self.dumbNodeLastStableEulerAnglesSample = node.eulerAngles

        updateQueue.async {
            self.planeNode.geometry = self.plane
            self.createHostingController(for: self.planeNode)

            node.addChildNode(self.planeNode)
            node.parent?.addChildNode(self.dumbNode)

            self.updatePosAndRot(for: self.planeNode, imageAnchor: imageAnchor)
        }

        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")

            let projectedPosition = self.sceneView.projectPoint(node.position)
            self.setupSupplementaryViews(initPosition: projectedPosition)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        guard viewModel.realTimeTrackingEnabled else { return }

        if imageAnchor.isTracked {
            if dumbNodeLastEulerAnglesDeque.count == 5 {
                _ = dumbNodeLastEulerAnglesDeque.popFirst()
            }

            if dumbNodeLastPositionDeque.count == 3 {
                _ = dumbNodeLastPositionDeque.popFirst()
            }

            self.dumbNodeLastPositionDeque.append(node.position)
            self.dumbNodeLastEulerAnglesDeque.append(node.eulerAngles)
            updateDumbNodeSample()

            updateQueue.async {
                if self.planeNode.parent != node {
                    self.planeNode.removeFromParentNode()
                    node.addChildNode(self.planeNode)
                }

                self.updatePosAndRot(for: self.planeNode, imageAnchor: imageAnchor)
            }
        } else {
            if planeNode.parent == node {
                updateQueue.async {
                    self.planeNode.removeFromParentNode()
                    self.dumbNode.addChildNode(self.planeNode)
                }
            }
        }
    }
}
