//
//  ViewController.swift
//  TapPlane
//
//  Created by mking on 7/29/17.
//  Copyright © 2017 mking. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [UUID: SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Add light
        do {
            let light = SCNLight()
            light.type = .omni
            let node = SCNNode()
            node.light = light
            node.position = SCNVector3(0, 5, 0)
            scene.rootNode.addChildNode(node)
        }
        
        // Add box
        do {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.blue
            let geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
            geometry.materials = [material]
            let node = SCNNode(geometry: geometry)
            node.position = SCNVector3(0, 0, -5)
//            scene.rootNode.addChildNode(node)
        }
        
        // Add plane
        do {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            material.isDoubleSided = true
            let geometry = SCNPlane(width: 2, height: 2)
            geometry.materials = [material]
            let node = SCNNode(geometry: geometry)
            node.position = SCNVector3(0, 0, -5)
            node.eulerAngles = SCNVector3(Float.pi / Float(2), 0, 0)
            scene.rootNode.addChildNode(node)
        }
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Only keep track of the first plane...
        if planes.isEmpty, let planeAnchor = anchor as? ARPlaneAnchor {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            geometry.materials = [material]
            let node = SCNNode(geometry: geometry)
            node.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            node.transform = SCNMatrix4MakeRotation(-Float.pi / Float(2), 1, 0, 0)
            sceneView.scene.rootNode.addChildNode(node)
            planes[anchor.identifier] = node
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, let plane = planes[anchor.identifier], let geometry = plane.geometry as? SCNPlane {
            geometry.width = CGFloat(planeAnchor.extent.x)
            geometry.height = CGFloat(planeAnchor.extent.z)
            node.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        }
    }
    
    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        if let planeAnchor = anchor as? ARPlaneAnchor {
//            // Add box to represent plane
//            // This works, but the plane seems to be at eye level
//            print("+++ detect plane \(planeAnchor)")
//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor.red
//            material.isDoubleSided = true
//            let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//            geometry.materials = [material]
//            let node = SCNNode(geometry: geometry)
//            node.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
//            node.transform = SCNMatrix4MakeRotation(-Float.pi / Float(2), 1, 0, 0)
//            sceneView.scene.rootNode.addChildNode(node)
//            return nil
//        }
//
//        print("+++ detect other")
//        return nil
//    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
