//
//  MainModel.swift
//  Trader_advice
//
//  Created by Роман Плахов on 03/05/2019.
//

import Foundation

class MainModel {
	var mode: Int
	var userAuthorized: Bool
	
	var mainMenuButtonModels: [ButtonDestination] = []
	
	init(mode: Int, userAuthorized: Bool) {
		self.mode = mode
		self.userAuthorized = userAuthorized
		
		configureButtonModels()
	}
	
	public func update(userAuthorized: Bool) {
		self.userAuthorized = userAuthorized
		
		configureButtonModels()
	}
	
	private func configureButtonModels() {
		mainMenuButtonModels = []
        mainMenuButtonModels.append(.aboutUs(mode: mode))
		mainMenuButtonModels.append(.howWeWork(mode: mode))
		if userAuthorized {
			mainMenuButtonModels.append(.history(mode: mode))
			mainMenuButtonModels.append(.buy(mode: mode))
		} else {
			//mainMenuButtonModels.append(.signIn(mode: mode))
			mainMenuButtonModels.append(.registration(mode: mode))
		}
		mainMenuButtonModels.append(.contacts)
	}
	
}
