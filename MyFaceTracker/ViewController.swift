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
};

class ViewController: UIViewController, FaceTrackerViewControllerDelegate, ModeSelectionViewControllerDelegate {
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    weak var faceTrackerViewController: FaceTrackerViewController?
    
    var overlayViews = [String: [UIView]]()
    
    var faceObscuringView : UIView?
    
    var faceObscuringMode : FaceObscuringMode = .WhiteBlur
    
    let drawFacePoints : Bool = false
    
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
            var minX : CGFloat = self.view.bounds.size.width
            var maxX : CGFloat = 0.0
            var minY : CGFloat = self.view.bounds.size.height
            var maxY : CGFloat = 0.0
            
            var cgPoints = points.leftEye + points.rightEye
            
            if (self.faceObscuringMode == .BlackRectangle || self.faceObscuringMode == .WhiteBlur) {
                cgPoints += points.leftBrow
                cgPoints += points.rightBrow
                cgPoints += points.outerMouth
            }
            
            for point in cgPoints {
                if point.x < minX {
                    minX = point.x
                }
                
                if point.x > maxX {
                    maxX = point.x
                }
                
                if point.y < minY {
                    minY = point.y
                }
                
                if point.y > maxY {
                    maxY = point.y
                }
            }
            
            self.faceObscuringView!.frame = CGRect.init(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
            
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
        
        self.updateFaceObscuringViewPosition(points)
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
        }
        
        self.view.addSubview(self.faceObscuringView!)
    }
}

