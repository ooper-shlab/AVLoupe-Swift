//
//  APLViewController.swift
//  AVLoupe
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/4/26.
//
//
/*
     File: APLViewController.h
     File: APLViewController.m
 Abstract: The player's UIViewController class.
 This controller manages the main view and a sublayer; the mainPlayerLayer. This controller also manages as a subview a UIImageView nammed loupeView. loupeView hosts a layer hirearchy that manages the zoomPlayerLayer.
 Users interact with the position of loupeView in respose to IBActions from a UIPanGestureRecognizer.
  Version: 1.0

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2012 Apple Inc. All Rights Reserved.

 */
//
//
//#import <UIKit/UIKit.h>
import UIKit
//#import <AVFoundation/AVFoundation.h>
import AVFoundation
//
//@interface APLViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
//
//@end
//
//
//#import "APLViewController.h"
//#import <MobileCoreServices/MobileCoreServices.h>
import MobileCoreServices
//#import <CoreMedia/CoreMedia.h>
import CoreMedia
//
//#define ZOOM_FACTOR 4.0
private let ZOOM_FACTOR: CGFloat = 4.0
//#define LOUPE_BEZEL_WIDTH 18.0
private let LOUPE_BEZEL_WIDTH: CGFloat = 18.0
//
//
@objc(APLViewController)
class APLViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate {
//@interface APLViewController ()
//
//{
//	BOOL _haveSetupPlayerLayers;
    var _haveSetupPlayerLayers: Bool = false
//}
//
//@property AVPlayer *player;
    var player: AVPlayer!
//@property AVPlayerLayer *zoomPlayerLayer;
    var zoomPlayerLayer: AVPlayerLayer?
//@property AVPlayerLayer *mainPlayerLayer;
    var mainPlayerLayer: AVPlayerLayer?
//@property UIPopoverController *popover;
    var popover: UIPopoverController?
//@property id notificationToken;
    var notificationToken: AnyObject?
//
//@property (weak) IBOutlet UINavigationBar *navigationBar;
    @IBOutlet weak var navigationBar: UINavigationBar!
//@property (weak) IBOutlet UIImageView *loupeView;
    @IBOutlet weak var loupeView: UIImageView!
//
//@end
//
//@implementation APLViewController
//
//- (void)viewDidLoad
//{
    override func viewDidLoad() {
        super.viewDidLoad()
//	_player = [[AVPlayer alloc] init];
        player = AVPlayer()
//	_player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
//	_haveSetupPlayerLayers = NO;
        _haveSetupPlayerLayers = false
//}
    }
//
//- (IBAction)handleTapFrom:(UITapGestureRecognizer *)recognizer
//{
    @IBAction func handleTapFrom(recognizer: UITapGestureRecognizer) {
//	self.navigationBar.hidden = !self.navigationBar.hidden;
        self.navigationBar.hidden = !self.navigationBar.hidden
//}
    }
//
//- (IBAction)handlePanFrom:(UIPanGestureRecognizer *)recognizer
//{
    @IBAction func handlePanFrom(recognizer: UIPanGestureRecognizer) {
//	CGPoint translation = [recognizer translationInView:self.view];
        let translation = recognizer.translationInView(self.view)
//
//	recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
        recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x,
//	                                     recognizer.view.center.y + translation.y);
            recognizer.view!.center.y + translation.y)
//	[recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        recognizer.setTranslation(CGPoint(), inView: self.view)
//
//	[CATransaction begin];
        CATransaction.begin()
//	[CATransaction setDisableActions:YES];
        CATransaction.setDisableActions(true)
//	self.zoomPlayerLayer.position = CGPointMake(self.zoomPlayerLayer.position.x - translation.x * ZOOM_FACTOR,
        self.zoomPlayerLayer?.position = CGPointMake(self.zoomPlayerLayer!.position.x - translation.x * ZOOM_FACTOR,
//	                                        self.zoomPlayerLayer.position.y - translation.y * ZOOM_FACTOR);
            self.zoomPlayerLayer!.position.y - translation.y * ZOOM_FACTOR)
//	[CATransaction commit];
        CATransaction.commit()
//}
    }
