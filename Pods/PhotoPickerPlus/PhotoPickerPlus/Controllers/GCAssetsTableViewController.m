//
//  GCAssetsTableViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 3/14/14.
//  Copyright (c) 2014 Chute. All rights reserved.
//

#import "GCAssetsTableViewController.h"
#import "GCAssetCell.h"

#import "GCAccountAssets.h"
#import "GCServicePicker.h"
//#import "NSDictionary+ALAsset.h"
#import "NSDictionary+GCAccountAsset.h"
#import "UIImage+VideoImage.h"
#import "PHAsset+Utilities.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "GCAsset.h"

@interface GCAssetsTableViewController ()

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (strong, nonatomic) NSMutableArray *selectedAssets;
@property (strong, nonatomic) PHImageManager *imageManager;
@property (strong, nonatomic) NSMutableArray *fetchedAssets;

@end

@implementation GCAssetsTableViewController

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
  self.navigationItem.title = self.collection != nil ?  self.collection.localizedTitle:@"Assets";
  self.selectedAssets = [NSMutableArray new];
  
  if(self.isItDevice) {
    [self getLocalAssets];
    if (self.isMultipleSelectionEnabled) {
      [self.navigationItem setRightBarButtonItems:[self doneAndCancelButtons]];
    } else {
      [self.navigationItem setRightBarButtonItem:[self cancelButton]];
    }
  }
  [self.tableView registerClass:[GCAssetCell class] forCellReuseIdentifier:@"AssetCell"];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  if (self.isItDevice)
    return self.fetchedAssets.count;
  else
    return [self.assets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"AssetCell";
  GCAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  if (cell == nil) {
    cell = [[GCAssetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  if(self.isItDevice) {
    PHAsset *asset = self.fetchedAssets[indexPath.item];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    //      options.synchronous = YES;
    [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(50, 50) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
      cell.imageView.image = result;
      if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoView.image = [UIImage imageNamed:@"video_overlay"];
        cell.duration.text = [asset getDuration];
      }
    }];
    
    [cell.titleLabel setText:@"No caption available"];
    [cell.titleLabel setTextColor:[UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1]];
  } else {
    GCAccountAssets *asset = [self.assets objectAtIndex:indexPath.row];
    
    if (asset.caption != nil) {
      [cell.titleLabel setText:asset.caption];
    } else {
      [cell.titleLabel setText:@"No caption available"];
      [cell.titleLabel setTextColor:[UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1]];
    }
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[asset thumbnail]]] success:^(UIImage *image) {
      if (asset.videoUrl != nil) {
        cell.imageView.image = [UIImage makeImageFromBottomImage:image withFrame:cell.imageView.frame andTopImage:[UIImage imageNamed:@"video_overlay.png"] withFrame:CGRectMake(0, 0, 15, 15)];
      } else {
        [cell.imageView setImage:image];
      }
    }];
    [operation start];
  }
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if([self isItDevice]) {
    PHAsset *asset = self.fetchedAssets[indexPath.item];
    [self.selectedAssets addObject:asset];
  } else {
    GCAccountAssets *asset = [self.assets objectAtIndex:indexPath.row];
    [self.selectedAssets addObject:asset];
  }
  
  if(self.isMultipleSelectionEnabled) {
    [self.tableView setAllowsMultipleSelection:YES];
    
    if([self.selectedAssets count] > 0)
      [self.doneButton setEnabled:YES];
  } else {
    [self done];
  }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(self.isMultipleSelectionEnabled) {
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
#pragma mark - Custom methods

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
  
  [self.tableView reloadData];
  
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
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:HUD];
    [HUD show:YES];
    
    if ([self isMultipleSelectionEnabled]) {
      NSMutableArray *infoArray = [NSMutableArray array];
      if(self.isItDevice) {
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
//        info = [NSDictionary infoFromALAsset:[self.selectedAssets objectAtIndex:0]];
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


@end
