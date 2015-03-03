//
//  OperationViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/1/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit

class OperationViewController: UIViewController,UINavigationControllerDelegate,ELCImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMeida(mediaType: EMedia)
    {
        var elcPicker = ELCImagePickerController(type: mediaType)
        elcPicker.maximumImagesCount = 10 //Set the maximum number of images to select, defaults to 4
        elcPicker.imagePickerDelegate = self
        self.presentViewController(elcPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func addPhotos(sender: AnyObject)
    {
        openMeida(EPhoto)
    }
    
    
    @IBAction func addVideos(sender: AnyObject)
    {
        openMeida(EVideo)
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
    
 
    
    func elcImagePickerController(picker: ELCImagePickerController, didFinishPickingMediaWithInfo info: NSArray )
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func elcImagePickerControllerDidCancel(picker:ELCImagePickerController )
    {
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    
    }
    

}
