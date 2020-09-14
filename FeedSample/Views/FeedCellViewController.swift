import AVKit
import UIKit
import Regift

final class FeedCellViewController: UIViewController {

    private(set) var channel: Channel?
    private(set) var page: Int?

    @IBOutlet private weak var playerContainerView: UIView!
    @IBOutlet var gifCreateButton: UIButton!
    @IBOutlet var longTapSensor: UITapGestureRecognizer!
//    TODO: 後でボタン作成とtimeSensorの有効化
    @IBAction func timeSensor(_ sender: UITapGestureRecognizer) {
        if sender.state == .began {
            print("ロングタップスタート")
            //            ここでstartTime取得
        } else if sender.state == .ended {
            print("ロングタップ終了")
            //            ここでdurationを取得
            //            ここでgif生成スタートする
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
    
    func createGif() {
        let videoURL   = URL(string: "")!
        //        TODO: 取得した時間で指定する
        let startTime = Float(30)
        let duration  = Float(15)
        let frameRate = 15
        
        Regift.createGIFFromSource(videoURL, startTime: startTime, duration: duration, frameRate: frameRate) { (result) in
            print("Gif saved to \(String(describing: result))")
        }
    }
    
    func tweet() {
        //        TODO: GIF付きのツイートをする
        let text = "ここにいい感じの文章\n#ハッシュタグ"
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let encodedText = encodedText,
            let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //    TODO: GIFが作成できたタイミングで出す
    func alert() {
        let alert: UIAlertController = UIAlertController(title: "GIFが作成されました", message:  "作成したGIFをツイートする", preferredStyle:  UIAlertController.Style.alert)
        let confirmAction: UIAlertAction = UIAlertAction(title: "ツイート", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("キャンセル")
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
