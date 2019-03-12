/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var sceneView: VirtualObjectARView!
    
    @IBOutlet weak var addObjectButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var saveExperience: UIBarButtonItem!
    
    @IBOutlet weak var OrientationArrow: UIImageView!
    
    /// A list storing the objects we must visit in order
    var objectQueue: [VirtualObject] = []
    
    var palaces = [MemoryPalace]()
    
    let selection = UISelectionFeedbackGenerator()
    
    var focusSquare = FocusSquare()
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// The view controller that displays the virtual object selection menu.
    var objectsViewController: VirtualObjectSelectionViewController?
    
    // MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView)
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mapDataFromFile != nil {
           print("hahahaaaaaa nope")
        }
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        sceneView.setupDirectionalLighting(queue: updateQueue)

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showVirtualObjectSelectionViewController))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        // Start the `ARSession`.
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.pause()
    }

    // MARK: - Scene content setup

    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }

        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }

    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        virtualObjectInteraction.selectedObject = nil
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }

    // MARK: - Focus Square

    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
        if let currentPosition = session.currentFrame?.camera.transform {
                                // print(position[3][0])
            if objectQueue.count > 0 {
                let objectPosition = objectQueue[0].transform
                let deltaZ = objectPosition.m43 - currentPosition[3][2]
                let deltaX = objectPosition.m41 - currentPosition[3][0]
                                            let deltaTheta = atan2(deltaZ, deltaX)
                                            var rotationAngle: Float = 0.0
                                            if let currentPosition = session.currentFrame?.camera.eulerAngles {
                                                        print(deltaTheta - currentPosition[1] + 1.5708)
                                                        rotationAngle = (deltaTheta - currentPosition[1] + 1.5708)
                                                }
                                            
                                            OrientationArrow.transform = CGAffineTransform.init(rotationAngle: CGFloat(-1.0 * rotationAngle))
                                    }
                        }
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
            addObjectButton.isHidden = false
            statusViewController.cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addObjectButton.isHidden = true
        }
        
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - ARSessionObserver
    
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
//        sessionInfoLabel.text = "Session was interrupted"
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required.
//        sessionInfoLabel.text = "Session interruption ended"
//    }
//
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user.
//        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
//        resetTracking(nil)
//    }
//
//    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
//        return true
//    }
//
    

    
    @IBAction func saveExperiencePressed(_ sender: UIBarButtonItem) {
        print("button was pressed")
        
        if #available(iOS 12.0, *) {
            sceneView.session.getCurrentWorldMap { worldMap, error in
                guard let map = worldMap
                    else {
                        let alert = UIAlertController(title: ":(", message: "Can't get current world map: " + error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        return
                }
                // Add a snapshot image indicating where the map was captured.
                //                guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
                //                    else { fatalError("Can't take snapshot") }
                //                map.anchors.append(snapshotAnchor)
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    try data.write(to: self.mapSaveURL, options: [.atomic])
                    DispatchQueue.main.async {
                        //self.loadExperienceButton.isHidden = false
                        //self.loadExperienceButton.isEnabled = true
                    }
                    print("saved!")
                } catch {
                    fatalError("Can't save map: \(error.localizedDescription)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()
    
    var mapData = [Data]()
    
    static var isRelocalizingMap = false
    
    static var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        } else {
            // Fallback on earlier versions
        }
        return configuration
    }
    
    var mapDataFromFile: Data? {
        return try? Data(contentsOf: mapSaveURL)
    }
    
    @IBAction func loadExperience(_ button: UIButton) {
        
        /// - Tag: ReadWorldMap
        if #available(iOS 12.0, *) {
            let worldMap: ARWorldMap = {
                guard let data = mapDataFromFile
                    else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
                do {
                    guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                        else { fatalError("No ARWorldMap in archive.") }
                    return worldMap
                } catch {
                    fatalError("Can't unarchive ARWorldMap from file data: \(error)")
                }
            }()
            
            let configuration = ViewController.defaultConfiguration // this app's standard world tracking settings
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            ViewController.isRelocalizingMap = true
        } else {
            // Fallback on earlier versions
        }
        
        // Display the snapshot image stored in the world
     
        //virtualObjectAnchor = nil
    }
    
    @IBAction func loadExp(_ sender: UIButton) {
        /// - Tag: ReadWorldMap
        if #available(iOS 12.0, *) {
            let worldMap: ARWorldMap = {
                guard let data = mapDataFromFile
                    else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
                do {
                    guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                        else { fatalError("No ARWorldMap in archive.") }
                    return worldMap
                } catch {
                    fatalError("Can't unarchive ARWorldMap from file data: \(error)")
                }
            }()
            
            let configuration = ViewController.defaultConfiguration // this app's standard world tracking settings
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            ViewController.isRelocalizingMap = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        var memoryPalace = MemoryPalace(name: "Lol", photo: nil, data: mapDataFromFile!)
        if (memoryPalace != nil)
        {
            //palaces.append(memoryPalace)
        }
    }
    
    
}
