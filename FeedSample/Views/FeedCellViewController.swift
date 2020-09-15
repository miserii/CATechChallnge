import AVKit
import UIKit
import Regift

final class FeedCellViewController: UIViewController {

    private(set) var channel: Channel?
    private(set) var page: Int?

    @IBOutlet private weak var playerContainerView: UIView!
    @IBOutlet var longTapSensor: UILongPressGestureRecognizer!
    @IBAction func timeSensor(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("ロングタップスタート")
        } else if sender.state == .ended {
            let url = URL(string: "https://github.com/CyberAgentHack/abemahack-sample-video/raw/master/assets/hls/abema_test_hls_movie_01.m3u8")!
            //    TODO: 取得した時間で指定する
            let startTime = Float(1)
            let duration = Float(5)
            let frameRate = 15
            guard let videoURL = URL(string: url) else { return }
            guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                guard let location = location else { return }
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                print(location)
                print(destinationURL)
                do {
                    let isExit = FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path)
                    if isExit {
                        try FileManager.default.removeItem(at: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent))
                    }
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    let item = AVPlayerItem(url: destinationURL)
                    let exportSession = AVAssetExportSession(asset: item.asset, presetName: AVAssetExportPresetPassthrough)
                    exportSession?.outputFileType = AVFileType.mp4
                    exportSession?.outputURL = destinationURL.appendingPathComponent("store/mp4")
                    exportSession?.canPerformMultiplePassesOverSourceMediaData = true
                    exportSession?.exportAsynchronously { () -> Void in
                        switch exportSession!.status {
                        case AVAssetExportSession.Status.completed:
                            print(exportSession?.directoryForTemporaryFiles as Any)
                            Regift.createGIF(fromAsset: item.asset, startTime: startTime, duration: duration, frameRate: frameRate) { (result) in
                                print("Gif saved to \(String(describing: result))")
                            }
                            // mp4に変換できた
                            break
                        case AVAssetExportSession.Status.failed:
                            print(exportSession?.error as Any)
                            break
                        case AVAssetExportSession.Status.cancelled:
                            break
                        default:
                            break
                        }
                    }
                } catch { print(error) }
            }.resume()
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
