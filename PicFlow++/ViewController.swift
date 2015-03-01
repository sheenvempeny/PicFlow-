//
//  ViewController.swift
//  PicFlow++
//
//  Created by Sheen on 2/2/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var projectsList: UICollectionView!
    @IBOutlet weak var operViewController : OperationViewController!
    
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
    
    }
}

