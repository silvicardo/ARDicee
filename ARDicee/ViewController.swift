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
        
        //mostra i punti tramite i quali avviene il riconoscimento di supercici orizzontali
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
        
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
        
        //aggiungiamo effetti di luce(ombre per gli oggetti)
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Aggiungiamo rilevamento piani orizzontali
        
        configuration.planeDetection = .horizontal
        
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
    

    // MARK: - ARSCNViewDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        //touches è un set di oggetti di UITouch
        //ne estraiamo solo il primo tocco(evitiamo multitouch)
        if let touch = touches.first {
            //La posizione del tocco nella sceneView
            let touchLocation = touch.location(in: sceneView)
            //il display è in 2d quindi per convertire il tocco nello spazio 3d
            //il metodo hitTest aggiunge la profondità al tocco
            
            let results : [ARHitTestResult] = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            //Comunichiamo in console la posizione del tocco rispetto al piano rilevato
            if !results.isEmpty {
                print("Oggetto toccato nel piano orizzontale")
            } else {
                print("Oggetto toccato al di fuori del piano")
            }
            
            // se l'array result non è vuoto ne estraiamo il primo valore
            if let hitResult = results.first {
                // e vi posizioniamo
                //l'oggetto DADO da File .DAE
                
                //Se al percorso viene trovato una scene con node "diceCollada.scn"
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                //aggiungi la scena al root Node con nome "Dice"(definito nell'inspector)
                //l'attributo recursively-true include anche i childNodes rispetto a quello in oggetto
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    //la posizione del dado sarà il punto toccato sul piano selezionato
                    
                    //worldTransform è matrice 4x4 di float
                    //4 colonne x 4 righe
                    //definiscono scale, rotation e position
                    //la quarta colonna(3) ci da la posizione
                    let hitResultPosition = hitResult.worldTransform.columns.3
                    //la posizione del dado sarà data dai piani
                    //corrispondenti nella posizione appena definita
                    //correggiamo la proprietà y aggiungendo il raggio dell'oggetto.
                    //In pratica aggiungiamo la metà della sua altezza
                    //così da farlo posizionare subito sopra al piano
                    diceNode.position = SCNVector3(x: hitResultPosition.x,
                                                   y: hitResultPosition.y + diceNode.boundingSphere.radius,
                                                   z: hitResultPosition.z)
                    
                    //aggiugniamo il dado alla scene
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                }
            }
            
        }
    }
    
    //Se viene rilevata una superficie orizzontale vi assegna  widht+height(ARAnchor)
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //controlliamo se l'ARAnchor corrisponde ad un piano orizzontale
        if anchor is ARPlaneAnchor {
            print("planeDetected")
            //se lo è creiamo un ARPlaneAnchor dal valore di anchor
            let planeAnchor = anchor as! ARPlaneAnchor
            
            //creiamo uno scenePlane dalla larghezza e profondità di planeAnchor
            //Uno ScenePlane va ideato come superficie orizzontale le cui dimensioni
            //vengono assegnate nella sua rappresentazione verticale
            //l'asse x del plane è l'asse x dell'anchor(la regolare larghezza)
            //l'asse y del plane è l'asse z (profondità) dell'anchor
            //l'asse z non è prevista in un SCNPlane
            
            let scnPlane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            //creiamo un punto nello spazio da aggiungere alla scene
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            //dobbiamo ruotare di 90° il plane per far si che si "appoggi"all'asse umano x
            //angle definisce l'angolo di rotazione(Float.pi = 180° in senso antiorario)
            //1 o 0 fa da vero/falso per l'attivazione della rotazione per quegli assi
            //in questo caso va girato solo dall'asse x
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            //applichiamo al piano l'immagine png griglia
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.sncassets/grid.png")
            
            scnPlane.materials = [gridMaterial]
            
            //le misure del planeNode sono quelle dello scenePlane
            
            planeNode.geometry = scnPlane
            
            //a partire dall'input della funzione(node) aggiungiamo il planeNode creato
            
            node.addChildNode(planeNode)
            
            
        } else {
            return
        }
        
        
    }
    
    
    
    
}
