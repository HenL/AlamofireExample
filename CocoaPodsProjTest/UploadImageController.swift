//
//  UploadImageController.swift
//  CocoaPodsProjTest
//
//  Created by Hen Levy on 12/10/2015.
//  Copyright © 2015 Hen Levy. All rights reserved.
//

import UIKit
import Alamofire
import AssetsLibrary
import Photos
import Bolts

class UploadImageController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var pickedImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var progressView: UIProgressView!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadAnImageDidTap(sender: UIButton) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK:  UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(pickedImage)
            let localId = (assetChangeRequest.placeholderForCreatedAsset?.localIdentifier)!
            let assetResult = PHAsset.fetchAssetsWithLocalIdentifiers([localId], options: nil)
            let asset = assetResult.firstObject as! PHAsset
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil, resultHandler: { [weak self] (imageData, dataUTI, orientation, info) -> Void in
                    print(info)
                    
                    guard let strongSelf = self, imageInfo = info, imageUrl = imageInfo["PHImageFileURLKey"] as? NSURL else {
                        return
                    }
                    
                    strongSelf.uploadImage(imageUrl, pickedImage: pickedImage)
                    })
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Upload
    
    func uploadImage(imageUrl: NSURL, pickedImage: UIImage) {

        // update ui
        self.pickedImageView.image = pickedImage
        self.pickedImageView.alpha = 0.7
        self.uploadButton.setTitle("Uploading...", forState: .Normal)
        self.uploadButton.userInteractionEnabled = false
        self.progressView.hidden = false
        self.activityIndicator.startAnimating()
        
        // upload image
        Alamofire.upload(.POST, "http://httpbin.org/post", file: imageUrl)
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                print(totalBytesWritten)

                dispatch_async(dispatch_get_main_queue()) {
                    print("Total bytes written on main queue: \(totalBytesWritten)")
                    
                    let part = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    self.progressView.progress = part
                }
            }
            .responseJSON { response in
                debugPrint(response)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.progressView.progress = 1.0
                    self.pickedImageView.alpha = 1.0
                    self.activityIndicator.stopAnimating()
                    self.uploadButton.setTitle("Upload Done!", forState: .Normal)
                });
        }
    }
}
