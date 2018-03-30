//
//  RemoteImages.swift
//  GCDSample
//
//  Created by Cristian Blazquez Bustos on 22/3/18.
//  Copyright © 2018 Cbb. All rights reserved.
//

import Foundation

typealias URLString = String
enum RemoteImages: URLString {
    case danny = "https://typeset-beta.imgix.net/rehost/2016/9/13/9f6e6cc4-c86b-4cbb-8d7d-bedf3f8b3937.jpg"
    case missandei = "http://www.farfarawaysite.com/section/got/gallery3/gallery4/hires/15.jpg"
    case olenna = "http://girlswithguns.org/wp-content/gallery/women-of-game-of-thrones/09olennatyrell.jpg"
    case cersei = "http://hdqwalls.com/wallpapers/cersei-lannister-game-of-thrones-season-7-39.jpg"
    case wrongURLString = "https://germguy.files.wordpress.com/2016/11/jedi.jpg"
    
    static func url(_ aCase: RemoteImages) -> URL?{
        let strRep = aCase.rawValue
        return URL(string: strRep)
    }
}

