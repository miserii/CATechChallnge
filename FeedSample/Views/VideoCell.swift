import AVKit
import UIKit

final class VideoCell: UICollectionViewCell {

    static var className: String {
        return String(describing: self)
    }

    private let playerViewController: AVPlayerViewController = {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = false
        playerVC.videoGravity = .resizeAspectFill
        playerVC.view.isUserInteractionEnabled = false
        return playerVC
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playerViewController.view)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: playerViewController.view.leftAnchor),
            contentView.topAnchor.constraint(equalTo: playerViewController.view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: playerViewController.view.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: playerViewController.view.rightAnchor)
            ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        playerViewController.player?.pause()
        playerViewController.player = nil
    }

    func setPlayer(with url: URL) {
        playerViewController.player = AVPlayer(url: url)
        playerViewController.player?.play()

        // 動画の無限ループ
        if let player = playerViewController.player {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
                self?.playerViewController.player?.seek(to: CMTime.zero)
                self?.playerViewController.player?.play()
            }
        }
    }
}
