//
//  HistoryVC.swift
//  Trader_advice
//
//  Created by Иван Романович on 30.04.2019.
//

import Foundation
import UIKit
import RealmSwift
import SnapKit

class HistoryVC: BaseVC {

	public var currentMode: Int!
	
	@IBOutlet weak var tableView: UITableView!
	private let spinnerTag = 999
	
	private var modeSelectionButtonBar: UIView?
	private var selectionBar: UIView?
	
	private var usersRepository: Repository<User> = Repository<User>()
	private var forexRepository: Repository<ForexSignal> = Repository<ForexSignal>()
	private var sportRepository: Repository<SportSignal> = Repository<SportSignal>()
	
	private var forexSignals: Results<ForexSignal>?
	private var sportSignals: Results<SportSignal>?
	private var users: [User]!
	
	private var forexSections: [(date: Date, items: Results<ForexSignal>)]?
	private var sportSections: [(date: Date, items: Results<SportSignal>)]?
	
	private var constraints = [Constraint]()
	
	private let alertsService = AlertsService()
	
	convenience init (mode: Int) {
		self.init()
		
		self.currentMode = mode
		users = usersRepository.getItemsFromDatabase()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		title = LocalizedStrings.shared[.history]
		
		configureSections()
		
		updateData()
		configureView()
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorColor = .clear
		tableView.showsVerticalScrollIndicator = false
    }
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateData()
		configureView()
	}
	
	public func updateData() {
		startSpinnerAnimation()
		SignalApiClient().getSignals(forMode: currentMode) {
			[weak self] error in
			guard let historyVC = self else {return}
			if error == Constants.Errors.ERROR {
				historyVC.alertsService.showPaidPeriodExpiredAlert(for: historyVC.currentMode, in: historyVC) {[weak self] _ in
					guard let historyVC = self else {return}
					historyVC.navigationController?.pushViewController(PaymentsVC(mode: historyVC.currentMode
					), animated: true)
				}
			} else if error == Constants.Errors.CONNECTION_ERROR {
				ToastView.shared.short(historyVC.view, txt_msg: LocalizedStrings.shared[.noConnection])
			}
			
			historyVC.configureSections()
			historyVC.tableView.reloadData()
			historyVC.stopSpinnerAnimation()
		}
	}
	
	private func configureView () {
		var isModeSelectionButtonBarRequired = users.count == 2
		
		if isModeSelectionButtonBarRequired {
			self.modeSelectionButtonBar?.removeFromSuperview()
			let modeSelectionButtonBarWidth: CGFloat  = view.frame.width
			let buttonWidth: CGFloat  = modeSelectionButtonBarWidth / 2
			let buttonHeight: CGFloat = 50
			let selectionBarHeight: CGFloat  = 2
			
			let modeSelectionButtonBar = UIView(frame: .zero)
			view.addSubview(modeSelectionButtonBar)
			
			let forexButton = UIButton()
			forexButton.setTitle("FOREX", for: .normal)
			forexButton.addTarget(self, action: #selector(onForexButtonTapped), for: .touchUpInside)
			
			let sportButton = UIButton()
			sportButton.setTitle("SPORT", for: .normal)
			sportButton.addTarget(self, action: #selector(onSportButtonTapped), for: .touchUpInside)
			
			let stackView = UIStackView(arrangedSubviews: [forexButton, sportButton])
			stackView.axis = .horizontal
			stackView.alignment = .fill
			stackView.distribution = .fillEqually
			
			modeSelectionButtonBar.addSubview(stackView)
			stackView.translatesAutoresizingMaskIntoConstraints = false
			
			stackView.snp.removeConstraints()
			stackView.snp.makeConstraints { make in
				make.leading.equalTo(modeSelectionButtonBar.snp.leading)
				make.top.equalTo(modeSelectionButtonBar.snp.top)
				make.trailing.equalTo(modeSelectionButtonBar.snp.trailing)
				make.bottom.equalTo(modeSelectionButtonBar.snp.bottom).offset(-selectionBarHeight)
			}
			
			selectionBar = UIView(frame: CGRect(x: (currentMode == Constants.Mode.FOREX ? 0 : buttonWidth), y: buttonHeight, width: buttonWidth, height: selectionBarHeight))
			selectionBar?.backgroundColor = .white
			modeSelectionButtonBar.addSubview(selectionBar!)
			
			self.modeSelectionButtonBar = modeSelectionButtonBar
		}

		configureConstraints()
	}
	
	private func configureConstraints() {
		for constraint in constraints {
			constraint.deactivate()
		}
		
		constraints = []

		tableView.translatesAutoresizingMaskIntoConstraints = false
		modeSelectionButtonBar?.translatesAutoresizingMaskIntoConstraints = false
		
		tableView.snp.makeConstraints { make in
			self.constraints.append(make.leading.equalTo(view.snp.leading).constraint)
			self.constraints.append(make.trailing.equalTo(view.snp.trailing).constraint)
			self.constraints.append(make.bottom.equalTo(view.snp.bottom).constraint)
		}
		
		if let bar = modeSelectionButtonBar {
			bar.snp.makeConstraints { make in
				self.constraints.append(make.leading.equalTo(view.snp.leading).constraint)
				self.constraints.append(make.top.equalTo(view.snp.topMargin).constraint)
				self.constraints.append(make.trailing.equalTo(view.snp.trailing).constraint)
				self.constraints.append(make.height.equalTo(52).constraint)
			}
			tableView.snp.makeConstraints {make in
				self.constraints.append(make.top.equalTo(bar.snp.bottom).constraint)
			}
		} else {
			tableView.snp.makeConstraints {make in
				self.constraints.append(make.top.equalTo(view.snp.topMargin).constraint)
			}
		}
	}
	
	private func updateSelectionBarPosition() {
		guard let selectionBar = self.selectionBar else {return}
		
		let newFrame = currentMode == Constants.Mode.FOREX
			? CGRect(x: 0, y: selectionBar.frame.minY, width: selectionBar.frame.width, height: selectionBar.frame.height)
			: CGRect(x: selectionBar.frame.width, y: selectionBar.frame.minY, width: selectionBar.frame.width, height: selectionBar.frame.height)
		UIView.animate(withDuration: 0.35) {
			selectionBar.frame = newFrame
		}
	}
	
	@objc private func onForexButtonTapped() {
		setNewMode(mode: Constants.Mode.FOREX)
	}
	
	@objc private func onSportButtonTapped() {
		setNewMode(mode: Constants.Mode.SPORT)
	}
	
	private func setNewMode (mode: Int) {
		if currentMode == mode {
			return
		}
		
		currentMode = mode
		updateData()
		updateSelectionBarPosition()
	}
	
	private func configureSections() {
		if currentMode == Constants.Mode.FOREX {
			forexSignals = forexRepository.getResultsFromDatabase().sorted(byKeyPath: "updatedAt", ascending: false)
			forexSignals = forexSignals?.filter("language = \(LocalizationsManager.shared.currentLocalization)")
		} else if currentMode == Constants.Mode.SPORT {
			sportSignals = sportRepository.getResultsFromDatabase().sorted(byKeyPath: "updatedAt", ascending: false)
			sportSignals = sportSignals?.filter("language = \(LocalizationsManager.shared.currentLocalization)")
		}
		
		if let signals = forexSignals, currentMode == Constants.Mode.FOREX {
			forexSections = signals
				.map {signal in
					return Calendar.current.startOfDay(for: signal.updatedAtDate)}
				.reduce([]) {dates, date in
					return dates.last == date ? dates : dates + [date]}
				.compactMap { startDate -> (date: Date, items: Results<ForexSignal>)? in
					let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
					let items = signals.filter("(updatedAt >= %@) AND (updatedAt < %@)", Int(startDate.timeIntervalSince1970), Int(endDate.timeIntervalSince1970))
						.sorted(byKeyPath: "updatedAt", ascending: false)
					return items.isEmpty ? nil : (date: startDate, items: items)}
			tableView.register(UINib(nibName: "ForexHistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "ForexHistoryCell")
		} else if let signals = sportSignals, currentMode == Constants.Mode.SPORT  {
			sportSections = signals
				.map {signal in
					return Calendar.current.startOfDay(for: signal.updatedAtDate)}
				.reduce([]) {dates, date in
					return dates.last == date ? dates : dates + [date]}
				.compactMap { startDate -> (date: Date, items: Results<SportSignal>)? in
					let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
					let items = signals.filter("(updatedAt >= %@) AND (updatedAt < %@)", Int(startDate.timeIntervalSince1970), Int(endDate.timeIntervalSince1970))
						.sorted(byKeyPath: "updatedAt", ascending: false)
					return items.isEmpty ? nil : (date: startDate, items: items)}
			tableView.register(UINib(nibName: "SportHistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "SportHistoryCell")
		}
	}
	
	private func startSpinnerAnimation() {
		if view.viewWithTag(spinnerTag) == nil {
			let spinner = UIActivityIndicatorView(style: .gray)
			spinner.startAnimating()
			spinner.tag = spinnerTag
			view.addSubview(spinner)
			
			spinner.translatesAutoresizingMaskIntoConstraints = false
			spinner.snp.makeConstraints { make in
				make.center.equalTo(tableView)
			}
		}
	}
	
	private func stopSpinnerAnimation() {
		if let spinner = view.viewWithTag(spinnerTag) {
			spinner.removeFromSuperview()
		}
	}

}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = currentMode == Constants.Mode.FOREX ? "ForexHistoryCell" : "SportHistoryCell"
		guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? HistoryCell else {return UITableViewCell()}
		
		if let signal = currentMode == Constants.Mode.FOREX ? forexSections?[indexPath.section].1[indexPath.row] : sportSections?[indexPath.section].1[indexPath.row]  {
			cell.configureCell(for: signal as! Signal)
		}
		return cell as! UITableViewCell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch currentMode {
		case Constants.Mode.FOREX:
			guard let sections = forexSections else {return 0}
			return sections[section].1.count
		case Constants.Mode.SPORT:
			guard let sections = sportSections else {return 0}
			return sections[section].1.count
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let signal: Signal
		switch currentMode {
		case Constants.Mode.FOREX:
			guard let sections = forexSections else {return}
			signal = sections[indexPath.section].1[indexPath.row]
		case Constants.Mode.SPORT:
			guard let sections = sportSections else {return}
			signal = sections[indexPath.section].1[indexPath.row]
		default:
			return
		}
		
		navigationController?.pushViewController(SignalVC(signal: signal), animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch currentMode {
		case Constants.Mode.FOREX:
			return ForexHistoryCell.CELL_HEIGHT
		case Constants.Mode.SPORT:
			return SportHistoryCell.CELL_HEIGHT
		default:
			return 0
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		switch currentMode {
		case Constants.Mode.FOREX:
			guard let sections = forexSections else {return 0}
			return sections.count
		case Constants.Mode.SPORT:
			guard let sections = sportSections else {return 0}
			return sections.count
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 30))
		headerView.backgroundColor = .white
		let label = UILabel()
		let formatter = DateFormatter()

		formatter.dateFormat = "dd.MM.yyyy"
		
		label.text = formatter.string(from: currentMode == Constants.Mode.FOREX ? forexSections![section].0 : sportSections![section].0)
		label.textAlignment = .center
		label.frame = headerView.bounds
		headerView.addSubview(label)
		
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
}
