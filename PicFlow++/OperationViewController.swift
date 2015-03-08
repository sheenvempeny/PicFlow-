//
//  OperationViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/1/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit
import MediaPlayer

class OperationViewController: UIViewController,UINavigationControllerDelegate,ELCImagePickerControllerDelegate,MPMediaPickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func getViewController() -> ViewController
    {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let controller:UIViewController = appDelegate.window!.rootViewController!
        return controller as ViewController;
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
    
    func openAudio()
    {
        var picker: MPMediaPickerController = MPMediaPickerController(mediaTypes: MPMediaType.Music)
        picker.delegate						= self;
        picker.allowsPickingMultipleItems	= true;
        picker.prompt						= "Add songs to play"
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        self.presentViewController(picker, animated: true, completion: nil)
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
        openAudio()
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
        let viewController:ViewController = self.getViewController()
        viewController.mProject.addPhotos(info)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func elcImagePickerControllerDidCancel(picker:ELCImagePickerController )
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!)
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
