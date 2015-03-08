//
//  ViewController.swift
//  PicFlow++
//
//  Created by Sheen on 2/2/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var projectsList: UICollectionView!
    @IBOutlet weak var operViewController : OperationViewController!
    
    var mProject : Project;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func NewProject(sender: AnyObject)
    {
        var newProject:Project = Project()
        mProject = newProject
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
    }
    

}

