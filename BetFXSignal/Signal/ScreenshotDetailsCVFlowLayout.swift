//
//  ScreenshotDetailsCVFlowLayout.swift
//  Trader_advice
//
//  Created by Роман Плахов on 12/05/2019.
//

import UIKit

protocol ScreenshotDetailsCollectionViewFlowLayoutDelegate: class {
	var imagesCount: Int {get}
	
	var currentImageNumber: Int {get set}
	
	func ratio (forItemAt indexPath: IndexPath) -> CGFloat
}

class ScreenshotDetailsCollectionViewFlowLayout: UICollectionViewFlowLayout {
	public weak var delegate: ScreenshotDetailsCollectionViewFlowLayoutDelegate!
	
	private var attributes: [IndexPath:UICollectionViewLayoutAttributes] = [:]
	
	override var collectionViewContentSize: CGSize {
		let width = collectionView!.frame.width*CGFloat(delegate.imagesCount)
		let height = collectionView!.frame.height
		return CGSize(width: width, height: height)
	}
	
	override func prepare() {
		super.prepare()
		
		guard let collectionView = self.collectionView else {
			return
		}
		
		attributes = [:]
		
		let numberOfItems = delegate.imagesCount
		let width = collectionView.frame.width
		let collectionViewHeight = collectionView.frame.height
		var allAttributes: [IndexPath:UICollectionViewLayoutAttributes] = [:]
		
		//Располагаем картинки одну за другой по горизонтали
		for itemNumber in 0..<numberOfItems {
			let indexPath = IndexPath(item: itemNumber, section: 0)
			let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
			let height = width / delegate.ratio(forItemAt: indexPath)
			attributes.frame = CGRect(x: CGFloat(itemNumber)*width, y: 0, width: width, height: collectionViewHeight)
			allAttributes[indexPath] = attributes
		}
		
		attributes = allAttributes
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return attributes.values.filter{$0.frame.intersects(rect)}
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return attributes[indexPath]
	}
}
