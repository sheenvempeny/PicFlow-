//
//  GCLegacyAlbumsCollectionViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aranea | Oliver Dimitrov on 2/11/15.
//  Copyright (c) 2015 Chute. All rights reserved.
//

#import "GCLegacyAlbumsCollectionViewController.h"
#import "GCLegacyAssetsTableViewController.h"
#import "GCLegacyAssetsCollectionViewController.h"
#import "GCAccountMediaViewController.h"
#import "GCAccountAlbum.h"
#import "GCAlbumCell.h"

#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GCPhotoPickerConfiguration.h"
#import "GetChute.h"

@interface GCLegacyAlbumsCollectionViewController ()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *tempAlbums;
@property (strong, nonatomic) NSMutableArray *elementCount;

@end

@implementation GCLegacyAlbumsCollectionViewController

@synthesize assetsLibrary,elementCount,tempAlbums;
@synthesize isMultipleSelectionEnabled, isItDevice, accountID, serviceName, albums,successBlock, cancelBlock;

static NSString * const reuseIdentifier = @"AlbumCell";

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
  
  [self.collectionView registerClass:[GCAlbumCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Data Source and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [self.albums count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  GCAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
  
  if([self isItDevice]) {
    ALAssetsGroup *albumForCell = [albums objectAtIndex:indexPath.row];
    NSString *albumName = [albumForCell valueForProperty:ALAssetsGroupPropertyName];
    NSString *numOfAssets = [elementCount objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@  (%@)", albumName,numOfAssets];
  }
  
  else {
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
      
      GCLegacyAssetsTableViewController *atVC = [GCLegacyAssetsTableViewController new];
      [atVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
      [atVC setSuccessBlock:[self successBlock]];
      [atVC setCancelBlock:[self cancelBlock]];
      [atVC setIsItDevice:self.isItDevice];
      [atVC setAssetGroup:[self.albums objectAtIndex:indexPath.row]];
      
      [self.navigationController pushViewController:atVC animated:YES];
    }
    
    else  {
      GCLegacyAssetsCollectionViewController *acVC = [[GCLegacyAssetsCollectionViewController alloc] initWithCollectionViewLayout:[GCLegacyAssetsCollectionViewController setupLayout]];
      [acVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
      [acVC setSuccessBlock:self.successBlock];
      [acVC setCancelBlock:self.cancelBlock];
      [acVC setIsItDevice:self.isItDevice];
      [acVC setAssetGroup:[self.albums objectAtIndex:indexPath.row]];
      
      [self.navigationController pushViewController:acVC animated:YES];
    }
  }
  
  else {
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
  self.elementCount = [[NSMutableArray array] init];
  
  if (!self.assetsLibrary) {
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
  }
  if (!self.albums) {
    self.tempAlbums = [[NSMutableArray alloc] init];
  } else {
    [self.tempAlbums removeAllObjects];
  }
  
  ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock =  ^(ALAssetsGroup *group, BOOL *stop) {
    if(group != nil) {
      //Add the album to the array
      [self.tempAlbums addObject: group];
      
      if ([[[GCPhotoPickerConfiguration configuration] mediaTypesAvailable] isEqualToString:@"Photos"])
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
      if ([[[GCPhotoPickerConfiguration configuration] mediaTypesAvailable] isEqualToString:@"Videos"])
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
      if ([[[GCPhotoPickerConfiguration configuration] mediaTypesAvailable] isEqualToString:@"All Media"])
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
      [elementCount addObject: [NSNumber numberWithInt:group.numberOfAssets]];
      
    } else
    {
      [self setAlbums:self.tempAlbums];
      [self.collectionView reloadData];
    }
    
  };
  
  [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:^(NSError *error) {
    GCLogError([error localizedDescription]);
  }];
  
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
