//
//  ViewController.swift
//  PicFlow++
//
//  Created by Sheen on 2/2/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ProjectsCollectionProtocol {

   
    let detailedViewController:DetailViewController?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
    }
    
    var projectCollectionManager:ProjectsCollectionManager?
    @IBOutlet weak var projectsList: UICollectionView!
    @IBOutlet weak var operViewController : OperationViewController!
   
    
    var projects : [Project] = []
    var selectedProject:Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        // Do any additional setup after loading the view, typically from a nib.
        let mAppDelegate:AppDelegate  =  UIApplication.sharedApplication().delegate as AppDelegate
        mAppDelegate.mainViewController = self
        var projectArray:NSArray = DBManager.getSharedInstance().getProjects()
        var mProject:Project?
        for mProject in projectArray
        {
            var aProject = mProject as Project
            projects.append(aProject)
        }
        
        projectCollectionManager = ProjectsCollectionManager(inCollectionView: projectsList, withProjects: projects)
        projectCollectionManager!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showDetailedViewController() -> Void
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("DetailView") as DetailViewController
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let navController:UINavigationController = appDelegate.window?.rootViewController as UINavigationController
        navController.pushViewController(controller, animated: true)
    }
    
     func projectSelectionChanged(project: Project) {
        self.loadProject(project)
    }
    
    func loadProject(project:Project) -> Void
    {
        selectedProject = project;
        selectedProject?.load()
        self.showDetailedViewController();
    }
    

    @IBAction func NewProject(sender: AnyObject)
    {
        var newProject:Project = Project()
        projects.append(newProject)
        selectedProject = newProject;
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
    }
    

}

