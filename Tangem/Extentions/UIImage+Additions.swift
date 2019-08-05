//
//  UIImage+Additions.swift
//  Haptic
//
//  Created by Gennady Berezovsky on 11.03.18.
//  Copyright © 2018 Gennady Berezovsky. All rights reserved.
//

import UIKit

@objc public extension UIView {
    
    @objc func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
}
