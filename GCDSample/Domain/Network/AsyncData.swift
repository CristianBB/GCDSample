//
//  AsyncData.swift
//  GCDSample
//
//  Created by Cristian Blazquez Bustos on 27/3/18.
//  Copyright © 2018 Cbb. All rights reserved.
//

import UIKit

typealias ImageCompletion = (UIImage) -> ()
let nopCompletion = {(_: UIImage) in } // Completion closure que no hace nada, necesaria para que el compilador permita definir una closura opcional como parametro de entrada

// MARK: - Classes
open // Permite el acceso a la clase desde fuera del módulo, usado para definir Frameworks
class AsyncImage {
    
    private var placeHolderImage: UIImage
    private let remoteImageURL: URL
    private var localImage: UIImage?
    private let queue: DispatchQueue
    private var completion: ImageCompletion
    private weak var delegate: AsyncImageDelegate?
    
    // Propiedad computada que devuelve la imagen placeHolder o la Remota (si ya está cargada)
    var image: UIImage {
        get{
            guard let img = localImage else {
                return placeHolderImage
            }
            return img
        }
    }
    
    // MARK: - Init
    // Inicializador Designado: El resto de inits utilizan éste mismo. Provee una Completion Closure que no hace nada por defecto
    init(placeHolderImage img: UIImage, remoteImageURL url: URL, downloadQueue: DispatchQueue, completion: @escaping ImageCompletion = nopCompletion) {
        placeHolderImage = img
        remoteImageURL = url
        queue = downloadQueue
        self.completion = completion
        
        // Comienza la descarga
        loadImage(remoteURL: url)
    }
    
}

// MARK: - Convenience inits
extension AsyncImage {
    
    // Uso de cola privada sin completion closure
    convenience init(placeHolderImage img: UIImage, remoteImageURL url: URL) {
        self.init(placeHolderImage: img, remoteImageURL: url, downloadQueue: DispatchQueue(label: "io.keepcoding.AsyncImage<\(url)>"))
    }
    
    // Uso de cola privada con completion closure
    convenience init(placeHolderImage img: UIImage, remoteImageURL url: URL, completion : @escaping ImageCompletion){
        
        self.init(placeHolderImage: img, remoteImageURL: url,
                  downloadQueue: DispatchQueue(label: "io.keepcoding.AsyncImage<\(url)>"),
                  completion: completion)
        
    }
    
}

// MARK: - Downloading
extension AsyncImage {
    func downloadRemoteImage(remoteURL: URL) {
        queue.async {
            
            // Notifica al delegado en la cola principal
            DispatchQueue.main.async {
                self.delegate?.asyncImage(self, willDownloadImageAt: remoteURL)
            }
            
            if let data = try? Data(contentsOf: self.remoteImageURL),
                let img = UIImage(data: data) {
                
                // Almacena imagen en cache
                _ = self.saveToLocalStorage(remoteURL: remoteURL, image: img)
                
                // Si todo va bien, intercambia las imagenes en la cola principal
                DispatchQueue.main.async { [weak self] in   //Para evitar la referencia ciclica de self a completion y completion a self
                    self?.localImage = img
                    self?.completion(img)
                    
                    // Avisa a delegado
                    self?.delegate?.asyncImage(self!, didDownloadImageAt: remoteURL)
                    
                    // Envía notificación
                    self?.postCompletionNotification((self?.createCompletionNotification(image: img))!)
                }
            }
        }
    }
}

// MARK: - Delegate Protocol
protocol AsyncImageDelegate : AnyObject{
    
    func asyncImage(_ ai: AsyncImage, willDownloadImageAt url: URL)
    func asyncImage(_ ai: AsyncImage, didDownloadImageAt url: URL)
    
}

// Implementación por defecto que no hace nada: De este modo el delegado solo tiene que definir los metodos que necesite en lugar de todos
extension AsyncImageDelegate{
    func asyncImage(_ ai: AsyncImage, willDowloadImageAt url: URL){}
    func asyncImage(_ ai: AsyncImage, didDownloadImageAt url: URL){}
}

