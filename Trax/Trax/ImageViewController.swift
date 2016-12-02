//
//  ImageViewController.swift
//  Cassini
//
//  Created by Simen Gangstad on 02.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {

            spinner?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async() {
                do {
                    let imageData = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
                    
                    DispatchQueue.main.async() {[weak self] in
                        // In the case where one presses cassini and then earth for example, we don't want cassini appear
                        // in the ImageView, therefore we check:
                        if url  == self?.imageURL {
                            self?.image = UIImage(data: imageData)
                        }
                        else {
                            print("Ignored data from url: \(url)")
                        }
                    }
                }
                catch {
                    print("\(url) could not be fetched.")
                    DispatchQueue.main.async() { [weak self] in
                        self?.spinner?.stopAnimating()
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
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
            spinner?.stopAnimating()
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
}

