//
//  OperationViewController.swift
//  PicFlow++
//
//  Created by Sheen on 3/1/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit
import MediaPlayer

class OperationViewController: UIViewController,UINavigationControllerDelegate,ELCImagePickerControllerDelegate,MPMediaPickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,PhotoPickerViewControllerDelegate {

   
    @IBOutlet weak var actionsListView: UITableView!
    var actions:[String] = ["Add Photos","Add Music","Show Details"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionsListView.delegate = self
        actionsListView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openMeida(mediaType: EMedia)
    {
        var photoPicker = PhotoPickerViewController(title: "Photos")
        photoPicker.isMultipleSelectionEnabled = true
        photoPicker.delegate = self;
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    func openMeida2(mediaType: EMedia)
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
    
    func getViewController() -> ViewController?
    {
       let mAppDelegate:AppDelegate  =  UIApplication.sharedApplication().delegate as AppDelegate
       return mAppDelegate.mainViewController
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
 
    @IBAction func showDetails(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.getViewController()?.showDetailedViewController()
    }

    //photo picker delegate
    //one asset
     /**
    Called when the user had finished picking and had selected multiple assets, which are returned in an array.
    */
    func imagePickerController(picker:PhotoPickerViewController,didFinishPickingArrayOfMediaWithInfo info:NSArray)
    {
        self.getViewController()?.selectedProject?.addPhotos(info)
        self.dismissViewControllerAnimated(false, completion: nil)
        self.getViewController()?.showDetailedViewController()
    }
    
    /**
    Called when the user canceled the picking.
    */
    func imagePickerControllerDidCancel( picker:PhotoPickerViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func elcImagePickerController(picker: ELCImagePickerController, didFinishPickingMediaWithInfo info: NSArray )
    {
        self.getViewController()?.selectedProject?.addPhotos(info)
        self.dismissViewControllerAnimated(false, completion: nil)
        self.getViewController()?.showDetailedViewController()
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return actions.count
    }
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell = self.actionsListView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = self.actions[indexPath.row]
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if(self.actions[indexPath.row] == actions[0])
        {
            self.addPhotos(tableView)
        }
        else if(self.actions[indexPath.row] == actions[2])
        {
            self.showDetails(tableView)
        }

    }
    
    

}
