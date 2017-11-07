//
//  ReportListViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportTableViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    var report: [Any]?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "reportCellIdentifier",
                                                                  for: indexPath)
        return cell
    }
}
