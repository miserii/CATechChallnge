import UIKit

class FeedViewController: UIViewController {

    @IBOutlet private weak var videoCollectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: VideoCell.className, bundle: nil)
            videoCollectionView.register(nib, forCellWithReuseIdentifier: VideoCell.className)
            videoCollectionView.isPagingEnabled = true
            videoCollectionView.contentInsetAdjustmentBehavior = .never
            videoCollectionView.showsHorizontalScrollIndicator = false
        }
    }

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewFlowLayout.scrollDirection = .horizontal
        }
    }

    fileprivate let videoUrls = loadVideos()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 起動時に中央までスクロールさせておく
        let centerIndex = Int(videoUrls.count / 2)
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
        return videoUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.className, for: indexPath) as! VideoCell
        let url = videoUrls[indexPath.item]
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

private extension FeedViewController {
    static func loadVideos() -> [URL] {
        guard let path = Bundle.main.path(forResource: "dev_rabbit", ofType: "mp4") else { return [] }
        return (0..<5).map { _ in URL(fileURLWithPath: path) }
    }
}