//
//- (void)viewDidLayoutSubviews
//{
    override func viewDidLayoutSubviews() {
//	if (!_haveSetupPlayerLayers) {
        if !_haveSetupPlayerLayers {
//		// Main PlayerLayer.
//		self.mainPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.mainPlayerLayer = AVPlayerLayer(player: self.player)
//		[self.view.layer insertSublayer:self.mainPlayerLayer below:self.loupeView.layer];
            self.view.layer.insertSublayer(self.mainPlayerLayer, below: self.loupeView.layer)
//		self.mainPlayerLayer.frame = self.view.layer.bounds;
            self.mainPlayerLayer!.frame = self.view.layer.bounds
//
//		// Build the loupe.
//		// Content layer serves two functions:
//		//  - An opaque black backdrop, since our AVPlayerLayers have a finite edge.
//		//  - Applies a sub-layers only mask on behalf of the loupe view
//		CALayer *contentLayer = [CALayer layer];
            let contentLayer = CALayer()
//		contentLayer.frame = self.loupeView.bounds;
            contentLayer.frame = self.loupeView.bounds
//		contentLayer.backgroundColor = [[UIColor blackColor] CGColor];
            contentLayer.backgroundColor = UIColor.blackColor().CGColor
//
//		// The content layer has a circular mask applied.
//		CAShapeLayer *maskLayer = [CAShapeLayer layer];
            let maskLayer = CAShapeLayer()
//		maskLayer.frame = contentLayer.bounds;
            maskLayer.frame = contentLayer.bounds
//
//		CGMutablePathRef circlePath = CGPathCreateMutable();
            let circlePath = CGPathCreateMutable()
//		CGPathAddEllipseInRect(circlePath, NULL, CGRectInset(self.loupeView.layer.bounds, LOUPE_BEZEL_WIDTH , LOUPE_BEZEL_WIDTH));
            CGPathAddEllipseInRect(circlePath, nil, CGRectInset(self.loupeView.layer.bounds, LOUPE_BEZEL_WIDTH , LOUPE_BEZEL_WIDTH))
//
//		maskLayer.path = circlePath;
            maskLayer.path = circlePath
//		CGPathRelease(circlePath);
//
//		contentLayer.mask = maskLayer;
            contentLayer.mask = maskLayer
//
//		// Set up the zoom AVPlayerLayer.
//		self.zoomPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.zoomPlayerLayer = AVPlayerLayer(player: self.player)
//		CGSize zoomSize = CGSizeMake(self.view.layer.bounds.size.width * ZOOM_FACTOR, self.view.layer.bounds.size.height * ZOOM_FACTOR);
            let zoomSize = CGSizeMake(self.view.layer.bounds.size.width * ZOOM_FACTOR, self.view.layer.bounds.size.height * ZOOM_FACTOR)
//		self.zoomPlayerLayer.frame = CGRectMake((contentLayer.bounds.size.width /2) - (zoomSize.width /2),
                self.zoomPlayerLayer!.frame = CGRectMake((contentLayer.bounds.size.width/2) - (zoomSize.width/2),
//											(contentLayer.bounds.size.height /2) - (zoomSize.height /2),
                (contentLayer.bounds.size.height/2) - (zoomSize.height/2),
//											zoomSize.width,
                zoomSize.width,
//											zoomSize.height);
                zoomSize.height)
//
//		[contentLayer addSublayer:self.zoomPlayerLayer];
            contentLayer.addSublayer(self.zoomPlayerLayer)
//		[self.loupeView.layer addSublayer:contentLayer];
            self.loupeView.layer.addSublayer(contentLayer)
//
//		_haveSetupPlayerLayers = YES;
            _haveSetupPlayerLayers = true
//	}
        }
//}
    }
//
//- (IBAction)loadMovieFromCameraRoll:(id)sender
//{
    @IBAction func loadMovieFromCameraRoll(sender: UIBarButtonItem) {
//    [self.player pause];
        self.player.pause()
//
//    if ([self.popover isPopoverVisible]) {
        if self.popover?.popoverVisible ?? false {
//        [self.popover dismissPopoverAnimated:YES];
            self.popover!.dismissPopoverAnimated(true)
//    }
        }
//    // Initialize UIImagePickerController to select a movie from the camera roll.
//    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        let videoPicker = UIImagePickerController()
//    videoPicker.delegate = self;
        videoPicker.delegate = self
//    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        videoPicker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
//    videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        videoPicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
//    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];
        videoPicker.mediaTypes = [kUTTypeMovie]
//
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//        self.popover = [[UIPopoverController alloc] initWithContentViewController:videoPicker];
            self.popover = UIPopoverController(contentViewController: videoPicker)
//        self.popover.delegate = self;
            self.popover!.delegate = self
//        [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            self.popover!.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: .Down, animated: true)
//    }
//	else {
        } else {
//        [self presentViewController:videoPicker animated:YES completion:nil];
            self.presentViewController(videoPicker, animated: true, completion: nil)
//    }
        }
//}
    }
//
//- (NSUInteger)supportedInterfaceOrientations
//{
    override func supportedInterfaceOrientations() -> Int {
//    return UIInterfaceOrientationMaskLandscape;
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
//}
    }
//
//#pragma mark Image Picker Controller Delegate
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//        [self.popover dismissPopoverAnimated:YES];
            self.popover?.dismissPopoverAnimated(true)
//    }
//	else {
        } else {
//        [self dismissViewControllerAnimated:YES completion:nil];
            self.dismissViewControllerAnimated(true, completion: nil)
//    }
        }
//
//    NSURL *url = info[UIImagePickerControllerReferenceURL];
        let url = info[UIImagePickerControllerReferenceURL] as! NSURL
//    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
        let item = AVPlayerItem(URL: url)
//	[self.player replaceCurrentItemWithPlayerItem:item];
        self.player.replaceCurrentItemWithPlayerItem(item)
//
//	self.notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.notificationToken = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: item, queue: NSOperationQueue.mainQueue()) {note in
//		// Simple item playback rewind.
//		[[self.player currentItem] seekToTime:kCMTimeZero];
            self.player.currentItem.seekToTime(kCMTimeZero)
//	}];
        }
//
//	[self.player play];
        self.player.play()
//}
    }
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//    [self dismissViewControllerAnimated:YES completion:nil];
        self.dismissViewControllerAnimated(true, completion: nil)
//
//	// Make sure playback is resumed from any interruption.
//    [self.player play];
        self.player.play()
//}
    }
//
//# pragma mark Popover Controller Delegate
//
//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
//{
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
//    // Make sure playback is resumed from any interruption.
//    [self.player play];
        self.player.play()
//}
    }
//
//@end
}
//
//
//
//@implementation UIImagePickerController (LandscapeOrientation)
extension UIImagePickerController {
//
//- (BOOL)shouldAutorotate
//{
    override public func shouldAutorotate() -> Bool {
//    return NO;
        return false
//}
    }
//
//@end
}