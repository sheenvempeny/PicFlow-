//
//  GCAccountMediaViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 8/20/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "GCAccountMediaViewController.h"
#import "GCAlbumsTableViewController.h"
#import "GCAlbumsCollectionViewController.h"
#import "GCAssetsCollectionViewController.h"
#import "GCAssetsTableViewController.h"
#import "GCServicePicker.h"
#import "GCPhotoPickerConfiguration.h"
#import "GCAccountAssets.h"

#import "MBProgressHUD.h"

@interface GCAccountMediaViewController ()

@property (strong, nonatomic) NSArray *folders;
@property (strong, nonatomic) NSArray *files;

@property (strong, nonatomic) NSString  *foldersLayout;
@property (strong, nonatomic) NSString  *assetsLayout;

@end

@implementation GCAccountMediaViewController

@synthesize scrollView;
@synthesize albumViewController, assetViewController;
@synthesize albumCollectionViewController, assetTableViewController;
@synthesize accountID, albumID, isItDevice, isMultipleSelectionEnabled;
@synthesize successBlock, cancelBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setServiceName:(NSString *)newServiceName
{
    if (newServiceName != _serviceName) {
        _serviceName = newServiceName;
        
        NSDictionary *layouts = [[GCPhotoPickerConfiguration configuration] servicesLayouts];
        NSDictionary *serviceLayout = [layouts objectForKey:_serviceName];
        
        self.foldersLayout = [serviceLayout objectForKey:@"folder_layout"];
        self.assetsLayout = [serviceLayout objectForKey:@"asset_layout"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.scrollView];
       
    [self getDataFromAccount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setScrollViewContentSize];
}

#pragma mark - Custom Methods

- (void)getDataFromAccount
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [GCServicePicker getDataForServiceWithName:self.serviceName forAccountWithID:self.accountID forAlbumWithID:self.albumID success:^(GCResponseStatus *responseStatus, NSArray *folders, NSArray *files) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
        
        self.folders = folders;
        self.files = files;
        
        [self setupViewControllers];

    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)setupViewControllers
{
    
    if(self.folders != nil)
    {
        if ([self.foldersLayout isEqualToString:@"collectionView"]) {
            self.albumCollectionViewController = [[GCAlbumsCollectionViewController alloc] initWithCollectionViewLayout:[GCAlbumsCollectionViewController setupLayout]];
            
            [self addChildViewController:self.albumCollectionViewController];
            [self.scrollView addSubview:self.albumCollectionViewController.collectionView];
            [self.albumCollectionViewController didMoveToParentViewController:self];
            
            [self.albumCollectionViewController setServiceName:self.serviceName];
            [self.albumCollectionViewController setAccountID:self.accountID];
            [self.albumCollectionViewController setAlbums:self.folders];
            [self.albumCollectionViewController setIsItDevice:self.isItDevice];
            [self.albumCollectionViewController setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            [self.albumCollectionViewController setSuccessBlock:self.successBlock];
            [self.albumCollectionViewController setCancelBlock:self.cancelBlock];
            
            [self.albumCollectionViewController.collectionView reloadData];
            [self.navigationItem setRightBarButtonItem:[self.albumCollectionViewController setCancelButton]];

        }
        else  {
            self.albumViewController = [GCAlbumsTableViewController new];
            
            [self addChildViewController:self.albumViewController];
            [self.scrollView addSubview:self.albumViewController.tableView];
            [self.albumViewController didMoveToParentViewController:self];
            
            [self.albumViewController setServiceName:self.serviceName];
            [self.albumViewController setAccountID:self.accountID];
            [self.albumViewController setAlbums:self.folders];
            [self.albumViewController setIsItDevice:self.isItDevice];
            [self.albumViewController setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            [self.albumViewController setSuccessBlock:self.successBlock];
            [self.albumViewController setCancelBlock:self.cancelBlock];
            
            [self.albumViewController.tableView reloadData];
            [self.navigationItem setRightBarButtonItem:[self.albumViewController setCancelButton]];

        }
    }
    
    if(self.files != nil)
    {
        if ([self.assetsLayout isEqualToString:@"tableView"]) {
            
            self.assetTableViewController = [GCAssetsTableViewController new];
            
            [self addChildViewController:self.assetTableViewController];
            [self.scrollView addSubview:self.assetTableViewController.tableView];
            [self.assetTableViewController didMoveToParentViewController:self];
            
            [self.assetTableViewController setAssets:[self filterFiles:self.files]];
            [self.assetTableViewController setIsItDevice:self.isItDevice];
            [self.assetTableViewController setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            [self.assetTableViewController setSuccessBlock:[self successBlock]];
            [self.assetTableViewController setCancelBlock:[self cancelBlock]];
            
            [self.assetTableViewController.tableView reloadData];
            
            if ([self isMultipleSelectionEnabled]) {
                [self.navigationItem setRightBarButtonItems:[self.assetTableViewController doneAndCancelButtons]];
            }
            else {
                [self.navigationItem setRightBarButtonItem:[self.assetTableViewController cancelButton]];
            }
            
        }

        else {
            self.assetViewController = [[GCAssetsCollectionViewController alloc] initWithCollectionViewLayout:[GCAssetsCollectionViewController setupLayout]];
            [self addChildViewController:self.assetViewController];
            [self.scrollView addSubview:self.assetViewController.collectionView];
            [self.assetViewController didMoveToParentViewController:self];
            
            [self.assetViewController setAssets:[self filterFiles:self.files]];
            [self.assetViewController setSuccessBlock:[self successBlock]];
            [self.assetViewController setCancelBlock:[self cancelBlock]];
            [self.assetViewController setIsItDevice:self.isItDevice];
            [self.assetViewController setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            
            [self.assetViewController.collectionView reloadData];
            
            if ([self isMultipleSelectionEnabled]) {
                [self.navigationItem setRightBarButtonItems:[self.assetViewController doneAndCancelButtons]];
            }
            else {
                [self.navigationItem setRightBarButtonItem:[self.assetViewController cancelButton]];
            }
        }
        
    }
    
    [self setScrollViewContentSize];
    
}

- (void)setScrollViewContentSize
{
    CGFloat scrollViewWidth = self.view.bounds.size.width;
    self.scrollView.frame = self.view.bounds;

    [self.scrollView setContentSize:CGSizeZero];
    
    if (self.albumViewController != nil)
        self.albumViewController.tableView.bounds = self.scrollView.bounds;
    if (self.albumCollectionViewController != nil)
        self.albumCollectionViewController.collectionView.bounds = self.scrollView.bounds;
    if (self.assetViewController != nil)
        self.assetViewController.collectionView.bounds = self.scrollView.bounds;
    if (self.assetTableViewController != nil)
        self.assetTableViewController.tableView.bounds = self.scrollView.bounds;


    if(self.folders !=nil)
    {
        if ([self.foldersLayout isEqualToString:@"collectionView"]) {
            CGRect collectionViewFrame = self.albumCollectionViewController.collectionView.bounds;
            collectionViewFrame.size.height = self.albumCollectionViewController.collectionView.collectionViewLayout.collectionViewContentSize.height;
            collectionViewFrame.size.width = scrollViewWidth;
            collectionViewFrame.origin.y = self.scrollView.contentSize.height;
            self.albumCollectionViewController.collectionView.frame = collectionViewFrame;
            [self.albumCollectionViewController.collectionView setScrollEnabled:NO];
            
            [self.scrollView setContentSize:CGSizeMake(scrollViewWidth, self.scrollView.contentSize.height + collectionViewFrame.size.height)];
        }
        else {
            CGRect tableViewFrame = self.albumViewController.tableView.bounds;
            tableViewFrame.size.height = self.albumViewController.tableView.contentSize.height;
            tableViewFrame.size.width = scrollViewWidth;
            tableViewFrame.origin.y = self.scrollView.contentSize.height;
            self.albumViewController.tableView.frame = tableViewFrame;
            [self.albumViewController.tableView setScrollEnabled:NO];

            [self.albumViewController.tableView reloadData];

            [self.scrollView setContentSize:CGSizeMake(scrollViewWidth, self.scrollView.contentSize.height + tableViewFrame.size.height)];
        }
    }
    
    if (self.files != nil) {
        
        if ([self.assetsLayout isEqualToString:@"tableView"]) {
            CGRect tableViewFrame = self.assetTableViewController.tableView.bounds;
            tableViewFrame.size.height = self.assetTableViewController.tableView.contentSize.height;
            tableViewFrame.size.width = scrollViewWidth;
            tableViewFrame.origin.y = self.scrollView.contentSize.height;
            self.assetTableViewController.tableView.frame = tableViewFrame;
            [self.assetTableViewController.tableView setScrollEnabled:NO];
            
            [self.scrollView setContentSize:CGSizeMake(scrollViewWidth, self.scrollView.contentSize.height + tableViewFrame.size.height)];
        }
        
        else {
            CGRect collectionViewFrame = self.assetViewController.collectionView.bounds;
            collectionViewFrame.size.height = self.assetViewController.collectionView.collectionViewLayout.collectionViewContentSize.height;
            collectionViewFrame.size.width = scrollViewWidth;
            collectionViewFrame.origin.y = self.scrollView.contentSize.height;
            self.assetViewController.collectionView.frame = collectionViewFrame;
            [self.assetViewController.collectionView setScrollEnabled:NO];
                    
            [self.scrollView setContentSize:CGSizeMake(scrollViewWidth, self.scrollView.contentSize.height + collectionViewFrame.size.height)];
        }
    }
}

#pragma mark - Utility Function

- (NSArray *)filterFiles:(NSArray *)files
{
    NSMutableArray *filteredFiles = [NSMutableArray new];

    for (GCAccountAssets *asset in files) {
        if (asset.videoUrl != nil && [[GCPhotoPickerConfiguration configuration] showVideos] == YES) {
            [filteredFiles addObject:asset];
        }
        if (asset.videoUrl == nil && [[GCPhotoPickerConfiguration configuration] showImages] == YES) {
            [filteredFiles addObject:asset];
        }
    }
    return [filteredFiles copy];
}

@end
