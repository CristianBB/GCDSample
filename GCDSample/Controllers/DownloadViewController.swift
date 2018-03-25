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
            smartConcurrent(url: RemoteImages.url(.danny)!, completion: { (image) in
                self.imageView.image = image
                self.activiyView.isHidden = true
                self.activiyView.stopAnimating()
            })
        case .concurrenteBurro:
            smartConcurrent(url: RemoteImages.url(.missandei)!, completion: { (image) in
                self.imageView.image = image
                self.activiyView.isHidden = true
                self.activiyView.stopAnimating()
            })
        case .concurrenteCorrecto:
            smartConcurrent(url: RemoteImages.url(.olenna)!, completion: { (image) in
                self.imageView.image = image
                self.activiyView.isHidden = true
                self.activiyView.stopAnimating()
            })
        case .concurrenteEspabilao:
            smartConcurrent(url: RemoteImages.url(.cersei)!, completion: { (image) in
                self.imageView.image = image
                self.activiyView.isHidden = true
                self.activiyView.stopAnimating()
            })
        }

    }
    
    // MARK: - Estrategias
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
