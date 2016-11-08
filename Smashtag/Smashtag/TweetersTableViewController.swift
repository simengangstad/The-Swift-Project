//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by Simen Gangstad on 08.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class TweetersTableViewController: UITableViewController {

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
}
