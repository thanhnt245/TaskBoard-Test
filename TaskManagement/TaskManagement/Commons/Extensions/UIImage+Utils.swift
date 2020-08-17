//
//  UIImage+Utils.swift
//  TaskManagement
//
//  Created by LV00175_ThanhNT on 17/08/2020.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

