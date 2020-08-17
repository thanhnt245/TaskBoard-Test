//
//  TaskBoardCells.swift
//  TaskManagement
//
//  Created by Thanh Nguyen on 8/16/20.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import Foundation
import UIKit

class TaskCell: UICollectionViewCell {
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.borderWidth = 1.0
        bgView.layer.borderColor = UIColor.lightGray.cgColor
    }
}

class UserCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

class TimeSlotCell: UICollectionViewCell {
    @IBOutlet weak var timeSlotLabel: UILabel!
}
