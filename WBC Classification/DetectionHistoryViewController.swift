//
//  DetectionHistoryViewController.swift
//  WBC Classification
//
//  Created by Poom Penghiran on 24/11/2561 BE.
//  Copyright © 2561 Poom Penghiran. All rights reserved.
//

import UIKit

class DetectionHistoryViewController: UIViewController {
    
    @IBOutlet weak var ui_tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension DetectionHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
}
