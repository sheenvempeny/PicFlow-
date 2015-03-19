//
//  GCLegacyAssetsTableViewController.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aranea | Oliver Dimitrov on 2/11/15.
//  Copyright (c) 2015 Chute. All rights reserved.
//

#import "GCLegacyAssetsTableViewController.h"
#import "GCAssetCell.h"

#import "GCAccountAssets.h"
#import "GCServicePicker.h"
#import "NSDictionary+ALAsset.h"
#import "NSDictionary+GCAccountAsset.h"
#import "UIImage+VideoImage.h"

#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "GCAsset.h"

@interface GCLegacyAssetsTableViewController ()

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (strong, nonatomic) NSMutableArray *selectedAssets;

@end

@implementation GCLegacyAssetsTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.selectedAssets = [NSMutableArray new];
  
  if(self.isItDevice) {
    [self getLocalAssets];
    if (self.isMultipleSelectionEnabled) {
      [self.navigationItem setRightBarButtonItems:[self doneAndCancelButtons]];
    }
    else {
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
  return [self.assets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"AssetCell";
  GCAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  if (cell == nil) {
    cell = [[GCAssetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  if(self.isItDevice)
  {
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    [cell.titleLabel setText:@"No caption available"];
    [cell.titleLabel setTextColor:[UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1]];
    
    if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
      cell.imageView.image = [UIImage makeImageFromBottomImage:[UIImage imageWithCGImage:[asset thumbnail]] withFrame:cell.imageView.frame andTopImage:[UIImage imageNamed:@"video_overlay.png"] withFrame:CGRectMake(0, 0, 15, 15)];
    }
    else {
      cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    }
  }
  else
  {
    GCAccountAssets *asset = [self.assets objectAtIndex:indexPath.row];
    
    if (asset.caption != nil) {
      [cell.titleLabel setText:asset.caption];
    }
    else {
      [cell.titleLabel setText:@"No caption available"];
      [cell.titleLabel setTextColor:[UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1]];
    }
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[asset thumbnail]]] success:^(UIImage *image) {
      if (asset.videoUrl != nil) {
        cell.imageView.image = [UIImage makeImageFromBottomImage:image withFrame:cell.imageView.frame andTopImage:[UIImage imageNamed:@"video_overlay.png"] withFrame:CGRectMake(0, 0, 15, 15)];
      }
      else {
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
  if([self isItDevice])
  {
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    [self.selectedAssets addObject:asset];
  }
  else
  {
    GCAccountAssets *asset = [self.assets objectAtIndex:indexPath.row];
    [self.selectedAssets addObject:asset];
  }
  
  if(self.isMultipleSelectionEnabled)
  {
    [self.tableView setAllowsMultipleSelection:YES];
    
    if([self.selectedAssets count] > 0)
      [self.doneButton setEnabled:YES];
  }
  else
  {
    [self done];
  }
  
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(self.isMultipleSelectionEnabled)
  {
    if([self isItDevice])
    {
      ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
      [self.selectedAssets removeObject:asset];
    }
    else
    {
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
  NSMutableArray *temp = [[NSMutableArray alloc] init];
  [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
    if(result !=nil){
      [temp insertObject:result atIndex:0];
    }
    else
    {
      [self setAssets:temp];
      [self.tableView reloadData];
    }
    
  }];
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
        for (ALAsset *asset in self.selectedAssets) {
          [infoArray addObject:([NSDictionary infoFromALAsset:asset])];
        }
        info = infoArray;
        [HUD hide:YES];
        [self successBlock](info);
      }
      else
      {
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
      
    }
    else {
      if(self.isItDevice)
      {
        info = [NSDictionary infoFromALAsset:[self.selectedAssets objectAtIndex:0]];
        [HUD hide:YES];
        [self successBlock](info);
      }
      else
      {
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
