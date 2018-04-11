//
//  ViewController.swift
//  ARDicee
//
//  Created by riccardo silvi on 09/04/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assegnazione delegato
        sceneView.delegate = self
        
        
        
        /***OGGETTO CUBO***/
        
        //creiamo un nostro oggetto da visualizzare
        //l'unità di misura è il metro
        
        let cube =  SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.001)
        
        //personalizziamo l'oggetto assegnandogli un colore
        
        let cubeMaterial = SCNMaterial()
        
        cubeMaterial.diffuse.contents = UIColor.red
        
        cube.materials = [cubeMaterial]
        
        //creiamo un SCNNode(un punto in uno spazio tridimensionale)
        //Sarà il punto in cui sarà visualizzato l'SCNBOX
        
        let cubeNode = SCNNode()
        
        //nell'asse x e  y 0 rappresenta il centro
        //asse x valore negativo è la sinistra, positivo la destra
        //asse y valore negativo è il basso, positivo alto
        //asse z valore negativo porta l'oggetto più vicino, positivo più distante
        
        cubeNode.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
        
        // assegniamo le caratteristiche del punto
        //nello spazio definito al cubo da noi creato
        
        cubeNode.geometry = cube
        
        //lo aggiungiamo alla sceneView
        
        sceneView.scene.rootNode.addChildNode(cubeNode)
        
        
        /***OGGETTO SFERA***/
        
        //creiamo una sfera
        
        let moonSphere = SCNSphere(radius: 0.3)
        
        //e gli applichiamo la texture della luna
        
        let sphereMaterial = SCNMaterial()
        
        sphereMaterial.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")!
        
        moonSphere.materials = [sphereMaterial]
        
        //creiamo un punto  nello spazio e glielo passiamo
        
        let sphereNode = SCNNode()
        
        sphereNode.position = SCNVector3(x: 0.5, y: 0.5, z: -1)
        
        sphereNode.geometry = moonSphere
        
        //lo aggiungiamo alla sceneView
        
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        /***OGGETTO DADO DA .DAE FILE***/
        
        //Se al percorso viene trovato una scene con node "diceCollada.scn"
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
            //aggiungi la scena al root Node con nome "Dice"(definito nell'inspector)
            //l'attributo recursively-true include anche i childNodes rispetto a quello in oggetto
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            //definiamo una posizione
            
            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
        }
        
       
        
        
        
        //aggiungiamo effetti di luce(ombre per gli oggetti)
        
        sceneView.autoenablesDefaultLighting = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        
        //Stampiamo in console lo stato di compatibilità della sessione AR
        
        print("Sessione AR supportata = \(ARConfiguration.isSupported)")
        
        print("Sessione AR 6D supportata = \(ARWorldTrackingConfiguration.isSupported)")
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
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
}
