import AVKit
import UIKit
import Regift
import Swifter

final class FeedCellViewController: UIViewController {

    private(set) var channel: Channel?
    private(set) var page: Int?

    @IBOutlet private weak var playerContainerView: UIView!
    @IBOutlet var longTapSensor: UILongPressGestureRecognizer!
    @IBAction func timeSensor(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("ロングタップスタート")
            tweet()
        } else if sender.state == .ended {
            //            let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            //            //    TODO: 取得した時間で指定する
            //            let startTime = Float(30)
            //            let duration  = Float(15)
            //            let frameRate = 15
            //            Regift.createGIFFromSource(url, startTime: startTime, duration: duration, frameRate: frameRate) { (result) in
            //                print("Gif saved to \(String(describing: result))")
            //            }
        }
    }
    
    private let playerViewController: AVPlayerViewController = {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = false
        playerVC.videoGravity = .resizeAspectFill
        playerVC.view.isUserInteractionEnabled = false
        playerVC.view.backgroundColor = .darkGray
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        return playerVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        playerContainerView.addSubview(playerViewController.view)

        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
        ])
    }

    func play(with player: AVPlayer) {
        guard let channel = channel else {
            assertionFailure("should not reach here")
            return
        }

        guard let url = URL(string: channel.url) else {
            assertionFailure("invalid URL")
            return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        playerViewController.player = player
        player.play()
    }

    func stop() {
        playerViewController.player = nil
    }
    
    func tweet() {
        let swifter = Swifter(consumerKey: "3YZegq1DqWZWkWFA3ZpQRy7d6", consumerSecret: "cboDNBb3Ci54P8GYlg7paZYmhQRLRfSQlTTxFNyMbIC4irSZh8")
        swifter.authorize(
            withCallback: URL(string: "swifter-3YZegq1DqWZWkWFA3ZpQRy7d6://")!,
            presentingFrom: nil,
            success: { accessToken, response in
                print(response)
                let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "test", withExtension: "gif")!)
                swifter.postTweet(status: "テストツイート", media: imageData)
        }, failure: { error in
            print(error)
        }
        )
    }
    
    //    TODO: GIFが作成できたタイミングで出す
    func alert() {
        let alert: UIAlertController = UIAlertController(title: "GIFが作成されました", message:  "作成したGIFをツイートする", preferredStyle:  UIAlertController.Style.alert)
        let confirmAction: UIAlertAction = UIAlertAction(title: "ツイート", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}

extension FeedCellViewController {
    static func make(channel: Channel, page: Int) -> Self {
        let viewController = self.init(nibName: String(describing: self), bundle: nil)
        viewController.channel = channel
        viewController.page = page
        return viewController
    }
}
