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

// Struct para la descarga de imagenes en cola secundaria con closures de ejecución inicial y final
struct ConcurrentImageDownload {
    typealias initTask = () -> () // Closure para ejecución de tareas iniciales, no recibe parametros ni devuelve nada
    typealias UIImageTask = (UIImage)->() // Closure que recibe una UIImage y no devuelve nada
    
    static func download(url: URL, initTask: @escaping initTask, completion:@escaping UIImageTask) {
        // La closure initTask se ejecuta en cola principal
        DispatchQueue.main.async {
            initTask()
            
            // Me voy a segundo plano y aprovecho una de las colas del sistema
            DispatchQueue.global(qos:.default).async {
                if let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    
                    // No sé qué hará con la imagen la closure de finalización, por si acaso lo hago en primer plano
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }
    }
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

        var imageUrl: URL
        switch segueIdentifier {
        case .secuencialCazurro:
            imageUrl = RemoteImages.url(.danny)!
        case .concurrenteBurro:
            imageUrl = RemoteImages.url(.missandei)!
        case .concurrenteCorrecto:
            imageUrl = RemoteImages.url(.olenna)!
        case .concurrenteEspabilao:
            imageUrl = RemoteImages.url(.cersei)!
        }
        
        ConcurrentImageDownload.download(url: imageUrl, initTask: {
            self.activiyView.isHidden = false
            self.activiyView.startAnimating()
        }) { (image) in
            self.imageView.image = image
            self.activiyView.isHidden = true
            self.activiyView.stopAnimating()
        }

    }
    
}
