//
//  StrategiesTableViewController.swift
//  GCDSample
//
//  Created by Cristian Blazquez Bustos on 22/3/18.
//  Copyright © 2018 Cbb. All rights reserved.
//

import UIKit

class StrategiesTableViewController: UITableViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identificator = segue.identifier else {
            print("\(segue) has no id")
            return
        }
        
        guard let destinationVC = segue.destination as? DownloadViewController else {
            print ("\(segue) has the wrong type of destination")
            return
        }
        
        destinationVC.segueId = identificator
        
    }
}
