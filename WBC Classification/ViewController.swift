//
//  ViewController.swift
//  WBC Classification
//
//  Created by Poom Penghiran on 24/11/2561 BE.
//  Copyright © 2561 Poom Penghiran. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CropViewController
import Crashlytics

class ViewController: UIViewController {
    
    @IBOutlet weak var ui_displayImage: UIImageView!
    @IBOutlet weak var ui_detectButton: UIButton!
    @IBOutlet weak var ui_result: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takePhotoTappeed(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.authorisationStatus(attachmentTypeEnum: AttachmentType.camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.authorisationStatus(attachmentTypeEnum: AttachmentType.photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func detectTapped(_ sender: UIButton) {
        // TODO: Connect to API for detection
    }
    
    private func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable( .camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Device not Supported", message: "Device not supported to take photo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func selectFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable( .photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Device not Supported", message: "Device not supported to get photos from library", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func authorisationStatus(attachmentTypeEnum: AttachmentType) {
        
        if attachmentTypeEnum ==  AttachmentType.camera {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status{
            case .authorized: // The user has previously granted access to the camera.
                self.takePhoto()
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.takePhoto()
                    }
                }
            //denied - The user has previously denied access.
            //restricted - The user can't grant access due to restrictions.
            case .denied, .restricted:
                self.alertForDeniedMediaAccess(type: attachmentTypeEnum)
                return
            default:
                break
            }
        } else if attachmentTypeEnum == AttachmentType.photoLibrary {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status{
            case .authorized:
                if attachmentTypeEnum == AttachmentType.photoLibrary{
                    selectFromLibrary()
                }
            case .denied, .restricted:
                alertForDeniedMediaAccess(type: attachmentTypeEnum)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized {
                        // photo library access given
                        self.selectFromLibrary()
                    }
                })
            default:
                break
            }
        }
    }
    
    private func alertForDeniedMediaAccess(type: AttachmentType) {
        // TODO: Add handler for privacy setting
        let alert = UIAlertController(title: "Cannot access \(type)", message: "Please grant access for \(type)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let cropViewController = CropViewController(image: selectedImage)
                cropViewController.title = "Crop the target WBC"
//                cropViewController.imageCropFrame = CGRect(x: 0, y: 0, width: 200, height: 160)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPreset = .presetSquare
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
            }
        } else {
            // TODO: Handle error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        ui_displayImage.image = image
        self.dismiss(animated: true) {
            self.ui_detectButton.isHidden = false
        }
    }
    
}

enum AttachmentType: String {
    case camera, photoLibrary
}
