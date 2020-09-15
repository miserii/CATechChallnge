import AVKit
import UIKit
import Regift
import Swifter
import AVFoundation

final class FeedCellViewController: UIViewController {

    private(set) var channel: Channel?
    private(set) var page: Int?
    private(set) var item: AVPlayerItem?
    private(set) var startTime: Double = 0
    private(set) var endTime: Double = 0
    
    @IBOutlet private weak var playerContainerView: UIView!
    @IBOutlet var longTapSensor: UILongPressGestureRecognizer!
    @IBAction func timeSensor(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if let item = item {
                let currendSecond: Double = Double(CMTimeGetSeconds(item.currentTime()))
                startTime = currendSecond
            }
        } else if sender.state == .ended {
            if let item = item {
                let currendSecond: Double = Double(CMTimeGetSeconds(item.currentTime()))
                endTime = currendSecond
                var sourceURL: URL!
                if let channel = channel {
                    if channel.id == "ch-0" {
                        sourceURL = Bundle.main.url(forResource: "abema_test_movie_01", withExtension: "mp4")
                    } else if channel.id == "ch-1" {
                        sourceURL = Bundle.main.url(forResource: "abema_test_movie_02", withExtension: "mp4")
                    } else if channel.id == "ch-2" {
                        sourceURL = Bundle.main.url(forResource: "abema_test_movie_03", withExtension: "mp4")
                    } else if channel.id == "ch-3" {
                        sourceURL = Bundle.main.url(forResource: "abema_test_movie_04", withExtension: "mp4")
                    } else if channel.id == "ch-4" {
                        sourceURL = Bundle.main.url(forResource: "abema_test_movie_05", withExtension: "mp4")
                    }
                }
                cropVideo(sourceURL: sourceURL, startTime: startTime, endTime: endTime) { (mp4Url) in
                    //print(mp4Url)
                    Regift.createGIFFromSource(mp4Url, frameCount: 20, delayTime: 2.0) { (gifUrl) in
                        print(gifUrl)
                        let imageData = try! Data(contentsOf: gifUrl!)
                        DispatchQueue.main.async {
                            self.alertAndTweet(string: "#catechonline", media: imageData)
                        }
                    }
                }
            }
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

        item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        playerViewController.player = player
        player.play()
    }

    func stop() {
        playerViewController.player = nil
    }
    
    func tweet(string: String, media: Data) {
        let tweetViewController = TweetViewController(media: media)
        present(tweetViewController, animated: true, completion: nil)
    }
    
    func alertAndTweet(string: String, media: Data) {
        let alert: UIAlertController = UIAlertController(title: "GIFが作成されました", message: "作成したGIFをツイートする", preferredStyle: UIAlertController.Style.alert)
        let confirmAction: UIAlertAction = UIAlertAction(title: "ツイート", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            alert.dismiss(animated: true) {
                self.tweet(string: string, media: media)
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
        }catch let error {
            print(error)
        }
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
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
