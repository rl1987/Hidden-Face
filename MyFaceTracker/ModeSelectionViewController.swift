//
//  ModeSelectionViewController.swift
//  MyFaceTracker
//
//  Created by rl1987 on 25/12/16.
//  Copyright © 2016 camtasia. All rights reserved.
//

import UIKit

protocol ModeSelectionViewControllerDelegate : NSObjectProtocol {
    func modeSelectionVC(_ modeSelectionVC: ModeSelectionViewController, didChoose mode : FaceObscuringMode)
}

class ModeSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView : UITableView?
    
    var faceObscuringMode : FaceObscuringMode = .WhiteBlur
    
    weak var delegate : ModeSelectionViewControllerDelegate?
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        print("Save tapped")
        
        if ((self.delegate) != nil) {
            self.delegate?.modeSelectionVC(self, didChoose: self.faceObscuringMode)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        
        switch indexPath.row {
        case 0:
            cell?.textLabel!.text = "White Blur"
            cell?.accessoryType =
                (self.faceObscuringMode == .WhiteBlur) ? .checkmark : .none
        case 1:
            cell?.textLabel!.text = "Black Rectangle"
            cell?.accessoryType =
                (self.faceObscuringMode == .BlackRectangle) ? .checkmark : .none
        case 2:
            cell?.textLabel!.text = "White Blur (eyes only)"
            cell?.accessoryType =
                (self.faceObscuringMode == .WhiteBlurEyesOnly) ? .checkmark : .none
        case 3:
            cell?.textLabel!.text = "Black Rectangle (eyes only)"
            cell?.accessoryType =
                (self.faceObscuringMode == .BlackRectangleEyesOnly) ? .checkmark : .none
        case 4:
            cell?.textLabel!.text = "Guy Fawkes mask"
            cell?.accessoryType =
                (self.faceObscuringMode == .MaskGuyFawkes) ? .checkmark : .none;
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.faceObscuringMode = .WhiteBlur
        case 1:
            self.faceObscuringMode = .BlackRectangle
        case 2:
            self.faceObscuringMode = .WhiteBlurEyesOnly
        case 3:
            self.faceObscuringMode = .BlackRectangleEyesOnly
        case 4:
            self.faceObscuringMode = .MaskGuyFawkes
        default:
            break
        }
        
        self.tableView?.reloadData()
    }
}
