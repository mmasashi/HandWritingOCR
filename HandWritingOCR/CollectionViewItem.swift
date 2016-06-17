//
//  CollectionViewItem.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 6/27/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    @IBAction func deleteClicked(id: AnyObject) {
        (self.collectionView.delegate as? ViewController)!.deleteClicked((representedObject as? ImageObject)!)
    }
}
