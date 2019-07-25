//
//  ScreenshotDetailsVC.swift
//  Trader_advice
//
//  Created by Роман Плахов on 12/05/2019.
//

import UIKit

class ScreenshotDetailsVC: BaseVC {

	@IBOutlet weak var collectionView: UICollectionView!
	
	private let reuseIdentifier = "ScreenshotDetailsCell"
	
	private var images: [UIImage?]!
	private var currentImageNum: Int!
	
	//private var scrollingLocked = false
	
	convenience init(images: [UIImage?], currentImageNumber: Int) {
		self.init()
		
		self.currentImageNum = currentImageNumber
		self.images = images
	}
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

		title = LocalizedStrings.shared[.images]
		
		let layout = ScreenshotDetailsCollectionViewFlowLayout()
		layout.delegate = self
		collectionView.collectionViewLayout = layout
		collectionView.isPagingEnabled = true
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false

		if #available(iOS 11.0, *) {
			collectionView.contentInsetAdjustmentBehavior = .never
		} else {
			automaticallyAdjustsScrollViewInsets = false
		}

		
		collectionView.dataSource = self
		//collectionView.delegate = self
		
		self.collectionView!.register(UINib(nibName: "ScreenshotDetailsCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
    }
	
	override func viewDidLayoutSubviews()  {
		super.viewDidLayoutSubviews()
		
		let offset = collectionView.bounds.width
		
		collectionView.setContentOffset(CGPoint(x: offset * CGFloat(currentImageNum), y: collectionView.contentOffset.y), animated: false)
	}

}

extension ScreenshotDetailsVC: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ScreenshotDetailsCell else {return UICollectionViewCell()}
		
		cell.screenshotImageView.image = images[indexPath.item] ?? UIImage(named: "image_not_found")
		
		// Configure the cell
		
		return cell
	}
	
	
}

extension ScreenshotDetailsVC: ScreenshotDetailsCollectionViewFlowLayoutDelegate {
	var imagesCount: Int {
		return images.count
	}
	
	var currentImageNumber: Int {
		get {
			return currentImageNum
		}
		set {
			currentImageNum = newValue
		}
	}
	
	func ratio(forItemAt indexPath: IndexPath) -> CGFloat {
		let image = images[indexPath.item] ?? UIImage(named: "image_not_found")!
		return image.size.width / image.size.height
	}
}
