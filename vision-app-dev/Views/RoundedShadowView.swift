//
//  RoundedShadowView.swift
//  vision-app-dev
//
//  Created by Николай Маторин on 21.12.2017.
//  Copyright © 2017 Николай Маторин. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedShadowView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView() {
        self.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }

}
