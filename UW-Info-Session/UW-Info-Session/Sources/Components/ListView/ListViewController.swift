//
//  ListViewController.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit
import Then
import ChouTi

// TODO: Calling Status top overlay view bug

class ListViewController: BaseViewController {
	let tableView = UITableView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = UIColor.clear
		$0.separatorStyle = .none
		
		$0.rowHeight = UITableViewAutomaticDimension
		$0.sectionHeaderHeight = 32
		InfoSessionCell.registerInTableView($0)
		TableViewHeaderFooterView.registerInTableView($0)
	}
	
	let topOverlayView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
	
	let bottomOverlayView = GradientView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.isUserInteractionEnabled = false
		$0.gradientLayer.colors = [UIColor(white: 1.0, alpha: 0.0).cgColor, UIColor.white.cgColor]
		$0.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		$0.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
	}
	
	let footerLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.gillSansLightFont(20)
		$0.textColor = UIColor.unimportantText
	}
	
	// Grouped info session by date string
	var groupedInfoSessions = OrderedDictionary<String, [InfoSession]>()
	
	override func commonInit() {
		super.commonInit()
		title = "Info Sessions"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		
		navigationController?.delegate = self
		
		loadData()
	}
	
	private func setupViews() {
		view.backgroundColor = UIColor.white
		
		view.addSubview(tableView)
		
		tableView.dataSource = self
		tableView.delegate = self
//		automaticallyAdjustsScrollViewInsets = false
//		tableView.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
//		tableView.scrollIndicatorInsets = tableView.contentInset
		
		let footerView = UIView()
		footerView.bounds.size.height = 44
		tableView.tableFooterView = footerView
		footerView.addSubview(footerLabel)
		footerLabel.centerXAnchor.constrain(to: footerView.centerXAnchor)
		footerLabel.centerYAnchor.constrain(to: footerView.centerYAnchor, constant: -8)
		
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
}

extension ListViewController {
	func loadData() {
		InfoSessionProvider.fetchInfoSessions(year: 2017, term: .winter) { (infoSessions, error) in
			guard let infoSessions = infoSessions else {
				log.error(error?.localizedDescription)
				return
			}
			
			self.groupedInfoSessions.removeAll()
			for infoSession in infoSessions {
				guard let dateString = infoSession.startDate?.string(format: .custom("EEEE, MMM d, y")) else {
					continue
				}
				
				if let infoSessionsForDateString = self.groupedInfoSessions[dateString] {
					self.groupedInfoSessions[dateString] = infoSessionsForDateString + [infoSession]
				}
				else {
					self.groupedInfoSessions[dateString] = [infoSession]
				}
			}
			
			let infoSessionsCount = infoSessions.filter { $0.isNotice == false }.count
			self.footerLabel.text = "\(infoSessionsCount) Info Sessions"
			
			self.tableView.reloadData()
		}
	}
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return groupedInfoSessions.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return groupedInfoSessions[section].1.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withClass: InfoSessionCell.self, forIndexPath: indexPath)

		let infoSession = groupedInfoSessions[indexPath.section].1[indexPath.row]
		cell.configure(with: infoSession)
		
		cell.selectionStyle = infoSession.isNotice ? .none : .default
		
		// Last row configuration
		let rowsCount = tableView.numberOfRows(inSection: indexPath.section)
		let isLastRow = indexPath.row == rowsCount - 1
		cell.separatorView.isHidden = isLastRow
		
		if isLastRow {
			cell.contentView.layoutMargins.bottom = 16
		}
		else {
			cell.contentView.layoutMargins.bottom = 8
		}
		
		return cell
	}
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
	// MARK: - Rows
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return InfoSessionCell.estimatedHeight()
	}
	
	// MARK: - Selections
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let infoSession = groupedInfoSessions[indexPath.section].1[indexPath.row]
		
		guard infoSession.isNotice == false else { return }
		
		let detailViewController = DetailViewController(infoSession: infoSession)
		
		self.show(detailViewController, sender: self)
	}
	
	// MARK: - Sections
	func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return TableViewHeaderFooterView.estimatedHeight()
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let header = tableView.dequeueResuableHeaderFooterView(withClass: TableViewHeaderFooterView.self) else {
			return nil
		}
		
		header.titleLabel.text = groupedInfoSessions[section].0
		header.titleLabel.textColor = UIColor.primaryText
		header.titleLabel.font = UIFont.headerFont
		
		return header
	}
}

extension ListViewController: UIScrollViewDelegate {
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

extension ListViewController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		navigationController.setNavigationBarHidden(true, animated: true)
	}
}
