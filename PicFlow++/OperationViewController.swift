//
//  OperationViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/1/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit
import MediaPlayer

class OperationViewController: NSObject,UINavigationControllerDelegate,MPMediaPickerControllerDelegate,PhotoPickerViewControllerDelegate {

    var currentViewController:UIViewController?
    
    func openMeida(mediaType: EMedia)
    {
        var photoPicker = PhotoPickerViewController(title: "Photos")
        photoPicker.isMultipleSelectionEnabled = true
        photoPicker.delegate = self;
        currentViewController!.presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    
    func openAudio()
    {
        var picker: MPMediaPickerController = MPMediaPickerController(mediaTypes: MPMediaType.Music)
        picker.delegate						= self;
        picker.allowsPickingMultipleItems	= true;
        picker.prompt						= "Add songs to play"
        picker.showsCloudItems              = true
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        currentViewController!.presentViewController(picker, animated: true, completion: nil)
    }
    
    func getViewController() -> ViewController?
    {
       let mAppDelegate:AppDelegate  =  UIApplication.sharedApplication().delegate as! AppDelegate
       return mAppDelegate.mainViewController
    }
    
    
    @IBAction func addPhotos(sender: AnyObject)
    {
        openMeida(EPhoto)
    }
    
    @IBAction func addMusic(sender: AnyObject)
    {
        openAudio()
    }
   
    
    
    
    
    
    //photo picker delegate
    //one asset
     /**
    Called when the user had finished picking and had selected multiple assets, which are returned in an array.
    */
    func imagePickerController(picker:PhotoPickerViewController,didFinishPickingArrayOfMediaWithInfo info:[AnyObject]!)
    {
        self.getViewController()!.selectedProject?.addPhotos(info);
        currentViewController!.dismissViewControllerAnimated(false, completion: {
        
            var detailedViewController = self.getViewController()!.detailedViewController
            if(self.currentViewController!.isEqual(detailedViewController) == false){
                self.getViewController()?.showDetailedViewController()
            }
            else{
                
                detailedViewController!.reloadProject();
            }

        })
        
    }
    
    /**
    Called when the user canceled the picking.
    */
    func imagePickerControllerDidCancel( picker:PhotoPickerViewController)
    {
        currentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!)
    {
        currentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!)
    {
        currentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    

 

}
