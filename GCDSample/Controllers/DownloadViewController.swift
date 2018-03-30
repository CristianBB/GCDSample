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
    
    var asyncImg : AsyncImage?
    
    var segueId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        // Carga de imagen usando la clase AsyncImage
        let placeHolder = UIImage(named:"no-thumbnail.png")! // Imagen PlaceHolder
        asyncImg = AsyncImage(placeHolderImage: placeHolder,
                              remoteImageURL: imageUrl,
                              completion: { (img) in
                                // Muestra la imagen
                                self.imageView.image = img
                                
        })
        imageView.image = placeHolder

    }
    
}
