//
//  ViewController.swift
//  Animated_Circle_Progress_Bar
//
//  Created by 123 on 10.04.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var shapeLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    
    var circularPath: UIBezierPath {
        return UIBezierPath(arcCenter: .zero , radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    }
    
    let baseUrlStr = "https://firebasestorage.googleapis.com"
    var urlStr: String {
        return baseUrlStr + "/v0/b/videofortest-ba0fb.appspot.com/o/AmandaCerny.mov?alt=media&token=a794cfc2-7870-4727-854a-65da84d64c22"
    }
    
    var downloadTsk: URLSessionDownloadTask?
    
    let persentageLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start"
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 32)
        lbl.textColor = .white
        return lbl
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
        
        setupNotificationObservers()
        setShapeLayers()
        
        view.addSubview(persentageLabel)
        persentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        persentageLabel.center = view.center
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    fileprivate func setShapeLayers() {
        pulsatingLayer = createPulsatingLayer()
        createTrackLayer()
        animatePulsatingLayer()
        shapeLayer = createShapeLayer()
    }
    
    private func createPulsatingLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = circularPath.cgPath
        layer.fillColor = UIColor.pulsatingFillColor.cgColor
        layer.position = view.center
        view.layer.addSublayer(layer)
        return layer
    }
    
    private func createTrackLayer() {
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.trackStrokeColor.cgColor
        trackLayer.lineWidth = 20
        trackLayer.fillColor = UIColor.backgroundColor.cgColor
        trackLayer.position = view.center
        view.layer.addSublayer(trackLayer)
    }
    
    private func createShapeLayer() -> CAShapeLayer {
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.outlineStrokeColor.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeEnd = 0
        shapeLayer.position = view.center
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        view.layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
    @objc private func handleTap() {
        beginDownloadingFile()
    }
}

// MARK: - Setup Notification Observers
extension ViewController {
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
}

// MARK: - Animate Layers
extension ViewController {
    
    fileprivate func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "urBasicAnim")
    }
}

// MARK: - URLSession Download Delegate
extension ViewController: URLSessionDownloadDelegate {
    
    private func beginDownloadingFile() {
        OperationQueue.main.addOperation {
            self.shapeLayer.strokeEnd = 0
            self.persentageLabel.text = "0%"
        }
        
        if let task = downloadTsk {
            DispatchQueue.global(qos: .userInteractive).async {
                task.cancel()
            }
        }
        
        let config = URLSessionConfiguration.default
        let queue = OperationQueue()
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: queue)
        
        guard let url = URL.init(string: urlStr) else { return }
        downloadTsk = urlSession.downloadTask(with: url)
        downloadTsk?.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let persentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.persentageLabel.text = "\(Int(persentage * 100))%"
            self.shapeLayer.strokeEnd = persentage
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    }
    
}



















