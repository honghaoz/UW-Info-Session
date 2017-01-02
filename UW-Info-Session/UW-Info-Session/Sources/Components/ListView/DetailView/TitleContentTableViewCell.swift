//
//  TitleContentTableViewCell.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2017-01-02.
//  Copyright © 2017 Honghaoz. All rights reserved.
//

import UIKit
import ChouTi
import Then

//
// ┌─────────────────────┐
// │ Date                │
// │                     │
// │ Thursday, Jan 7     │
// │ 2017 ....           │
// └─────────────────────┘
//

protocol TitleContentTableViewCellViewModelType {
	var title: String? { get }
	var content: String? { get }
	
	var titleColor: UIColor? { get }
	var contentColor: UIColor? { get }
	
	var titleFont: UIFont? { get }
	var contentFont: UIFont? { get }
}

extension TitleContentTableViewCellViewModelType {
	var titleColor: UIColor? {
		return UIColor.secondaryText
	}
	var contentColor: UIColor? {
		return UIColor.primaryText
	}
	
	var titleFont: UIFont? {
		return UIFont.gillSansLightFont(18) ?? UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
	}
	var contentFont: UIFont? {
		return UIFont.gillSansFont(20) ?? UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
	}
}

struct TitleContentTableViewCellViewModel: TitleContentTableViewCellViewModelType {
	var title: String?
	var content: String?
	
	var titleColor: UIColor? = UIColor.secondaryText
	var contentColor: UIColor? = UIColor.primaryText
	
	var titleFont: UIFont? = UIFont.gillSansLightFont(18) ?? UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
	var contentFont: UIFont? = UIFont.gillSansFont(20) ?? UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
	
	init(title: String?, content: String?, titleColor: UIColor? = nil, contentColor: UIColor? = nil, titleFont: UIFont? = nil, contentFont: UIFont? = nil) {
		self.title = title
		self.content = content
		self.titleColor = titleColor
		self.contentColor = contentColor
		self.titleFont = titleFont
		self.contentFont = contentFont
	}
}

class TitleContentTableViewCell: UITableViewCell {
	let titleLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.gillSansLightFont(18) ?? UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
		$0.textColor = UIColor.secondaryText
	}
	
	let contentLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.gillSansFont(20) ?? UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
		$0.textColor = UIColor.primaryText
		$0.numberOfLines = 0
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
	
	private final func setupViews() {
		contentView.addSubview(titleLabel)
		contentView.addSubview(contentLabel)
	}
	
	private final func setupConstraints() {
		contentView.preservesSuperviewLayoutMargins = false
		contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		
		let views = [
			"titleLabel" : titleLabel,
			"contentLabel" : contentLabel
		]
		
		let metrics: [String : CGFloat] = [
			"v_spacing" : 8.0
		]
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-[contentLabel]-|", options: [.alignAllLeading, .alignAllTrailing], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-|", options: [], metrics: metrics, views: views)
		
		NSLayoutConstraint.activate(constraints)
	}
	
	func configure(with viewModel: TitleContentTableViewCellViewModelType) {
		titleLabel.text = viewModel.title
		contentLabel.text = viewModel.content
	}
}
