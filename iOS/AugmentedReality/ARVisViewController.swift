import ARKit
import SceneKit
import SwiftCSV
import SwiftUI
import UIKit
import DequeModule
import Combine
import SnapKit

class ARVisViewControllerViewModel: ObservableObject {
    @Published var realTimeTrackingEnabled = true
}

class ARVisViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet var blurView: UIVisualEffectView!

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

        // Combine Subscribers
        arViewModel.$realTimeTrackingEnabled
            .sink {
                if !$0 {
                    if self.planeNode.parent != self.dumbNode {
                        self.updateQueue.async {
                            self.planeNode.removeFromParentNode()
                            self.dumbNode.addChildNode(self.planeNode)
                        }
                    }
                }
            }
            .store(in: &subscribers)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
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

        dumbNodeLastPositionDeque = []
        dumbNodeLastEulerAnglesDeque = []

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
    }

    // MARK: - Properties

    let augmentedViewWidth: CGFloat = ImageGenerateHelper.graphWidth
    let augmentedViewHeight: CGFloat = ImageGenerateHelper.graphHeight

    var maxAugmentedViewWH: CGFloat {
        max(augmentedViewWidth, augmentedViewHeight)
    }

    private var plane = SCNPlane()
    private var planeNode = SCNNode()
    // 当 `ARImageAnchor` 对应的 `SCNNode` 被隐藏时，将图表节点转移至该节点下。
    private var dumbNode = SCNNode()

    private var dumbNodeLastEulerAnglesDeque = Deque<SCNVector3>()
    private var dumbNodeLastPositionDeque = Deque<SCNVector3>()
    private var dumbNodeLastStableEulerAnglesSample = SCNVector3()
    private var dumbNodeLastStablePositionSample = SCNVector3()

    private var isFirstTrack = true
    private var isSupplementaryViewSettle = false

    @ObservedObject var arViewModel = ARVisViewControllerViewModel()

    private var chartViewModel: ChartViewModel?
    private var chartViewController: UIViewController?
    private var chartViewDumbSuperViewController: UIViewController?

    private var subscribers: Set<AnyCancellable> = []

    private var chartViewExpanded: Bool = false
    private var chartViewExpansionAnimating: Bool = false
    private var viewInfoExpanded: Bool = false
}

// MARK: - Create Chart View Controller and Render into Material

extension ARVisViewController {

    private func createHostingController(for node: SCNNode) {
        DispatchQueue.main.async {
            let viewController = UIViewController()
            self.chartViewDumbSuperViewController = viewController
            viewController.view.frame = CGRect(x: 0, y: 0, width: self.maxAugmentedViewWH, height: self.maxAugmentedViewWH)
            viewController.view.isOpaque = false
            viewController.view.backgroundColor = .clear

//            let chartHostingVC = UIHostingController(rootView: LineChart(viewModel: self.viewModel))

            let pieChartViewModel = PieChartViewModel(itemGroups: [
                SamplePieChartDataHelper.SamplePieChartDataTGCategoryLocItemGroup(),
                SamplePieChartDataHelper.SamplePieChartDataTGCategoryFileCountItemGroup(),
                SamplePieChartDataHelper.SamlePieChartDataTGCategorySubmoduleItemGroup()
            ],
                                                      defaultItemGroupIndex: 0,
                                                      borderColor: .white)
            self.chartViewModel = pieChartViewModel
            let chartHostingVC = UIHostingController(rootView: PieChart().environmentObject(pieChartViewModel))
            self.chartViewController = chartHostingVC
            chartHostingVC.view.backgroundColor = .white
            chartHostingVC.view.frame = CGRect(x: 0, y: (self.maxAugmentedViewWH - self.augmentedViewHeight) / 2, width: self.augmentedViewWidth, height: self.augmentedViewHeight)

            viewController.view.addSubview(chartHostingVC.view)

            self.show(viewController: viewController, on: node)

            // fetch ARImageAnchor's corresponding node.
            let projectedPosition = self.sceneView.projectPoint(node.parent!.position)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupSupplementaryViews(initPosition: projectedPosition)
            }
        }
    }

    private func show(viewController: UIViewController, on node: SCNNode) {
        let material = SCNMaterial()
        material.diffuse.contents = viewController.view
        node.geometry?.materials = [material]
    }

}

// MARK: - ARSCNViewDelegate (Image detection results)

extension ARVisViewController {

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
            node.addChildNode(self.planeNode)
            node.parent?.addChildNode(self.dumbNode)

            if self.isFirstTrack {
                self.planeNode.geometry = self.plane
                self.createHostingController(for: self.planeNode)
                self.isFirstTrack = false
            }

            self.updatePosAndRot(for: self.planeNode, imageAnchor: imageAnchor)
        }

        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        guard arViewModel.realTimeTrackingEnabled else { return }

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

