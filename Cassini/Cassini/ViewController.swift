//
//  ViewController.swift
//  Cassini
//
//  Created by Simen Gangstad on 02.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var imageURL: URL? {
        didSet {
            image = nil
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            
            do {
                let imageData = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
                
                image = UIImage(data: imageData)
            }
            catch {
                print("\(url) could not be found.")
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        imageURL = URL(string: DemoURL.NASA["Cassini"]!)
    }
}

