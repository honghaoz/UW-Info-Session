//
//  DetailViewController.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2017-01-01.
//  Copyright © 2017 Honghaoz. All rights reserved.
//

import UIKit
import ChouTi
import Then

class DetailViewController: BaseViewController {
	let infoSession: InfoSession
	
	var infoSessionDetails: [TitleContentTableViewCellViewModelType] {
		var models: [TitleContentTableViewCellViewModel] = []
		
		models.append(
			TitleContentTableViewCellViewModel(
				title: "Date",
				content: infoSession.startDate?.string(format: .custom("EEEE, MMM d, y"))
			)
		)
		
		models.append(
			TitleContentTableViewCellViewModel(
				title: "Time",
				content: [infoSession.startDate?.string(format: .custom("h:mm a")), infoSession.endDate?.string(format: .custom("h:mm a"))].flatMap{ $0 }.joined(separator: " - ")
			)
		)
		
		models.append(
			TitleContentTableViewCellViewModel(
				title: "Location",
				content: infoSession.location
			)
		)
		
		models.append(
			TitleContentTableViewCellViewModel(
				title: "Website",
				content: infoSession.website
			)
		)
		
		models.append(
			TitleContentTableViewCellViewModel(
				title: "Students",
				content: infoSession.audience
			)
		)
		
		models.append(
			TitleContentTableViewCellViewModel(
				title: "Programs",
				content: infoSession.programs
			)
		)
		
		models.append(
			TitleContentTableViewCellViewModel(
				title: "Descriptions",
				content: infoSession.description
			)
		)
		
		models = models.filter { $0.content?.isEmpty == false }
		return models
	}
	
	let topOverlayView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
	
	let bottomOverlayView = GradientView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.isUserInteractionEnabled = false
		$0.gradientLayer.colors = [UIColor(white: 1.0, alpha: 0.0).cgColor, UIColor.white.cgColor]
		$0.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		$0.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
	}
	
	override func preferredPresentationStyle() -> PresentationStyle? {
		return .embedded
	}
	
	required init(infoSession: InfoSession) {
		self.infoSession = infoSession
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let tableView = UITableView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = UIColor.clear
		$0.separatorStyle = .none
		$0.allowsSelection = false
		
		$0.rowHeight = UITableViewAutomaticDimension
		$0.sectionHeaderHeight = 32
//		InfoSessionCell.registerInTableView($0)
		TitleAccessoryButtonTableViewCell.registerInTableView($0)
		TitleContentTableViewCell.registerInTableView($0)
	}
	
	override func commonInit() {
		super.commonInit()
		title = infoSession.employer
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
	}
	
	private func setupViews() {
		view.backgroundColor = UIColor.white
		
		view.addSubview(tableView)
		tableView.dataSource = self
		tableView.delegate = self
		
		view.addSubview(topOverlayView)
		topOverlayView.frame = UIApplication.shared.statusBarFrame
		view.addSubview(bottomOverlayView)
	}
	
	private func setupConstraints() {
		tableView.constrainToFullSizeInSuperview()
		
		bottomOverlayView.leadingAnchor.constrain(to: view.leadingAnchor)
		bottomOverlayView.trailingAnchor.constrain(to: view.trailingAnchor)
		bottomOverlayView.bottomAnchor.constrain(to: view.bottomAnchor)
		bottomOverlayView.heightAnchor.constrain(to: view.heightAnchor, multiplier: 0.25)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		enableSwipBackGesture()
	}
}

extension DetailViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1 + infoSessionDetails.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withClass: TitleAccessoryButtonTableViewCell.self, forIndexPath: indexPath)
			
			cell.configure(with: infoSession)
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCell(withClass: TitleContentTableViewCell.self, forIndexPath: indexPath)
			cell.contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
			
			let model = infoSessionDetails[indexPath.row - 1]
			cell.configure(with: model)
			
			return cell
		}
	}
}

extension DetailViewController: UITableViewDelegate {
	// MARK: - Rows
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return TitleAccessoryButtonTableViewCell.estimatedHeight()
		}
		else {
			return TitleContentTableViewCell.estimatedHeight()
		}
	}
}

extension DetailViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateBottomOverlayView(scrollView)
	}
	
	private func updateBottomOverlayView(_ scrollView: UIScrollView) {
		// TableView first appears
		if scrollView.contentSize.width == 0.0 {
			bottomOverlayView.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
			return
		}
		
		let bottomPosition = scrollView.contentOffset.y + scrollView.height
		let bottomSpacing = scrollView.contentSize.height - bottomPosition
		
		// Scrolls excceeds boundary
		guard bottomSpacing >= 0 else {
			bottomOverlayView.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.99)
			return
		}
		
		if bottomSpacing < bottomOverlayView.height {
			bottomOverlayView.gradientLayer.startPoint = CGPoint(x: 0.5, y: min(1.0 - bottomSpacing / bottomOverlayView.height, 0.99))
		}
		else {
			bottomOverlayView.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		}
	}
}
