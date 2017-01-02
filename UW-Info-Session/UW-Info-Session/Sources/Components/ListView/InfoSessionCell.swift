//
//  InfoSessionCell.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit
import Then

//
// ┌───────────────────────────────────┐
// │ Google                   11:30 AM │ <- accessoryLabel
// │ Davis Centre 1301               ❤️│ <- accessoryImageView
// └───────────────────────────────────┘
//

protocol InfoSessionViewModelType {
	var title: String? { get }
	var subtitle: String? { get }
	var accessoryTitle: String? { get }
	var isFavorited: Bool { get }
	
	var titleColor: UIColor? { get }
	var subtitleColor: UIColor? { get }
	var accessoryTitleColor: UIColor { get }
	
	var titleFont: UIFont? { get }
	var subtitleFont: UIFont? { get }
	var accessoryTitleFont: UIFont { get }
	
	var shouldShowSeparator: Bool { get }
}

extension InfoSessionViewModelType {
	var titleColor: UIColor? { return UIColor.primaryText }
	var subtitleColor: UIColor? { return UIColor.secondaryText }
	var accessoryTitleColor: UIColor { return UIColor.primaryText }
	
	var titleFont: UIFont? { return UIFont.titleFont }
	var subtitleFont: UIFont? { return UIFont.subtitleFont }
	var accessoryTitleFont: UIFont { return UIFont.subtitleFont }
	
	var shouldShowSeparator: Bool { return true }
}

class InfoSessionCell: UITableViewCell {

	let titleLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.titleFont
		$0.textColor = UIColor.primaryText
	}
	
	let subtitleLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.subtitleFont
		$0.textColor = UIColor.secondaryText
	}
	
	let accessoryLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.subtitleFont
		$0.textColor = UIColor.primaryText
		$0.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
	}
	
	let accessoryImageView = UIImageView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.contentMode = .scaleAspectFit
		$0.image = R.image.heart()?.withRenderingMode(.alwaysTemplate)
		$0.tintColor = UIColor.red
		
		$0.widthAnchor.constrain(to: $0.heightAnchor)
		$0.widthAnchor.constrain(to: 18)
	}
	
	let separatorView = UIView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = UIColor.separator
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
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.minimumScaleFactor = 0.9
		contentView.addSubview(titleLabel)
		contentView.addSubview(subtitleLabel)
		contentView.addSubview(accessoryLabel)
		contentView.addSubview(accessoryImageView)
		contentView.addSubview(separatorView)
	}

	private func setupConstraints() {
		contentView.preservesSuperviewLayoutMargins = false
		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)

		let views = [
			"titleLabel" : titleLabel,
			"subtitleLabel" : subtitleLabel,
			"accessoryLabel" : accessoryLabel,
			"accessoryImageView" : accessoryImageView
		]

		let metrics: [String : CGFloat] = [
			"v_spacing" : 4.0,
			"h_spacing" : 8.0
		]

		var constraints = [NSLayoutConstraint]()
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-(v_spacing)-[subtitleLabel]-|", options: [.alignAllLeading], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[accessoryLabel]-(>=v_spacing)-[accessoryImageView]-(>=v_spacing)-|", options: [.alignAllTrailing], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-(>=h_spacing)-[accessoryLabel]-|", options: [.alignAllFirstBaseline], metrics: metrics, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[subtitleLabel]-(>=h_spacing)-[accessoryLabel]", options: [], metrics: metrics, views: views)
		NSLayoutConstraint.activate(constraints)
		
		subtitleLabel.centerYAnchor.constrain(to: accessoryImageView.centerYAnchor)
		
		separatorView.bottomAnchor.constrain(to: contentView.bottomAnchor)
		separatorView.heightAnchor.constrain(to: 0.5)
		separatorView.leadingAnchor.constrain(to: contentView.layoutMarginsGuide.leadingAnchor)
		separatorView.trailingAnchor.constrain(to: contentView.trailingAnchor)
	}
	
	func configure(with viewModel: InfoSessionViewModelType) {
		titleLabel.text = viewModel.title
		subtitleLabel.text = viewModel.subtitle
		accessoryLabel.text = viewModel.accessoryTitle
		accessoryImageView.isHidden = !viewModel.isFavorited
		
		titleLabel.textColor = viewModel.titleColor
		subtitleLabel.textColor = viewModel.subtitleColor
		accessoryLabel.textColor = viewModel.accessoryTitleColor
		
		titleLabel.font = viewModel.titleFont
		subtitleLabel.font = viewModel.subtitleFont
		accessoryLabel.font = viewModel.accessoryTitleFont
	}
}
