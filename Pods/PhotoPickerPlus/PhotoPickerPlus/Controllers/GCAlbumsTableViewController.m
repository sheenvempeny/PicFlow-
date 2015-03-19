//
//  DeviceAlbumViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 8/5/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "GCAlbumsTableViewController.h"
#import "GCAssetsCollectionViewController.h"
#import "GCAssetsTableViewController.h"
#import "GCAccountMediaViewController.h"
#import "GCAccountAlbum.h"
#import "GCPhotoPickerCell.h"
#import "GCPhotoPickerConfiguration.h"

#import "GetChute.h"

#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PHAsset+Utilities.h"

@interface GCAlbumsTableViewController ()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *tempAlbums;
@property (strong, nonatomic) NSMutableArray *elementCount;
@property (strong, nonatomic) NSMutableArray *cachedImages;

@end

@implementation GCAlbumsTableViewController

@synthesize albums, assetsLibrary,elementCount,tempAlbums;

@synthesize successBlock, cancelBlock;

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.title = @"Albums";
  
  if(self.isItDevice) {
    [self getAlbumsFromDevice];
    [self.navigationItem setRightBarButtonItem:[self setCancelButton]];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (self.isItDevice)
    return [self.albums count];
  else
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  NSInteger numberOfRows = 0;
  if (self.isItDevice) {
    PHFetchResult *fetchResult = self.albums[section];
    numberOfRows = fetchResult.count;
  } else
    numberOfRows = [self.albums count];
  return numberOfRows;
}

- (GCPhotoPickerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  GCPhotoPickerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[GCPhotoPickerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  if([self isItDevice]) {
    NSArray *fetchResult = self.albums[indexPath.section];
    PHCollection *collection = fetchResult[indexPath.row];
    
    __block NSInteger assetsCount = 0;
    if ([collection isKindOfClass:[PHAssetCollection class]]) {
      PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:[PHAsset fetchOptions]];
      [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset.mediaSubtypes != PHAssetMediaSubtypeVideoHighFrameRate)
          assetsCount++;
      }];
      PHAsset *asset = assets.firstObject;
      if (asset != nil) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.version = PHImageRequestOptionsVersionCurrent;
//        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:cell.imageView.frame.size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
          if (result) {
            cell.imageView.image = result;
          }
          else
            cell.imageView.image = [UIImage imageNamed:@"album_default.png"];
        }];
      }
      else
       cell.imageView.image = [UIImage imageNamed:@"album_default.png"];
    }
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%ld)",collection.localizedTitle,(long)assetsCount];
  } else {
    GCAccountAlbum *albumForCell = [self.albums objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"album_default.png"];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",albumForCell.name];
  }
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(self.isItDevice) {
    NSDictionary *defaultLayouts = [[GCPhotoPickerConfiguration configuration] defaultLayouts];
    
    if ([[defaultLayouts objectForKey:@"asset_layout"] isEqualToString:@"tableView"]) {
      
      GCAssetsTableViewController *atVC = [GCAssetsTableViewController new];
      [atVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
      [atVC setSuccessBlock:[self successBlock]];
      [atVC setCancelBlock:[self cancelBlock]];
      [atVC setIsItDevice:self.isItDevice];
      NSArray *fetchResult = self.albums[indexPath.section];
      PHCollection *collection = fetchResult[indexPath.row];
      [atVC setCollection:collection];
      
      [self.navigationController pushViewController:atVC animated:YES];
    } else {
      GCAssetsCollectionViewController *acVC = [[GCAssetsCollectionViewController alloc] initWithCollectionViewLayout:[GCAssetsCollectionViewController setupLayout]];
      [acVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
      [acVC setSuccessBlock:self.successBlock];
      [acVC setCancelBlock:self.cancelBlock];
      [acVC setIsItDevice:self.isItDevice];
      NSArray *fetchResult = self.albums[indexPath.section];
      PHCollection *collection = fetchResult[indexPath.row];
      [acVC setCollection:collection];
      
      [self.navigationController pushViewController:acVC animated:YES];
    }
  } else {
    GCAccountAlbum *accAlbum = [self.albums objectAtIndex:indexPath.row];
    GCAccountMediaViewController *amVC = [GCAccountMediaViewController new];
    [amVC setAccountID:self.accountID];
    [amVC setAlbumID:accAlbum.id];
    [amVC setServiceName:self.serviceName];
    [amVC setIsItDevice:self.isItDevice];
    [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
    [amVC setSuccessBlock:self.successBlock];
    [amVC setCancelBlock:self.cancelBlock];
    
    [self.parentViewController.navigationController pushViewController:amVC animated:YES];
  }
}

#pragma mark - Custom Methods

- (void)getAlbumsFromDevice
{
  NSMutableArray *smartAlbums = [NSMutableArray new];
  NSMutableArray *topLevelAlbums = [NSMutableArray new];
  self.elementCount = [NSMutableArray new];
  
  PHFetchResult *smartAlbumsResults = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
  [smartAlbumsResults enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
    if (collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumSlomoVideos)
      [smartAlbums addObject:collection];
  }];
  
  PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
  [topLevelUserCollections enumerateObjectsUsingBlock:^(PHCollectionList *collection, NSUInteger idx, BOOL *stop) {
    [topLevelAlbums addObject:collection];
  }];
  self.albums = @[smartAlbums, topLevelAlbums];
  
  [self.tableView reloadData];
}

- (UIBarButtonItem *)setCancelButton
{
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
  
  return cancelButton;
}

- (void)cancel
{
  if (self.cancelBlock)
    [self cancelBlock]();
}

#pragma mark - Setters

- (void)setAccountID:(NSString *)accountID
{
  if(![_accountID isEqualToString:accountID])
    _accountID = accountID;
}

- (void)setIsMultipleSelectionEnabled:(BOOL)isMultipleSelectionEnabled
{
  if(_isMultipleSelectionEnabled != isMultipleSelectionEnabled)
    _isMultipleSelectionEnabled = isMultipleSelectionEnabled;
}

- (void)setIsItDevice:(BOOL)isItDevice
{
  if(_isItDevice != isItDevice)
    _isItDevice = isItDevice;
}

- (void)setServiceName:(NSString *)serviceName
{
  if(_serviceName != serviceName)
    _serviceName = serviceName;
}

@end
