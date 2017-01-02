//
//  GradientView.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2016-12-30.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit

class GradientView: UIView {
	let gradientLayer = CAGradientLayer()
	override var bounds: CGRect {
		didSet {
			gradientLayer.frame = bounds
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private final func commonInit() {
		layer.addSublayer(gradientLayer)
	}
}