// MARK: - Notifications
extension AsyncImage {
    
    // Constantes de tipo "open" para que puedan accederse desde cualquier lugar
    open static let CompletionNotificationName = Notification.Name(rawValue: "io.keepcoding.AsyncImage.DidDownload")
    open static let CompletionNotificationImageKey = "Image"
    
    private func createCompletionNotification(image: UIImage)->Notification{
        let n = Notification(name:  AsyncImage.CompletionNotificationName,
                             object: self,
                             userInfo: [AsyncImage.CompletionNotificationImageKey: image])
        return n
    }
    
    private func postCompletionNotification(_ n: Notification){
        let nc = NotificationCenter.default
        nc.post(n)
    }

}

// MARK : - Cache
extension AsyncImage{
    
    private func loadImage(remoteURL: URL){
        
        // Busca la imagen en la cache, intercambia las imagenes y envía los avisos oportunos
        self.delegate?.asyncImage(self, willDowloadImageAt: remoteURL)
        queue.async {
            if let localImage = self.loadLocalImage(remoteURL: remoteURL){
                self.localImage = localImage
                
                DispatchQueue.main.async {
                    self.delegate?.asyncImage(self, didDownloadImageAt: remoteURL)
                    self.completion(localImage)
                    self.postCompletionNotification(self.createCompletionNotification(image: localImage))
                }
            } else {
                // Imagen no encontrada, a descargarla
                self.downloadRemoteImage(remoteURL: remoteURL)
                
            }
            
        }
        
    }
    
    // Función para crear una nombre de archivo "unico"
    private func createUniqueFileName(url: URL)->String{
        // Can't use hashValue, as it's not guaranteed to be equal in
        // different executions of the program: https://apple.co/2pPZszS
        // The best solution would be to create an MD5 or sha of the url, but
        // that would require bridging into CommonCrypto.
        // Cant use the URL directly either, as the max size of urls is 2k chars.
        // The total max path size in iOS is 1024 and the filename part is much
        // lower: 255 chars.
        // According to this article (https://bit.ly/2Ib6Yg7), you better stay
        // substantially below MAX_PATH (1024 chars).
        // Let's use the first 'maxChars' of the url and hope for the best.
        // Worst case scenario, we'll cause a cache miss
        
        let maxChars = 150
        var fileName = "io.keepcoding.AsyncImage.cache."
        
        if let host = url.host, let query = url.query{
            fileName =  fileName.appending(host + url.path + query)
        }else{
            fileName = fileName.appending(url.path)
        }
        
        fileName = fileName.replacingOccurrences(of: "/", with: "-")
        
        let prefix = String(fileName.prefix(maxChars))
        
        return prefix
    }
    
    // Directorio de caches, devolverá nil si no puede encontrar las caches
    private var cachesURL : URL?{
        get{
            let fm = FileManager.default
            let urls = fm.urls(for: .cachesDirectory, in: .userDomainMask)
            
            return urls.last
        }
    }
    
    // Devuelve la URL local de la imagen, si no existe devuelve nil
    private func localURLFor(remote:URL) -> URL?{
        
        let fileURL = cachesURL?.appendingPathComponent(createUniqueFileName(url: remote))
        return fileURL
        
    }
    
    // Carga la imagen local, si no puede hacerlo devuelve nil
    private func loadLocalImage(remoteURL: URL)->UIImage?{
        
        if let localPath =  localURLFor(remote: remoteURL)?.path,
            let img = UIImage(contentsOfFile: localPath){
            return img
        }else{
            return nil
            
        }
        
    }
    
    // Guarda la imagen en cache. Si ha tenido éxito devuelve "true", en caso contrario devuelve "false"
    func saveToLocalStorage(remoteURL: URL, image: UIImage) -> Bool{
        
        
        if let localURL = localURLFor(remote: remoteURL),
            let imgData = UIImageJPEGRepresentation(image, 1),
            let _ = try? imgData.write(to: localURL, options: .atomic){
            return true
        }else{
            return false
        }
        
        
        
    }
    
    
}
