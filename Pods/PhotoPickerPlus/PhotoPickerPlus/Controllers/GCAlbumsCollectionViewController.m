//
//  GCAlbumsCollectionViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 3/14/14.
//  Copyright (c) 2014 Chute. All rights reserved.
//

#import "GCAlbumsCollectionViewController.h"
#import "GCAssetsCollectionViewController.h"
#import "GCAssetsTableViewController.h"
#import "GCAccountMediaViewController.h"
#import "GCAccountAlbum.h"
#import "GCAlbumCell.h"

#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GCPhotoPickerConfiguration.h"
#import "GetChute.h"
#import "PHAsset+Utilities.h"


@interface GCAlbumsCollectionViewController ()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *tempAlbums;
@property (strong, nonatomic) NSMutableArray *elementCount;

@end

@implementation GCAlbumsCollectionViewController

@synthesize assetsLibrary,elementCount,tempAlbums;

@synthesize isMultipleSelectionEnabled, isItDevice, accountID, serviceName, albums,successBlock, cancelBlock;
//@synthesize successBlock, cancelBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

+ (UICollectionViewFlowLayout *)setupLayout
{
  UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
  [aFlowLayout setItemSize:CGSizeMake(73.75, 73.75)];
  [aFlowLayout setMinimumInteritemSpacing:0.0f];
  [aFlowLayout setMinimumLineSpacing:5];
  [aFlowLayout setSectionInset:(UIEdgeInsetsMake(5, 5, 5, 5))];
  [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  
  return aFlowLayout;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.title = @"Albums";
  [self.collectionView setBackgroundColor:[UIColor whiteColor]];
  
  if(self.isItDevice) {
    [self getAlbumsFromDevice];
    [self.navigationItem setRightBarButtonItem:[self setCancelButton]];
  }
  
  [self.collectionView registerClass:[GCAlbumCell class] forCellWithReuseIdentifier:@"AlbumCell"];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Data Source and Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  if (self.isItDevice)
    return [self.albums count];
  else
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  NSInteger numberOfRows = 0;
  if (self.isItDevice) {
    PHFetchResult *fetchResult = self.albums[section];
    numberOfRows = fetchResult.count;
  }
  else
    numberOfRows = [self.albums count];
  return numberOfRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  GCAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
  
  if([self isItDevice]) {
    PHFetchResult *fetchResult = self.albums[indexPath.section];
    PHCollection *collection = fetchResult[indexPath.row];
    
    __block NSInteger assetsCount = 0;
    if ([collection isKindOfClass:[PHAssetCollection class]]) {
      PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:[PHAsset fetchOptions]];
      [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset.mediaSubtypes != PHAssetMediaSubtypeVideoHighFrameRate)
          assetsCount++;
      }];
      PHAsset *asset = assets.lastObject;
      if (asset != nil) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.version = PHImageRequestOptionsVersionCurrent;
//        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(50, 50) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
          if (result)
            cell.imageView.image = result;
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
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",albumForCell.name];
  }
  
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
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
    } else  {
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
    GCAccountAlbum *accAlbum = [self.albums objectAtIndex:indexPath.item];
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
  
  [self.collectionView reloadData];
  
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

@end
