import AVKit
import UIKit

class FeedViewController: UIPageViewController {

    /// 動画再生用のプレイヤー
    /// - NOTE: 多重再生を防ぐためにViewController単位で単一のプレイヤーを使う
    private let player = AVPlayer()

    /// 現在表示中のページ
    private var currentPage: Int?

    /// チャンネル一覧
    private lazy var channels = {
        return MockApiSession.shared.fetchChannels()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        let initialViewController = viewController(for: 0)
        setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        pageWillChange(newPage: 0, viewController: initialViewController, previousViewControllers: [])

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.player.seek(to: .zero)
                self?.player.play()
            }
        )
    }
}

extension FeedViewController {
    /// 各ページ用のViewControllerを生成する
    private func viewController(for page: Int) -> FeedCellViewController {
        FeedCellViewController.make(channel: channels[page], page: page)
    }

    /// `page` から `delta` 移動し、チャンネルの数でローテーションしたページ番号を返す
    private func rotatedPage(_ page: Int, delta: Int) -> Int {
        var newPage = page + delta
        if newPage < channels.startIndex {
            newPage += channels.count
        } else if newPage >= channels.endIndex {
            newPage -= channels.count
        }
        return newPage
    }

    /// 新しいページに遷移する際に呼び出す
    private func pageWillChange(
        newPage: Int,
        viewController: FeedCellViewController,
        previousViewControllers: [UIViewController]
    ) {
        guard currentPage != newPage else {
            // ページが変わっていなければそのまま
            return
        }
        currentPage = newPage

        // 移動元のページの再生を停止する
        for case let previousViewController as FeedCellViewController in previousViewControllers
            where previousViewController.page != newPage {
            previousViewController.stop()
        }

        // 移動先のページの再生を開始する
        viewController.play(with: player)
    }
}

extension FeedViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = (viewController as? FeedCellViewController)?.page else {
            assertionFailure("should never reach here")
            return UIViewController()
        }

        let newPage = rotatedPage(currentPage, delta: -1)
        return self.viewController(for: newPage)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = (viewController as? FeedCellViewController)?.page else {
            assertionFailure("should never reach here")
            return UIViewController()
        }

        let newPage = rotatedPage(currentPage, delta: 1)
        return self.viewController(for: newPage)
    }
}

extension FeedViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for viewController in pendingViewControllers {
            viewController.view.setNeedsLayout()
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            let viewController = pageViewController.viewControllers?.first as? FeedCellViewController,
            let newPage = viewController.page
        else {
            assertionFailure("should never reach here")
            return
        }

        pageWillChange(newPage: newPage, viewController: viewController, previousViewControllers: previousViewControllers)
    }
}
