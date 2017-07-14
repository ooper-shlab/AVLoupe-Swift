//
//  APLViewController.swift
//  AVLoupe
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/4/26.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The player's UIViewController class.
  This controller manages the main view and a sublayer; the mainPlayerLayer. This controller also manages as a subview a UIImageView nammed loupeView. loupeView hosts a layer hirearchy that manages the zoomPlayerLayer.
  Users interact with the position of loupeView in respose to IBActions from a UIPanGestureRecognizer.
 */


import UIKit
import AVFoundation


import MobileCoreServices
import CoreMedia

private let ZOOM_FACTOR: CGFloat = 4.0
private let LOUPE_BEZEL_WIDTH: CGFloat = 18.0


@objc(APLViewController)
class APLViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    private var _haveSetupPlayerLayers: Bool = false
    
    var player: AVPlayer!
    var zoomPlayerLayer: AVPlayerLayer?
    var mainPlayerLayer: AVPlayerLayer?
    var notificationToken: AnyObject?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var loupeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVPlayer()
        player.actionAtItemEnd = .none
        _haveSetupPlayerLayers = false
    }
    
    @IBAction func handleTapFrom(_ recognizer: UITapGestureRecognizer) {
        self.navigationBar.isHidden = !self.navigationBar.isHidden
    }
    
    @IBAction func handlePanFrom(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x,
                                          y: recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPoint(), in: self.view)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.zoomPlayerLayer?.position = CGPoint(x: self.zoomPlayerLayer!.position.x - translation.x * ZOOM_FACTOR,
                                                 y: self.zoomPlayerLayer!.position.y - translation.y * ZOOM_FACTOR)
        CATransaction.commit()
    }
    
    override func viewDidLayoutSubviews() {
        if !_haveSetupPlayerLayers {
            // Main PlayerLayer.
            self.mainPlayerLayer = AVPlayerLayer(player: self.player)
            self.view.layer.insertSublayer(self.mainPlayerLayer!, below: self.loupeView.layer)
            self.mainPlayerLayer!.frame = self.view.layer.bounds
            
            // Build the loupe.
            // Content layer serves two functions:
            //  - An opaque black backdrop, since our AVPlayerLayers have a finite edge.
            //  - Applies a sub-layers only mask on behalf of the loupe view
            let contentLayer = CALayer()
            contentLayer.frame = self.loupeView.bounds
            contentLayer.backgroundColor = UIColor.black.cgColor
            
            // The content layer has a circular mask applied.
            let maskLayer = CAShapeLayer()
            maskLayer.frame = contentLayer.bounds
            
            let circlePath = CGMutablePath()
            circlePath.addEllipse(in: self.loupeView.layer.bounds.insetBy(dx: LOUPE_BEZEL_WIDTH , dy: LOUPE_BEZEL_WIDTH))
            
            maskLayer.path = circlePath
            
            contentLayer.mask = maskLayer
            
            // Set up the zoom AVPlayerLayer.
            self.zoomPlayerLayer = AVPlayerLayer(player: self.player)
            let zoomSize = CGSize(width: self.view.layer.bounds.size.width * ZOOM_FACTOR, height: self.view.layer.bounds.size.height * ZOOM_FACTOR)
            self.zoomPlayerLayer!.frame = CGRect(x: (contentLayer.bounds.size.width/2) - (zoomSize.width/2),
                                                 y: (contentLayer.bounds.size.height/2) - (zoomSize.height/2),
                                                 width: zoomSize.width,
                                                 height: zoomSize.height)
            
            contentLayer.addSublayer(self.zoomPlayerLayer!)
            self.loupeView.layer.addSublayer(contentLayer)
            
            _haveSetupPlayerLayers = true
        }
    }
    
    @IBAction func loadMovieFromCameraRoll(_ sender: UIBarButtonItem) {
        self.player.pause()
        
        /*
         Show the image picker controller as a popover (iPad) or as a modal view controller
         (iPhone and iPhone 6 plus).
         */
        let videoPicker = UIImagePickerController()
        videoPicker.edgesForExtendedLayout = []
        videoPicker.modalPresentationStyle = .popover
        videoPicker.delegate = self
        // Initialize UIImagePickerController to select a movie from the camera roll.
        videoPicker.sourceType = .savedPhotosAlbum
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        
        let popoverPresController = videoPicker.popoverPresentationController
        popoverPresController?.barButtonItem = sender
        popoverPresController?.permittedArrowDirections = .any
        popoverPresController?.delegate = self
        
        self.present(videoPicker, animated: true) {
            // Done.
        }
    }
    
    //MARK: Image Picker Controller Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        let url = info[UIImagePickerControllerReferenceURL] as! URL
        let item = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: item)
        
        self.notificationToken = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: OperationQueue.main) {note in
            // Simple item playback rewind.
            self.player.currentItem!.seek(to: kCMTimeZero)
        }
        
        self.player.play()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        
        // Make sure playback is resumed from any interruption.
        self.player.play()
    }
    
    //MARK: Popover Presentation Controller Delegate
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        // Called when a Popover is dismissed.
        
        // Make sure playback is resumed from any interruption.
        self.player.play()
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        // Return YES if the Popover should be dismissed.
        // Return NO if the Popover should not be dismissed.
        return true
    }

    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>)
    {
        // Called when the Popover changes positon.
    }
    
    //MARK: - Adaptive Presentation Controller Delegate
    
    // Called for the iPhone only.
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .fullScreen
    
        // Note: by returning this, you can force it to be a popover for iPhone!
        // return .none
    }
    
}



extension UIImagePickerController {
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    //### Apple's doc says - The UIImagePickerController class supports portrait mode only.
    // But we prefer Landscape only app use it in landscape mode, and this code actually works.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
}
