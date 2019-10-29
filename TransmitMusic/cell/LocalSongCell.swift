//
//  LocalSongCell.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/26.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit

class LocalSongCell : UITableViewCell{
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var songNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.isUserInteractionEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkButton.isSelected = selected
    }
}
