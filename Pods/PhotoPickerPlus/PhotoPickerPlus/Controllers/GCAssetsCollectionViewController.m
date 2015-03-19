//
//  AssetsCollectionViewController.m
//  GCAPIv2TestApp
//
//  Created by Chute Corporation on 7/25/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCAssetsCollectionViewController.h"
#import "GCPhotoCell.h"
#import "GCAccountAssets.h"
#import "GCServicePicker.h"
#import "NSDictionary+ALAsset.h"
#import "NSDictionary+GCAccountAsset.h"
#import "UIImage+VideoImage.h"
#import "PHAsset+Utilities.h"

#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "GCAsset.h"

@interface GCAssetsCollectionViewController ()

@property (strong, nonatomic) PHImageManager *imageManager;

@property (strong, nonatomic) NSMutableArray *selectedAssets;
@property (strong, nonatomic) NSMutableArray *fetchedAssets;

@property (nonatomic, strong) UIBarButtonItem *doneButton;

@end

@implementation GCAssetsCollectionViewController

@synthesize doneButton;
@synthesize successBlock, cancelBlock;

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
  self.navigationItem.title = self.collection != nil ?  self.collection.localizedTitle:@"Assets";
  [self.collectionView setBackgroundColor:[UIColor whiteColor]];
  
  self.selectedAssets = [@[] mutableCopy];
  
  if(self.isItDevice) {
    [self getLocalAssets];
    if (self.isMultipleSelectionEnabled) {
      [self.navigationItem setRightBarButtonItems:[self doneAndCancelButtons]];
    } else {
      [self.navigationItem setRightBarButtonItem:[self cancelButton]];
    }
  }
  
  [self.collectionView registerClass:[GCPhotoCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView DataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  if (self.isItDevice)
    return self.fetchedAssets.count;
  else
    return [self.assets count];
}

-(GCPhotoCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  GCPhotoCell *cell = (GCPhotoCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  
  if(self.isItDevice) {
    PHAsset *asset = self.fetchedAssets[indexPath.item];
    cell.videoView.image = nil;
    cell.duration.text = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(73.75, 73.75) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
      cell.imageView.image = result;
      if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoView.image = [UIImage imageNamed:@"video_overlay"];
        cell.duration.text = [asset getDuration];
      }
    }];
  } else {
    GCAccountAssets *asset = [self.assets objectAtIndex:indexPath.row];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[asset thumbnail]]] success:^(UIImage *image) {
      if (asset.videoUrl != nil)
        cell.imageView.image = [UIImage makeImageFromBottomImage:image withFrame:cell.frame andTopImage:[UIImage imageNamed:@"video_overlay.png"] withFrame:CGRectMake(0, 0, 20, 20)];
      else
        [cell.imageView setImage:image];
    }];
    [operation start];
  }
  
  return cell;
}

#pragma mark - CollectionView Delegate Methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  if([self isItDevice]) {
    PHAsset *asset = self.fetchedAssets[indexPath.item];
    [self.selectedAssets addObject:asset];
  } else {
    GCAccountAssets *asset = [self.assets objectAtIndex:indexPath.row];
    [self.selectedAssets addObject:asset];
  }
  if(self.isMultipleSelectionEnabled){
    [self.collectionView setAllowsMultipleSelection:YES];
    
    if([self.selectedAssets count] > 0)
      [self.doneButton setEnabled:YES];
  }
  else {
    [self done];
  }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
  if(self.isMultipleSelectionEnabled)
  {
    if([self isItDevice]) {
      PHAsset *asset = self.fetchedAssets[indexPath.item];
      [self.selectedAssets removeObject:asset];
    } else {
      GCAccountAssets *asset = [self.assets objectAtIndex:indexPath.row];
      [self.selectedAssets removeObject:asset];
    }
    if([self.selectedAssets count] == 0)
      [self.doneButton setEnabled:NO];
  }
}

#pragma mark - Custom Methods

- (void)getLocalAssets
{
  self.fetchedAssets = [NSMutableArray new];
  self.imageManager = [PHImageManager defaultManager];
  if ([self.collection isKindOfClass:[PHAssetCollection class]]) {
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)self.collection options:[PHAsset fetchOptions]];
    [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
      if (asset.mediaSubtypes != PHAssetMediaSubtypeVideoHighFrameRate)
        [self.fetchedAssets addObject:asset];
    }];
  }  
}

- (UIBarButtonItem *)cancelButton
{
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
  
  return cancelButton;
}

- (NSArray *)doneAndCancelButtons
{
  self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  [self.doneButton setEnabled:NO];
  
  NSArray *navBarItemsToBeAdd = @[[self doneButton], [self cancelButton]];
  
  return navBarItemsToBeAdd;
}

#pragma mark - Instance Methods

- (void)done
{
  if (self.successBlock) {
    
    __block id info;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:HUD];
    [HUD show:YES];
    
    if ([self isMultipleSelectionEnabled]) {
      
      NSMutableArray *infoArray = [NSMutableArray array];
      if(self.isItDevice){
        typeof(self) weakSelf = self;
        __block int execCounter = self.selectedAssets.count - 1;
        for (PHAsset *asset in self.selectedAssets) {
          [asset requestMetadataWithBlock:^(NSDictionary *metadata) {
            [infoArray addObject:metadata];
            if (execCounter) execCounter--;
            else {
              dispatch_async(dispatch_get_main_queue(), ^{
                info = infoArray;
                [HUD hide:YES];
                [weakSelf successBlock](info);
              });
            }
          }];
        }
      } else {
        [GCServicePicker postSelectedImages:self.selectedAssets success:^(GCResponseStatus *responseStatus, NSArray *returnedArray) {
          for(GCAsset *asset in returnedArray){
            [infoArray addObject:([NSDictionary infoFromGCAsset:asset])];
          }
          info = infoArray;
          [HUD hide:YES];
          [self successBlock](info);
        } failure:^(NSError *error) {
          [HUD hide:YES];
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
      }
    } else {
      if(self.isItDevice) {
        PHAsset *asset = [self.selectedAssets objectAtIndex:0];
        [asset requestMetadataWithBlock:^(NSDictionary *metadata) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            [self successBlock](metadata);
          });
        }];
      } else {
        [GCServicePicker postSelectedImages:self.selectedAssets success:^(GCResponseStatus *responseStatus, NSArray *returnedArray) {
          info = [NSDictionary infoFromGCAsset:[returnedArray objectAtIndex:0]];
          [HUD hide:YES];
          [self successBlock](info);
        } failure:^(NSError *error) {
          [HUD hide:YES];
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
      }
    }
  }
}

- (void)cancel
{
  if (self.cancelBlock)
    [self cancelBlock]();
}

#pragma mark - Setters

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

- (void)setAccountID:(NSString *)accountID
{
  if(![_accountID isEqualToString:accountID])
    _accountID = accountID;
}

- (void)setAlbumID:(NSNumber *)albumID
{
  if(_albumID != albumID)
    _albumID = albumID;
}

- (void)setServiceName:(NSString *)serviceName
{
  if(_serviceName != serviceName)
    _serviceName = serviceName;
}
@end
