//
//  ScreenshotsCVFlowLayout.swift
//  Trader_advice
//
//  Created by Роман Плахов on 11/05/2019.
//

import UIKit

protocol ScreenshotsCVFlowLayoutDelegate: class {
	var imagesCount: Int {get}
	
	func ratio (forItemAt indexPath: IndexPath) -> CGFloat
}

class ScreenshotsCVFlowLayout: UICollectionViewFlowLayout {
	public weak var delegate: ScreenshotsCVFlowLayoutDelegate!
	
	private var attributes: [IndexPath:UICollectionViewLayoutAttributes] = [:]
	
	private let indent: CGFloat = 10
	
	override var collectionViewContentSize: CGSize {
		var width: CGFloat = 0
		let height = collectionView!.frame.height
		
		for attribute in attributes.values {
			if attribute.frame.maxX > width {
				width = attribute.frame.maxX
			}
		}
		return CGSize(width: width + indent, height: height)
	}
	
	override func prepare() {
		super.prepare()
		
		guard let collectionView = self.collectionView else {
			return
		}
		
		attributes = [:]
		
		let numberOfItems = delegate.imagesCount
		
		let maxHeight = collectionView.frame.height - indent * 2
		//let maxWidth = maxHeight
		var allAttributes: [IndexPath:UICollectionViewLayoutAttributes] = [:]
		var curX: CGFloat = indent
		var curY: CGFloat = 0
		for itemNumber in 0..<numberOfItems {
			let indexPath = IndexPath(item: itemNumber, section: 0)
			let ratio = delegate.ratio(forItemAt: indexPath)
			let height = maxHeight
			let width = ratio * height

			curY = (collectionView.frame.height-height)/2
			let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
			attributes.frame = CGRect(x: curX, y: curY, width: width, height: height)
			allAttributes[indexPath] = attributes
			
			curX += width + indent
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
