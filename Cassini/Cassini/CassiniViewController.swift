//
//  CassiniViewController.swift
//  Cassini
//
//  Created by Simen Gangstad on 03.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController, UISplitViewControllerDelegate {
    
    private struct Storyboard {
        static let ShowImageSegue = "Show Image"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ShowImageSegue {
            if let imageViewController = segue.destination.contentViewController as? ImageViewController {
                let imageName = (sender as? UIButton)?.currentTitle
                imageViewController.imageURL = DemoURL.NASAImageNamed(imageName: imageName)
                imageViewController.title = imageName
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }

    @IBAction func showImage(_ sender: UIButton) {
        if let ivc = splitViewController?.viewControllers.last?.contentViewController as? ImageViewController {
            let imageName = sender.currentTitle
            ivc.imageURL = DemoURL.NASAImageNamed(imageName: imageName)
            ivc.title = imageName
        }
        else {
            performSegue(withIdentifier: Storyboard.ShowImageSegue, sender: sender)
        }
    }
    
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self {
            if let ivc = secondaryViewController.contentViewController as? ImageViewController, ivc.imageURL == nil {
                return true
            }
        }
        return false
    }
}


extension UIViewController {
    var contentViewController : UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
        }
        else {
            return self
        }
    }
}
