//
//  DownloadViewController.swift
//  GCDSample
//
//  Created by Cristian Blazquez Bustos on 22/3/18.
//  Copyright © 2018 Cbb. All rights reserved.
//

import UIKit

// Enum de identificadores segue
enum SegueIdentifier: String {
    case secuencialCazurro = "secuencialCazurro"
    case concurrenteBurro = "concurrenteBurro"
    case concurrenteCorrecto = "concurrenteCorrecto"
    case concurrenteEspabilao = "concurrenteEspabilao"
}

class DownloadViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activiyView: UIActivityIndicatorView!
 
    var segueId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard  let segueIdentifier = SegueIdentifier(rawValue: segueId) else {
            print("Use AsyncImage")
            return
        }

        switch segueIdentifier {
        case .secuencialCazurro:
            serialDownload(url: RemoteImages.url(.danny)!)
        case .concurrenteBurro:
            concurrentKludge(url: RemoteImages.url(.missandei)!)
        case .concurrenteCorrecto:
            correctConcurrent(url: RemoteImages.url(.olenna)!)
        case .concurrenteEspabilao:
            smartConcurrent(url: RemoteImages.url(.cersei)!, completion: { (image) in
                self.imageView.image = image
                self.activiyView.isHidden = true
                self.activiyView.stopAnimating()
            })
        }

//        switch RemoteImages.imageCase(forSegueId: segueId) {
//        case .danny:
//            serialDownload(url: RemoteImages.url(.danny)!)
//        case .missandei:
//            concurrentKludge(url: RemoteImages.url(.missandei)!)
//        case .olenna:
//            correctConcurrent(url: RemoteImages.url(.olenna)!)
//        case .cersei:
//            smartConcurrent(url: RemoteImages.url(.cersei)!, completion: { (image) in
//                self.imageView.image = image
//                self.activiyView.isHidden = true
//                self.activiyView.stopAnimating()
//            })
//
//        default:
//            print("Use AsyncImage")
//        }
    }
    
    // MARK: - Estrategias
    func serialDownload(url: URL) {
        // Gestion UI
        activiyView.isHidden = false
        activiyView.startAnimating()
        
        // Este codigo se ejecutará al salir de la función
        defer {
            activiyView.isHidden = true
            activiyView.stopAnimating()
        }
        
        if let imgData = try? Data(contentsOf: url),
            let image = UIImage(data: imgData) {
            
            imageView.image = image
        }
    }
    
    func concurrentKludge(url: URL) {
        // Gestion UI
        activiyView.isHidden = false
        activiyView.startAnimating()
        
        // Este codigo se ejecutará al salir de la función
        defer {
            activiyView.isHidden = true
            activiyView.stopAnimating()
        }
        
        DispatchQueue(label: "io.keepcoding.concurrent").async {
            if let imgData = try? Data(contentsOf: url),
                let image = UIImage(data: imgData) {
                
                self.imageView.image = image
            }
        }
        
        
    }
    
    func correctConcurrent(url: URL) {
        // Gestion UI
        activiyView.isHidden = false
        activiyView.startAnimating()
        
        
        DispatchQueue(label: "io.keepcoding.concurrent").async {
            if let imgData = try? Data(contentsOf: url),
                let image = UIImage(data: imgData) {
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.activiyView.isHidden = true
                    self.activiyView.stopAnimating()
                }
            }
        }
    }
    
    
    typealias UIImageTask = (UIImage)->() // Closure que recibe una UIImage y no devuelve nada
    func smartConcurrent(url: URL, completion:@escaping UIImageTask) {
        
        // No sé desde que cola  me llaman, pero sé que la preparación de la UI tiene que ser en primer plano
        DispatchQueue.main.async {
            self.activiyView.isHidden = false
            self.activiyView.startAnimating()
        
            // Me voy a segundo plano y aprovecho una de las colas del sistema
            DispatchQueue.global(qos:.default).async {
                if let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    
                    // No sé qué hará con la imagen la clausura de finalización, por si acaso lo hago en primer plano
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }
        
        
    }
    
}
