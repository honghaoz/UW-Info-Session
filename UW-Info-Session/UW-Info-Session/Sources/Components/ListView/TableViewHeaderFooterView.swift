//
//  TableViewHeaderFooterView.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-30.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit

open class TableViewHeaderFooterView: UITableViewHeaderFooterView {
	open let titleLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
	}
	
	public override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	open func commonInit() {
		let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
		backgroundView = blurView

		contentView.addSubview(titleLabel)
		titleLabel.centerYAnchor.constrain(to: contentView.centerYAnchor)
		titleLabel.leadingAnchor.constrain(to: contentView.layoutMarginsGuide.leadingAnchor)
	}
}
