//
//  TweetViewController.swift
//  FeedSample
//
//  Created by osakamiseri on 2020/09/16.
//  Copyright © 2020 AbemaTV, Inc. All rights reserved.
//

import UIKit
import Swifter

class TweetViewController: UIViewController {
    
    let media: Data
    var tweetText: String?
    
    let wordCoundLabel = UILabel()
    var contentViewTopConstraint: NSLayoutConstraint?
    
    init(media: Data) {
        self.media = media
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .clear
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.24)
        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let contentView = UIView()
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.frame.height - 300) / 2)
        contentViewTopConstraint?.isActive = true
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Tweet内容"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.87)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        let closeButton = UIButton()
        closeButton.setTitle("閉じる", for: UIControl.State())
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        closeButton.setTitleColor(UIColor.black.withAlphaComponent(0.87), for: UIControl.State())
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        contentView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0).isActive = true
        closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: closeButton.titleLabel!.intrinsicContentSize.width).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.black.withAlphaComponent(0.87)
        textView.tintColor = UIColor.black
        textView.becomeFirstResponder()
        textView.delegate = self
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -61.0).isActive = true
        textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0).isActive = true
        
        wordCoundLabel.font = UIFont.systemFont(ofSize: 11)
        wordCoundLabel.textColor = UIColor.black.withAlphaComponent(0.24)
        wordCoundLabel.textAlignment = .right
        wordCoundLabel.text = "0/140"
        contentView.addSubview(wordCoundLabel)
        wordCoundLabel.translatesAutoresizingMaskIntoConstraints = false
        wordCoundLabel.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0).isActive = true
        wordCoundLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        wordCoundLabel.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
        wordCoundLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0).isActive = true
        
        let tweetButton = UIButton()
        tweetButton.setTitle("Tweetする！", for: UIControl.State())
        tweetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        tweetButton.setTitleColor(.white, for: UIControl.State())
        tweetButton.contentHorizontalAlignment = .center
        tweetButton.contentVerticalAlignment = .center
        tweetButton.backgroundColor = UIColor.black
        tweetButton.clipsToBounds = true
        tweetButton.addTarget(self, action: #selector(tweetButtonTapped), for: .touchUpInside)
        tweetButton.layer.cornerRadius = 45.0 / 2
        contentView.addSubview(tweetButton)
        tweetButton.translatesAutoresizingMaskIntoConstraints = false
        tweetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0).isActive = true
        tweetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0).isActive = true
        tweetButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8.0).isActive = true
        tweetButton.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tweetButtonTapped() {
        guard let tweetText = tweetText else {
            let errorAlert = UIAlertController(title: "ツイート内容を書いてください", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                errorAlert.dismiss(animated: true, completion: nil)
            }
            errorAlert.addAction(action)
            present(errorAlert, animated: true, completion: nil)
            return
        }
        
        let swifter = Swifter(consumerKey: "3YZegq1DqWZWkWFA3ZpQRy7d6", consumerSecret: "cboDNBb3Ci54P8GYlg7paZYmhQRLRfSQlTTxFNyMbIC4irSZh8")
        swifter.authorize(
            withCallback: URL(string: "swifter-3YZegq1DqWZWkWFA3ZpQRy7d6://")!,
            presentingFrom: nil,
            success: { accessToken, response in
                swifter.postTweet(status: tweetText, media: self.media, success: { (json) in
                    print(json)
                    DispatchQueue.main.async {
                        let sucsessAlert = UIAlertController(title: "ツイートしました", message: nil, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default) { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        sucsessAlert.addAction(action)
                        self.present(sucsessAlert, animated: true, completion: nil)
                    }
                }, failure: { (error) in
                    print(error)
                })
        }) { error in
            print(error)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.contentViewTopConstraint?.isActive = false
            let oldConstant: CGFloat = (self.view.frame.height - 300) / 2
            self.contentViewTopConstraint?.constant = oldConstant - 150
            self.contentViewTopConstraint?.isActive = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.contentViewTopConstraint?.isActive = false
            self.contentViewTopConstraint?.constant = (self.view.frame.height - 300) / 2
            self.contentViewTopConstraint?.isActive = true
        }
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

extension TweetViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tweetText = textView.text
        wordCoundLabel.text = "\(textView.text.count)/140"
    }
}

extension TweetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}

