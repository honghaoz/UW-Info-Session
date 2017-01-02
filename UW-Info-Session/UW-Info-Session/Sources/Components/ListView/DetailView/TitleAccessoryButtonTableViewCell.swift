//
//  TitleAccessoryButtonTableViewCell.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2017-01-01.
//  Copyright © 2017 Honghaoz. All rights reserved.
//

import UIKit
import ChouTi
import Then

//
// ┌───────────────┐
// │ Google      ❏ │
// └───────────────┘
//

class TitleAccessoryButtonTableViewCell: UITableViewCell {
	weak var infoSession: InfoSession?
	
	let titleLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.heading1TextFont
		$0.textColor = UIColor.primaryText
	}
	
	let accessoryButton = Button().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.contentMode = .scaleAspectFit
		$0.imageView?.contentMode = .scaleAspectFit
		$0.widthAnchor.constrain(to: $0.heightAnchor)
		$0.widthAnchor.constrain(to: 28)
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		setupViews()
		setupConstraints()
	}
	
	private func setupViews() {
		titleLabel.numberOfLines = 0
		titleLabel.font = UIFont.heading1TextFont
		titleLabel.textColor = UIColor.primaryText
		contentView.addSubview(titleLabel)
		
		accessoryButton.setImage(R.image.heartEmpty()?.withRenderingMode(.alwaysTemplate), for: .normal)
		accessoryButton.setImage(R.image.heart()?.withRenderingMode(.alwaysTemplate), for: .selected)
		accessoryButton.tintColor = UIColor.red
		accessoryButton.addTarget(self, action: #selector(TitleAccessoryButtonTableViewCell.buttonTapped(sender:)), for: .touchUpInside)
		contentView.addSubview(accessoryButton)
	}
	
	private func setupConstraints() {
		contentView.preservesSuperviewLayoutMargins = false
		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		
		let views = [
			"titleLabel" : titleLabel,
			"accessoryButton" : accessoryButton
		]
		
		let metrics: [String : CGFloat] = [
			"h_spacing" : 8.0
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", options: [], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-(>=h_spacing)-[accessoryButton]-|", options: [.alignAllCenterY], metrics: metrics, views: views)
		
		NSLayoutConstraint.activate(constraints)
	}
	
	dynamic private func buttonTapped(sender: Any) {
		accessoryButton.isSelected = !accessoryButton.isSelected
//		infoSession?.isFavorited = accessoryButton.isSelected
	}
	
	func configure(with infoSession: InfoSession) {
		self.infoSession = infoSession
		titleLabel.text = infoSession.employer
		accessoryButton.isSelected = infoSession.isFavorited
	}
}
