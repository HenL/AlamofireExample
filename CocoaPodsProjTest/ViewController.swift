//
//  ViewController.swift
//  CocoaPodsProjTest
//
//  Created by Hen Levy on 07/10/2015.
//  Copyright © 2015 Hen Levy. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet var requestButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var continueButton: UIButton!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Events

    @IBAction func requestDidTap(sender: UIButton) {
        
        self.requestButton.hidden = true
        self.activityIndicator.startAnimating()
        
        Alamofire.request(.GET, "http://httpbin.org/get")
            .responseJSON { response in
                
                guard let jsonResult = response.result.value as? Dictionary<String, AnyObject> else {
                    return
                }
                
                print(jsonResult.debugDescription)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.textView.text = jsonResult.debugDescription
                    self.textView.hidden = false
                    self.continueButton.hidden = false
                    self.activityIndicator.stopAnimating()
                }
        }
        
        let iconUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Robot_icon.svg/1024px-Robot_icon.svg.png"
        
        Alamofire.request(Method.GET, iconUrl).validate().response {
            (_, _, data, _) in
            
            guard let imageData = data else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = UIImage(data: imageData)
            }
        }
    }
}