// MARK: - Setup Supplementary Views

extension ARVisViewController {

    private func setupSupplementaryViews(initPosition: SCNVector3) {
        guard !isSupplementaryViewSettle else { return }
        isSupplementaryViewSettle = true

        setupSettingView(initPosition: initPosition)
        setupAttachedViewInfoView(initPosition: initPosition)
        setupChartViewExpandButton()
    }

    private func setupChartViewExpandButton() {
        let buttonHeight: CGFloat = 50
        let padding: CGFloat = 16
        // ExpandButton declaration
        let expandButtonViewController = vibrantButtonWith(systemImage: "arrow.up.left.and.arrow.down.right") {
            guard !self.chartViewExpansionAnimating else { return }
            if let chartView = self.chartViewController?.view, let chartViewDumbSuperViewController = self.chartViewDumbSuperViewController {
                if !self.chartViewExpanded {
                    self.planeNode.isHidden = true
                    self.planeNode.geometry?.materials = []
                    self.view.insertSubview(chartView, aboveSubview: self.sceneView)
                    chartView.layer.cornerRadius = 20
                    chartView.snp.makeConstraints { make in
                        make.edges.equalToSuperview().inset(ConstraintInsets(top: 2 * padding + buttonHeight, left: padding, bottom: 2 * padding + buttonHeight, right: padding))
                    }
                    chartView.transform = .identity.translatedBy(x: 0, y: self.view.frame.height)
                    UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                        self.chartViewExpansionAnimating = true
                        chartView.transform = .identity
                    } completion: { completed in
                        if completed {
                            self.chartViewExpansionAnimating = false
                        }
                    }
                } else {
                    UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
                        self.chartViewExpansionAnimating = true
                        chartView.transform = .identity.translatedBy(x: 0, y: self.view.frame.height)
                    } completion: { completed in
                        if completed {
                            self.planeNode.isHidden = false
                            chartView.snp.removeConstraints()
                            chartView.translatesAutoresizingMaskIntoConstraints = true
                            chartView.layer.cornerRadius = 0
                            chartView.removeFromSuperview()
                            chartViewDumbSuperViewController.view.addSubview(chartView)
                            chartView.frame = CGRect(x: 0, y: (self.maxAugmentedViewWH - self.augmentedViewHeight) / 2, width: self.augmentedViewWidth, height: self.augmentedViewHeight)
                            self.show(viewController: chartViewDumbSuperViewController, on: self.planeNode)
                            self.chartViewExpansionAnimating = false
                        }
                    }
                }
                self.chartViewExpanded.toggle()
            }
        }

        self.view.addSubview(expandButtonViewController.view)
        expandButtonViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(buttonHeight)
        }
    }

    // swiftlint:disable function_body_length
    private func setupAttachedViewInfoView(initPosition: SCNVector3) {
        let buttonHeight: CGFloat = 50
        let padding: CGFloat = 16
        let width: CGFloat = 325
        let height: CGFloat = 280
        let originX = padding
        let originY = 2 * padding + buttonHeight
        let rect = CGRect(x: originX, y: originY, width: width, height: height)

        // ViewInfoView declaration
        let generatedViewInfoComponent = SampleViewInfoComponentHelper.sampleViewInfoComponent
        let viewInfoViewController = UIHostingController(rootView: ARVisInfoView(viewInfoComponents: [generatedViewInfoComponent]))

        // ExpandButton declaration
        let expandButtonViewController = vibrantButtonWith(systemImage: "arrow.up.left.and.arrow.down.right") {
            UIView.animate(withDuration: 1.0) {
                if self.viewInfoExpanded {
                    viewInfoViewController.view.snp.updateConstraints { make in
                        make.width.equalTo(width)
                        make.height.equalTo(height)
                    }
                } else {
                    let maxWidth = self.view.frame.width - padding * 2
                    let expandWidth = width * 2 < maxWidth ? width * 2 : maxWidth
                    let maxHeight = self.view.frame.height - padding * 2
                    let expandHeight = height * 2 < maxHeight ? height * 2 : maxHeight
                    viewInfoViewController.view.snp.updateConstraints { make in
                        make.width.equalTo(expandWidth)
                        make.height.equalTo(expandHeight)
                    }
                }
                viewInfoViewController.view.setNeedsUpdateConstraints()
                viewInfoViewController.view.superview?.layoutIfNeeded()

                self.viewInfoExpanded.toggle()
            }
        }

        // HideButton declaration
        let hideButtonViewController = vibrantButtonWith(primaryText: "Hide", secondaryText: "Show") {
            UIView.animate(withDuration: 0.5) {
                viewInfoViewController.view.alpha = 1 - viewInfoViewController.view.alpha
                expandButtonViewController.view.alpha = 1 - expandButtonViewController.view.alpha
            }
        }

        self.view.addSubview(hideButtonViewController.view)
        hideButtonViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(padding)
            make.leading.equalToSuperview().inset(padding)
            make.height.equalTo(buttonHeight)
        }

        showViewControllerWithMagicMoveAnimation(viewController: viewInfoViewController, in: rect, initPosition: initPosition) {
            viewInfoViewController.view.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(padding)
                make.top.equalTo(hideButtonViewController.view.snp.bottom).offset(padding)
                make.bottom.lessThanOrEqualToSuperview().inset(padding).priority(.required)
                make.trailing.lessThanOrEqualToSuperview().inset(padding).priority(.required)

                make.width.equalTo(width)
                make.height.equalTo(height)
            }
        }

        self.view.addSubview(expandButtonViewController.view)
        expandButtonViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(padding)
            make.leading.equalTo(hideButtonViewController.view.snp.trailing).offset(padding)
            make.height.equalTo(buttonHeight)
        }
    }

    private func setupSettingView(initPosition: SCNVector3) {
        let padding: CGFloat = 16

        var settingComponents: [AnyARVisSettingViewComponent] = [
            .trackingComponent(realTimeTrackingEnabled: $arViewModel.realTimeTrackingEnabled)
        ]

        if let chartViewModel = chartViewModel {
            if let pieChartViewModel = chartViewModel as? PieChartViewModel {
                settingComponents.append(.toggleableComponent(sectionName: pieChartViewModel.itemLabelShowingToggleableSection.section,
                                                              toggleableItems: pieChartViewModel.itemLabelShowingToggleableSection.items))
            }
        }

        let settingViewController = UIHostingController(rootView: ARVisSettingView(sectionComponents: settingComponents))

        let hideButtonViewController = vibrantButtonWith(primaryText: "Hide", secondaryText: "Show") {
            UIView.animate(withDuration: 0.5) {
                settingViewController.view.alpha = 1 - settingViewController.view.alpha
            }
        }

        let buttonHeight: CGFloat = 50
        self.view.addSubview(hideButtonViewController.view)
        hideButtonViewController.view.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(padding)
            make.bottom.equalToSuperview().inset(padding)
            make.height.equalTo(buttonHeight)
        }

        let width: CGFloat = 325
        let height: CGFloat = 280
        let originX = view.frame.size.width - width - padding
        let originY = view.frame.size.height - height - 2 * padding - buttonHeight
        let rect = CGRect(x: originX, y: originY, width: width, height: height)
        showViewControllerWithMagicMoveAnimation(viewController: settingViewController, in: rect, initPosition: initPosition) {
            settingViewController.view.snp.makeConstraints { make in
                make.trailing.equalTo(hideButtonViewController.view)
                make.bottom.equalTo(hideButtonViewController.view.snp.top).inset(-padding)
                make.size.equalTo(CGSize(width: width, height: height))
            }
        }
    }

    private func showViewControllerWithMagicMoveAnimation(viewController: UIViewController, in rect: CGRect, initPosition: SCNVector3, completion: @escaping () -> Void) {
        viewController.view.backgroundColor = .clear
        view.addSubview(viewController.view)

        let transform: CGAffineTransform =
            .identity
            .translatedBy(x: CGFloat(initPosition.x) - rect.minX - rect.width / 2, y: CGFloat(initPosition.y) - rect.minY - rect.height / 2)
            .scaledBy(x: 0.5, y: 0.5)

        viewController.view.alpha = 0
        viewController.view.frame = rect
        viewController.view.transform = transform
        DispatchQueue.main.async {
            let animator = UIViewPropertyAnimator(duration: 0.7, curve: .easeInOut) {
                viewController.view.alpha = 1
                viewController.view.transform = .identity
                viewController.view.layoutIfNeeded()
            }
            animator.addCompletion { position in
                if position == .end {
                    completion()
                }
            }
            animator.startAnimation()
        }
    }

    private func vibrantButtonWith(text: String, action: @escaping () -> Void) -> UIViewController {
        let viewController = UIHostingController(rootView: VibrantTextButton(text: text, action: action))
        let view = viewController.view!
        view.backgroundColor = .clear
        return viewController
    }

    private func vibrantButtonWith(primaryText: String, secondaryText: String, action: @escaping () -> Void) -> UIViewController {
        let viewController = UIHostingController(rootView: VibrantTwoStatesTextButton(primaryText: primaryText, secondaryText: secondaryText, action: action))
        let view = viewController.view!
        view.backgroundColor = .clear
        return viewController
    }

    private func vibrantButtonWith(systemImage: String, action: @escaping () -> Void) -> UIViewController {
        let viewController = UIHostingController(rootView: VibrantImageButton(systemName: systemImage, action: action))
        let view = viewController.view!
        view.backgroundColor = .clear
        return viewController
    }
}
