//
//  OperationViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/1/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit

class OperationViewController: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func addPhotos(sender: AnyObject)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = false
            self.presentViewController(imag, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func addVideos(sender: AnyObject)
    {
    
    }
    
    
    @IBAction func addMusic(sender: AnyObject)
    {
    
    
    }
   
    
    @IBAction func recordMusic(sender: AnyObject)
    {
    
    
    }
    
    
    @IBAction func recordVideo(sender: AnyObject)
    {
    
    
    }
    
    @IBAction func takeAPhoto(sender: AnyObject)
    {
    
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        let selectedImage : UIImage = image
        //var tempImage:UIImage = editingInfo[UIImagePickerControllerOriginalImage] as UIImage
       // img.image=selectedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    
    }
    

}
