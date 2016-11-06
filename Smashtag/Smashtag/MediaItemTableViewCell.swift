//
//  MediaItemTableViewCell.swift
//  
//
//  Created by Simen Gangstad on 05.11.2016.
//
//

import UIKit
import Twitter

class MediaItemTableViewCell: UITableViewCell {

    @IBOutlet weak var mediaItemImageView: UIImageView!
    
    var mediaItem : MediaItem? {
        didSet {
            fetchMediaItem()
        }
    }

    private var lastURL : URL?
    
    private func fetchMediaItem() {
        
        if let item = mediaItem {
            lastURL = item.url
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                do {
                    let imageData = try Data(contentsOf: item.url)
                    
                    DispatchQueue.main.async {
                        
                        if (item.url == self?.mediaItem?.url) {
                            self?.mediaItemImageView?.image = UIImage(data: imageData)
                            self?.mediaItemImageView.bounds = CGRect(x: 0, y: 0, width: self!.bounds.width, height: (1.0 / CGFloat(item.aspectRatio)) * self!.bounds.width)
                            self?.setNeedsLayout()
                        }
                        else {
                            // print("Ignored data from url: \(weakSelf?.lastURL)")
                        }
                    }
                }
                catch {
                    print("Image from \(self?.lastURL) could not be fetched")
                    DispatchQueue.main.async {
                        self?.imageView?.image = nil
                    }
                }
            }
        }
    }
}
