//
//  SignalVC.swift
//  Trader_advice
//
//  Created by Роман Плахов on 06/05/2019.
//

import UIKit
import RealmSwift

class SignalVC: BaseVC {
	private let spinnerTag = 1000

	@IBOutlet weak var isWinIndicatorView: UIView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var contentTextView: UITextView!
	@IBOutlet weak var screenshotsCollectionView: UICollectionView!
	
	private var signal: Signal!
	
	private let imageLoader = ImageLoader()
	
	convenience init(signal: Signal) {
		self.init()
		
		self.signal = signal
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		title = LocalizedStrings.shared[.signal]
		
		screenshotsCollectionView.backgroundColor = .clear
		
		switch signal?.isWin {
		case 1:
			isWinIndicatorView.backgroundColor = UIColor(red: 211/255, green: 255/255, blue: 190/255, alpha: 0.9)
		case 2:
			isWinIndicatorView.backgroundColor = UIColor(red: 254/255, green: 204/255, blue: 203/255, alpha: 0.9)
		default:
			isWinIndicatorView.backgroundColor = .white
		}
		isWinIndicatorView.layer.shadowColor = UIColor.black.cgColor
		isWinIndicatorView.layer.shadowOpacity = 0.3
		isWinIndicatorView.layer.shadowOffset = CGSize(width: 0, height: 2)
		isWinIndicatorView.layer.shadowRadius = 1
		
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy hh:mm"
		dateLabel.text = formatter.string(from: signal!.updatedAtDate)
		
		contentTextView.attributedText = signal?.formattedTextRepresentation
		contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		
		screenshotsCollectionView.isHidden = !signal.containsImages
		
		screenshotsCollectionView.delegate = self
		screenshotsCollectionView.dataSource = self
		let layout = ScreenshotsCVFlowLayout()
		layout.delegate = self
		screenshotsCollectionView.collectionViewLayout = layout
		
		screenshotsCollectionView.showsHorizontalScrollIndicator = false
		screenshotsCollectionView.showsVerticalScrollIndicator = false
		
		if #available(iOS 11.0, *) {
			screenshotsCollectionView.contentInsetAdjustmentBehavior = .never
		} else {
			automaticallyAdjustsScrollViewInsets = false
		}
		
		screenshotsCollectionView.register(UINib(nibName: "ScreenshotCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ScreenshotCell")

		if signal.images == nil && signal.containsImages {
			var imagesURLs = [String]()
			for imageURL in self.signal.imagesURLs {
				imagesURLs.append(imageURL)
			}
			DispatchQueue.global().async {
				self.imageLoader.loadImages(fromURLs: imagesURLs) {loadedImages, identificationToken in
					DispatchQueue.main.async {
						self.signal.images = loadedImages
						self.stopSpinnerAnimation()
						self.screenshotsCollectionView.reloadData()
					}
				}
			}
		}
	
        // Do any additional setup after loading the view.
    }
	
	override func viewDidLayoutSubviews() {
		 super.viewDidLayoutSubviews()
		
		configureConstraints()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if imageLoader.isLoadingInProgress {
			startSpinnerAnimation()
		}
	}
	
	private func configureConstraints () {
		contentTextView.translatesAutoresizingMaskIntoConstraints = false
		screenshotsCollectionView.translatesAutoresizingMaskIntoConstraints = false

		screenshotsCollectionView.snp.makeConstraints { make in
			if !self.signal.containsImages {
				make.height.equalTo(0)
			} else {
				make.height.equalTo(view.bounds.height / 5)
				make.leading.equalTo(view.snp.leading)
				make.trailing.equalTo(view.snp.trailing)
				make.bottom.equalTo(view.snp.bottom)
			}
		}
		
		contentTextView.snp.makeConstraints { make in
			make.leading.equalTo(view.snp.leading)
			make.top.equalTo(isWinIndicatorView.snp.bottom)
			make.trailing.equalTo(view.snp.trailing)
			
			if !self.signal.containsImages {
				make.bottom.equalTo(view.snp.bottom)
			} else {
				make.bottom.equalTo(screenshotsCollectionView.snp.top)
			}
		}
	}
	
	private func startSpinnerAnimation() {
		if view.viewWithTag(spinnerTag) == nil {
			let spinner = UIActivityIndicatorView(style: .gray)
			spinner.center = screenshotsCollectionView.center
			spinner.startAnimating()
			spinner.tag = spinnerTag
			view.addSubview(spinner)
			
			spinner.translatesAutoresizingMaskIntoConstraints = false
			
			spinner.snp.makeConstraints { make in
				make.center.equalTo(screenshotsCollectionView)
			}
		}
	}
	
	private func stopSpinnerAnimation() {
		if let spinner = view.viewWithTag(spinnerTag) {
			spinner.removeFromSuperview()
		}
	}
}

extension SignalVC: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let images = signal.images else {return 0}
		return images.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCell", for: indexPath) as? ScreenshotCell else {return UICollectionViewCell()}
		
		cell.screenshotImageView.image = signal.images?[indexPath.item] ?? UIImage(named: "image_not_found")!
		
		return cell
	}
}

extension SignalVC: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		guard let images = signal.images else {return}
		
		navigationController?.pushViewController(ScreenshotDetailsVC(images: images, currentImageNumber: indexPath.item), animated: true)
	}
}

extension SignalVC: ScreenshotsCVFlowLayoutDelegate {
	var imagesCount: Int {
		guard let images = signal.images else {return 0}
		return images.count
	}
	
	func ratio(forItemAt indexPath: IndexPath) -> CGFloat {
		guard let images = signal.images else {return 0}
		
		let image = images[indexPath.item] ?? UIImage(named: "image_not_found")!
		return image.size.width / image.size.height
	}
}
