//
//  ViewController.swift
//  MyFaceTracker
//
//  Created by camtasia on 2016-03-11.
//  Copyright © 2016 camtasia. All rights reserved.
//

import UIKit
import FaceTracker
import AudioToolbox

public enum FaceObscuringMode {
    case WhiteBlur
    case BlackRectangle
    case WhiteBlurEyesOnly
    case BlackRectangleEyesOnly
    case MaskGuyFawkes
};

class ViewController: UIViewController, FaceTrackerViewControllerDelegate, ModeSelectionViewControllerDelegate {
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    weak var faceTrackerViewController: FaceTrackerViewController?
    
    var overlayViews = [String: [UIView]]()
    
    var faceObscuringView : UIView?
    
    var faceObscuringMode : FaceObscuringMode = .WhiteBlur
    
    let drawFacePoints : Bool = true
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "faceTrackerEmbed") {
            faceTrackerViewController = segue.destination as? FaceTrackerViewController
            faceTrackerViewController!.delegate = self
        } else if (segue.identifier == "chooseMode") {
            let msvc = segue.destination as! ModeSelectionViewController
            
            msvc.faceObscuringMode = self.faceObscuringMode
            
            msvc.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (self.faceObscuringView != nil) {
            return // Bail out if already started tracking and have .faceObscuringView
        }
        
        faceTrackerViewController!.startTracking { () -> Void in
            print("Started tracking")
            
            if self.faceObscuringView == nil {
                self.faceObscuringView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
                
                self.view.addSubview(self.faceObscuringView!)
            }
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            playCameraSound()
        }
    }
    
    func playCameraSound() {
        AudioServicesPlaySystemSound(1108)
    }
    
    @IBAction func otherCamButtonTapped(_ sender: Any) {
        faceTrackerViewController!.swapCamera()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        self.bottomToolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.bounds.size)
        
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        let photoImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(photoImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        self.bottomToolbar.isHidden = false
    }
    
    func updateFaceObscuringViewPosition(_ points: FacePoints?) {
        if let points = points {
            if self.faceObscuringMode == .MaskGuyFawkes {
                self.faceObscuringView!.transform = .identity
                
                self.faceObscuringView!.frame = CGRect.init(x: 0.0, y: 0.0, width: 375.0, height: 530.0)
                
                let maskLeftEye = CGPoint.init(x: 93.0, y: 204.0)
                
                let maskIPD : CGFloat = 192.0
                
                let leftEyeCenter = points.leftEyeCenter()
                
                let displacement = CGVector.init(dx: leftEyeCenter.x - maskLeftEye.x, dy: leftEyeCenter.y - maskLeftEye.y)
                
                let scaleFactor = points.interPupillaryDistance() / maskIPD
                
                self.faceObscuringView!.frame =
                    self.faceObscuringView!.frame.offsetBy(dx: 2 * displacement.dx, dy: 2 * displacement.dy)
                
                self.faceObscuringView!.frame =
                    CGRect.init(x: self.faceObscuringView!.frame.origin.x,
                                y: self.faceObscuringView!.frame.origin.y,
                                width: self.faceObscuringView!.frame.size.width * scaleFactor,
                                height: self.faceObscuringView!.frame.size.height * scaleFactor)
                
                self.faceObscuringView!.layer.anchorPoint = CGPoint.init(x: 0.504, y: 0.384905660377358)
                
                let angle = atan2(points.rightEyeCenter().y - points.leftEyeCenter().y,
                                  points.rightEyeCenter().x - points.leftEyeCenter().x)
                
                print("angle = ",angle)
                
                self.faceObscuringView!.transform = CGAffineTransform.identity.rotated(by: angle);
            } else {
                let eyesOnly = (self.faceObscuringMode == .BlackRectangleEyesOnly ||
                    self.faceObscuringMode == .WhiteBlurEyesOnly)
                
                self.faceObscuringView!.frame = points.enclosingRect(eyesOnly)
            }
            
            self.faceObscuringView!.isHidden = false
        } else {
            self.faceObscuringView!.isHidden = true
        }
    }
    
    func updateViewForFeature(_ feature: String, index: Int, point: CGPoint, bgColor: UIColor) {
        
        if self.drawFacePoints == false {
            return
        }
        
        let frame = CGRect(x: point.x-2, y: point.y-2, width: 4.0, height: 4.0)
        
        if self.overlayViews[feature] == nil {
            self.overlayViews[feature] = [UIView]()
        }
        
        if index < self.overlayViews[feature]!.count {
            self.overlayViews[feature]![index].frame = frame
            self.overlayViews[feature]![index].isHidden = false
            self.overlayViews[feature]![index].backgroundColor = bgColor
            self.overlayViews[feature]![index].alpha = 0.5
        } else {
            let newView = UIView(frame: frame)
            newView.backgroundColor = bgColor
            newView.isHidden = false
            self.view.addSubview(newView)
            self.overlayViews[feature]! += [newView]
        }
    }
    
    func hideAllOverlayViews() {
        for (_, views) in self.overlayViews {
            for view in views {
                view.isHidden = true
            }
        }
    }
    
    func faceTrackerDidUpdate(_ points: FacePoints?) {
        self.updateFaceObscuringViewPosition(points)
        
        if let points = points {
            
            for (index, point) in points.leftEye.enumerated() {
                self.updateViewForFeature("leftEye", index: index, point: point, bgColor: UIColor.blue)
            }
            
            for (index, point) in points.rightEye.enumerated() {
                self.updateViewForFeature("rightEye", index: index, point: point, bgColor: UIColor.blue)
            }
            
            for (index, point) in points.leftBrow.enumerated() {
                self.updateViewForFeature("leftBrow", index: index, point: point, bgColor: UIColor.white)
            }
            
            for (index, point) in points.rightBrow.enumerated()
            {
                self.updateViewForFeature("rightBrow", index: index, point: point, bgColor: UIColor.white)
            }
            
            for (index, point) in points.nose.enumerated() {
                self.updateViewForFeature("nose", index: index, point: point, bgColor: UIColor.purple)
            }
            
            for (index, point) in points.innerMouth.enumerated() {
                self.updateViewForFeature("innerMouth", index: index, point: point, bgColor: UIColor.red)
            }
            
            for (index, point) in points.outerMouth.enumerated(){
                self.updateViewForFeature("outerMouth", index: index, point: point, bgColor: UIColor.yellow)
            }
            
        }
        else {
            self.hideAllOverlayViews()
        }
    }
    
    func modeSelectionVC(_ modeSelectionVC: ModeSelectionViewController, didChoose mode : FaceObscuringMode) {
        if (self.faceObscuringMode == mode) {
            return
        }
        
        self.faceObscuringMode = mode
        
        self.faceObscuringView?.removeFromSuperview()
        self.faceObscuringView = nil
        
        if (self.faceObscuringMode == .WhiteBlur || self.faceObscuringMode == .WhiteBlurEyesOnly) {
            self.faceObscuringView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
        } else if (self.faceObscuringMode == .BlackRectangle || self.faceObscuringMode == .BlackRectangleEyesOnly) {
            self.faceObscuringView = UIView.init()
            
            self.faceObscuringView?.backgroundColor = UIColor.black
        } else if (self.faceObscuringMode == .MaskGuyFawkes) {
            let guyFawkesMaskImage = UIImage.init(named: "mask1.png", in: Bundle.main, compatibleWith: nil)
            
            self.faceObscuringView = UIImageView.init(image: guyFawkesMaskImage)
            
            
        }
        
        self.view.addSubview(self.faceObscuringView!)
    }
}

