import UIKit

class FeedViewController: UIViewController {

    @IBOutlet private weak var videoCollectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: FeedCell.className, bundle: nil)
            videoCollectionView.register(nib, forCellWithReuseIdentifier: FeedCell.className)
            videoCollectionView.isPagingEnabled = true
            videoCollectionView.contentInsetAdjustmentBehavior = .never
            videoCollectionView.showsHorizontalScrollIndicator = false
        }
    }

    @IBOutlet private weak var collectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewFlowLayout.scrollDirection = .horizontal
        }
    }

    private lazy var channels = {
        return MockApiSession.shared.fetchChannels()
    }()

    private lazy var channelURLs = {
        return channels.map { $0.url }.compactMap { URL(string: $0) }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 起動時に中央までスクロールさせておく
        let centerIndex = Int(channels.count / 2)
        let cellWidth = videoCollectionView.bounds.width

        videoCollectionView.setContentOffset(CGPoint(x: cellWidth * CGFloat(centerIndex), y: 0),
                                             animated: false)
    }
}

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.className, for: indexPath) as! FeedCell
        let url = channelURLs[indexPath.item]
        cell.setPlayer(with: url)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
