//
//  RoundImageView.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/26.
//  Copyright © 2019 chenwei. All rights reserved.
//

import UIKit

class RoundImageView : UIImageView{
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        //设置圆角
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2
        
        //加框
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).cgColor
    }
    
    func rotation(){
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = Double.pi*2.0
        animation.duration = 20
        animation.repeatCount = 1000
        self.layer.add(animation, forKey: nil)
    }
}
