//
//  MainVC.swift
//  Trader_advice
//
//  Created by Иван Романович on 30.04.2019.
//

import UIKit
import SwiftyUserDefaults
import SnapKit

class MainVC: BaseVC {
	
	private var mainModel: MainModel!
	private let localizationsManager = LocalizationsManager.shared
	private let userRepository = Repository<User>()
	
	private let spinnerTag = 1001
	
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var menuLabel: UILabel!
	@IBOutlet weak var russianFlagImage: UIImageView!
	@IBOutlet weak var britainFlagImage: UIImageView!
	@IBOutlet weak var blurEffect: UIVisualEffectView!
	
	private var buttonsContainer: UIView?
	
	@IBOutlet weak var privacyPolicyButton: UIButton!
	convenience init(mode: Int) {
		self.init()
		
		let userForCurrentMode = userRepository.getItemFromDatabaseBy(primaryKey: mode)
		let userAuthorized = userForCurrentMode != nil
		
		mainModel = MainModel(mode: mode, userAuthorized: userAuthorized)
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		updateView()
		
		russianFlagImage.isUserInteractionEnabled = true
		russianFlagImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRussianFlagTapped)))
		
		britainFlagImage.isUserInteractionEnabled = true
		britainFlagImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBritainFlagTapped)))
		
		blurEffect.alpha = 0
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let userForCurrentMode = userRepository.getItemFromDatabaseBy(primaryKey: mainModel.mode)
		let userAuthorized = userForCurrentMode != nil
		
		mainModel.update(userAuthorized: userAuthorized)
		updateView()
	}
	
	private func configureButtonsLayout() {
		if let container = self.buttonsContainer {
			container.removeFromSuperview()
		}
		
		let buttonsContainer = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 1000))
		var curButtonPosition: CGFloat = 0
		let buttonsHeigh: CGFloat = 20
		let buttonsWidth: CGFloat = 150
		let buttonsOffset = UIScreen.main.bounds.height / 30
		
		let buttonModels = mainModel.mainMenuButtonModels
		
		for buttonModel in buttonModels {
			let button = MainMenuButton(buttonDestination: buttonModel)
			button.frame = CGRect(x: 0, y: curButtonPosition, width: buttonsWidth, height: buttonsHeigh)
			button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
			buttonsContainer.addSubview(button)
			curButtonPosition += buttonsHeigh + buttonsOffset
		}
		
		buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(buttonsContainer)
		
		buttonsContainer.snp.makeConstraints { make in
			make.center.equalTo(contentView)
			make.width.equalTo(CGFloat(buttonsWidth))
			make.height.equalTo(CGFloat(curButtonPosition-buttonsOffset))
		}
		
		self.buttonsContainer = buttonsContainer
		
	}
	
	@objc private func onButtonTapped(_ sender: MainMenuButton) {
		guard let destination = sender.getButtonDestination() else {return}
		
		navigationController?.pushViewController(destination.destinationVC, animated: true)
	}
	
	@objc private func onRussianFlagTapped(_ sender: Any) {
		changeLocalization(newLocalization: Constants.Localizations.RUSSIAN)
	}
	
	@objc private func onBritainFlagTapped(_ sender: Any) {
		changeLocalization(newLocalization: Constants.Localizations.ENGLISH)
	}
	
	private func changeLocalization(newLocalization: Int) {
		startSpinnerAnimation()
		UIView.animate(withDuration: 0.2) {
			self.blurEffect.alpha = 0.9
		}
		localizationsManager.setLocalization(localization: newLocalization, for: mainModel.mode) {
			self.updateView()
			UIView.animate(withDuration: 0.2) {
				self.blurEffect.alpha = 0
			}
			self.stopSpinnerAnimation()
		}
	}
	
	private func updateView() {
		menuLabel.text = LocalizedStrings.shared[.menu]
		configureButtonsLayout()
		privacyPolicyButton.setTitle(LocalizedStrings.shared[.privacyPolicy], for: .normal)
	}
	
	private func startSpinnerAnimation() {
		if view.viewWithTag(spinnerTag) == nil {
			let spinner = UIActivityIndicatorView(style: .gray)
			spinner.center = view.center
			spinner.center.y += spinner.bounds.size.height/2
			spinner.startAnimating()
			spinner.tag = spinnerTag
			view.addSubview(spinner)
		}
	}
	
	private func stopSpinnerAnimation() {
		if let spinner = view.viewWithTag(spinnerTag) {
			spinner.removeFromSuperview()
		}
	}
	
	@IBAction func onPrivacyPolicyButtonTapped(_ sender: Any) {
		navigationController?.pushViewController(PrivacyPolicyVC(), animated: true)
	}
	
}
