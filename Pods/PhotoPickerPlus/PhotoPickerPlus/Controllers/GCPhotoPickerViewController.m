//
//  PhotoPickerViewController.m
//  GCAPIv2TestApp
//
//  Created by Chute Corporation on 7/24/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCPhotoPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GCPhotoPickerCell.h"
#import "GCAlbumsCollectionViewController.h"
#import "GCAssetsCollectionViewController.h"
#import "GCAccountMediaViewController.h"
#import "GCAlbumsTableViewController.h"
#import "NSDictionary+ALAsset.h"
#import "GCServiceAccount.h"
#import "GCAccount.h"
#import "GCPhotoPickerConfiguration.h"
#import "GCMacros.h"

#import "PHAsset+Utilities.h"
#import "GCLegacyAlbumsTableViewController.h"
#import "GCLegacyAlbumsCollectionViewController.h"

#import "GetChute.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface GCPhotoPickerViewController ()

@property (nonatomic) BOOL isItDevice;
@property (assign, nonatomic) BOOL hasLocal;
@property (strong, nonatomic) NSArray *localFeatures;
@property (assign, nonatomic) BOOL hasOnline;
@property (strong, nonatomic) NSArray *services;
@property (nonatomic, strong) UIBarButtonItem *logoutButton;

@end

@implementation GCPhotoPickerViewController

@synthesize delegate, isMultipleSelectionEnabled = _isMultipleSelectionEnabled;
@synthesize isItDevice;
@synthesize navigationTitle = _navigationTitle;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.navigationTitle? self.navigationTitle: @"Photo Picker";
    
    [self setNavBarItems];

    GCClient *apiClient = [GCClient sharedClient];

    if([apiClient isLoggedIn] == NO)
        [self setLogoutNavBarButton:NO];
    else
        [self setLogoutNavBarButton:YES];
    
    [self.tableView registerClass:[GCPhotoPickerCell class] forCellReuseIdentifier:@"GroupCell"];

    [self setLocalFeatures:[[GCPhotoPickerConfiguration configuration] localFeatures]];
    [self setServices:[[GCPhotoPickerConfiguration configuration] services]];
    
    if([self.localFeatures count] > 0)
        self.hasLocal = YES;
    else
        self.hasLocal = NO;
    
    if( [self.services count] > 0)
        self.hasOnline = YES;
    else
        self.hasOnline = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.hasLocal + self.hasOnline);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.hasLocal)
        return GCLocalizedString(@"picker.local_services");
    return GCLocalizedString(@"picker.online_services");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 && self.hasLocal)
        return [self.localFeatures count];
    return [self.services count];
}

- (GCPhotoPickerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";

    GCPhotoPickerCell *cell = [[GCPhotoPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if(indexPath.section == 0 && self.hasLocal){
        
        NSString *serviceName = [self.localFeatures objectAtIndex:indexPath.row];
        NSString *cellTitle = [[serviceName capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        
        if ([cellTitle isEqualToString:GCLocalizedString(@"picker.choose_media")]) {
            if ([[[GCPhotoPickerConfiguration configuration] mediaTypesAvailable] isEqualToString:@"Photos"])
                cellTitle = GCLocalizedString(@"picker.choose_photo");
            else if ([[[GCPhotoPickerConfiguration configuration] mediaTypesAvailable] isEqualToString:@"Videos"])
                cellTitle = GCLocalizedString(@"picker.choose_video");
            [cell.imageView setImage:[UIImage imageNamed:@"defaultThumb.png"]];
        }
        if ([cellTitle isEqualToString:GCLocalizedString(@"picker.take_photo")])
            [cell.imageView setImage:[UIImage imageNamed:@"camera.png"]];
        
        if ([cellTitle isEqualToString:GCLocalizedString(@"picker.last_photo_taken")])
            [cell.imageView setImage:[UIImage imageNamed:@"defaultThumb.png"]];
        
        if ([cellTitle isEqualToString:GCLocalizedString(@"picker.record_video")])
            [cell.imageView setImage:[UIImage imageNamed:@"camera.png"]];
        if ([cellTitle isEqualToString:GCLocalizedString(@"picker.last_video_captured")])
            [cell.imageView setImage:[UIImage imageNamed:@"defaultThumb.png"]];
        [cell.titleLabel setText:cellTitle];
    }
    else
    {
        NSString *serviceName = [self.services objectAtIndex:indexPath.row];
        GCLoginType loginType = [[GCPhotoPickerConfiguration configuration] loginTypeForString:serviceName];
        NSString *loginTypeString = [[GCPhotoPickerConfiguration configuration] loginTypeString:loginType];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.png", serviceName];
        UIImage *temp = [UIImage imageNamed:imageName];
        [cell.imageView setImage:temp];
        
        NSString *cellTitle = [[serviceName capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];

        for (GCAccount *account in [[GCPhotoPickerConfiguration configuration] accounts]) {
            if([account.type isEqualToString:loginTypeString]){
                if (account.name) {
                    cellTitle = account.name;
                }
                else if (account.username){
                    cellTitle = account.username;
                }
            }
        }
        [cell.titleLabel setText:cellTitle];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && self.hasLocal){
        
        
        NSString *serviceName = [self.localFeatures objectAtIndex:indexPath.row];
        NSString *cellTitle = [[serviceName capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];

        if ([cellTitle isEqualToString:GCLocalizedString(@"picker.take_photo")]) {

            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:nil];

        }
        
        else if ([cellTitle isEqualToString:GCLocalizedString(@"picker.record_video")]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
            picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            picker.allowsEditing = YES;
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:nil];

        }
        
        else if ([cellTitle isEqualToString:GCLocalizedString(@"picker.last_video_captured")]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self getLatestPhoto:NO andVideo:YES];
        }
        
        else if ([cellTitle isEqualToString:GCLocalizedString(@"picker.choose_media")])
        {
          [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
          self.isItDevice = YES;
          NSDictionary *defaultLayouts = [[GCPhotoPickerConfiguration configuration] defaultLayouts];
          
          if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            if ([[defaultLayouts objectForKey:@"folder_layout"] isEqualToString:@"collectionView"]) {
              GCLegacyAlbumsCollectionViewController *albumVC = [[GCLegacyAlbumsCollectionViewController alloc] initWithCollectionViewLayout:[GCLegacyAlbumsCollectionViewController setupLayout]];
              [albumVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
              [albumVC setSuccessBlock:[self successBlock]];
              [albumVC setCancelBlock:[self cancelBlock]];
              [albumVC setIsItDevice:self.isItDevice];
              
              [self.navigationController pushViewController:albumVC animated:YES];
            } else {
              GCLegacyAlbumsTableViewController *daVC = [[GCLegacyAlbumsTableViewController alloc] init];
              [daVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
              [daVC setSuccessBlock:[self successBlock]];
              [daVC setCancelBlock:[self cancelBlock]];
              [daVC setIsItDevice:self.isItDevice];
              
              [self.navigationController pushViewController:daVC animated:YES];
            }
          }
          else {
            if ([[defaultLayouts objectForKey:@"folder_layout"] isEqualToString:@"collectionView"]) {
              GCAlbumsCollectionViewController *albumVC = [[GCAlbumsCollectionViewController alloc] initWithCollectionViewLayout:[GCAlbumsCollectionViewController setupLayout]];
              [albumVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
              [albumVC setSuccessBlock:[self successBlock]];
              [albumVC setCancelBlock:[self cancelBlock]];
              [albumVC setIsItDevice:self.isItDevice];
              
              [self.navigationController pushViewController:albumVC animated:YES];
            } else {
              GCAlbumsTableViewController *daVC = [[GCAlbumsTableViewController alloc] init];
              [daVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
              [daVC setSuccessBlock:[self successBlock]];
              [daVC setCancelBlock:[self cancelBlock]];
              [daVC setIsItDevice:self.isItDevice];
              
              [self.navigationController pushViewController:daVC animated:YES];
            }
          }
        }
        else if ([cellTitle isEqualToString:GCLocalizedString(@"picker.last_photo_taken")]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self getLatestPhoto:YES andVideo:NO];
        }
    }
    else {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.isItDevice = NO;
        
        NSString *serviceName = [self.services objectAtIndex:indexPath.row];
        GCLoginType loginType = [[GCPhotoPickerConfiguration configuration] loginTypeForString:serviceName];
        NSString *loginTypeString = [[GCPhotoPickerConfiguration configuration] loginTypeString:loginType];
        
        for (GCAccount *account in [[GCPhotoPickerConfiguration configuration] accounts]) {
            if(!([account.type isEqualToString:@"google"] || [account.type isEqualToString:@"microsoft_account"])) {
                if ([account.type isEqualToString:loginTypeString]) {
                    
                    GCAccountMediaViewController *amVC = [[GCAccountMediaViewController alloc] init];
                    [amVC setIsItDevice:self.isItDevice];
                    [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
                    [amVC setAccountID:account.shortcut];
                    [amVC setServiceName:serviceName];
                    [amVC setSuccessBlock:[self successBlock]];
                    [amVC setCancelBlock:[self cancelBlock]];
                    
                    [self.navigationController pushViewController:amVC animated:YES];
                    [self.tableView reloadData];
                    return;
                }
            }
        }
        
        [GCLoginView showLoginType:loginType success:^{
            [GCServiceAccount getProfileInfoWithSuccess:^(GCResponseStatus *responseStatus, NSArray *accounts) {
                GCAccount *account;
                for (GCAccount *acc in accounts) {
                    if ([loginTypeString isEqualToString:acc.type])
                        account = acc;
                    
                    [[GCPhotoPickerConfiguration configuration] addAccount:acc];
                }
                if (!account)
                    return;
                
                GCAccountMediaViewController *amVC = [[GCAccountMediaViewController alloc] init];
                [amVC setIsItDevice:self.isItDevice];
                [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
                [amVC setAccountID:account.shortcut];
                [amVC setServiceName:serviceName];
                [amVC setSuccessBlock:[self successBlock]];
                [amVC setCancelBlock:[self cancelBlock]];
                
                [self setLogoutNavBarButton:YES];
                [self.tableView reloadData];
                [self.navigationController pushViewController:amVC animated:YES];
            } failure:^(NSError *error) {
                GCLogError([error localizedDescription]);
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        } failure:^(NSError *error) {
            if ([error code] == 302) {
                GCClient *apiClient = [GCClient sharedClient];
                NSString *oldToken = [[[apiClient authorizationToken] componentsSeparatedByString:@" "] objectAtIndex:1];
                
                [apiClient clearAuthorizationHeader];
              [apiClient setAuthorizationHeaderWithToken:[NSString stringWithFormat:@"%@", [[error userInfo] objectForKey:@"new_token"]]];
                
                [GCServiceAccount getProfileInfoWithSuccess:^(GCResponseStatus *responseStatus, NSArray *accounts) {
                    GCAccount *account;
                    for (GCAccount *acc in accounts) {
                        if ([loginTypeString isEqualToString:acc.type])
                            account = acc;
                        
                        [[GCPhotoPickerConfiguration configuration] addAccount:acc];
                    }
                    if (!account)
                        return;
                    
                    GCAccountMediaViewController *amVC = [[GCAccountMediaViewController alloc] init];
                    [amVC setIsItDevice:self.isItDevice];
                    [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
                    [amVC setAccountID:account.shortcut];
                    [amVC setServiceName:serviceName];
                    [amVC setSuccessBlock:[self successBlock]];
                    [amVC setCancelBlock:[self cancelBlock]];
                    
                    [self setLogoutNavBarButton:YES];
                    [self.tableView reloadData];
                    [self.navigationController pushViewController:amVC animated:YES];
                    
                    [apiClient clearAuthorizationHeader];
                  [apiClient setAuthorizationHeaderWithToken:oldToken];
                    
                } failure:^(NSError *error) {
                    GCLogError([error localizedDescription]);
                  [apiClient setAuthorizationHeaderWithToken:oldToken];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];

            }
            else {
              GCLogError([error localizedDescription]);
              [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

#pragma mark - Custom Methods

- (void)getLatestPhoto:(BOOL)photo andVideo:(BOOL)video
{
  if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate all the photos and videos group by using ALAssetsGroupAll.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
      
      // Within the group enumeration block, filter to enumerate just photos.
      if (photo && video)
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
      else if (video)
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
      else
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
      
      if (group != nil && [group numberOfAssets] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have any photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
      }
      
      // Chooses the photo at the last index
      [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
        
        // The end of the enumeration is signaled by asset == nil.
        if (alAsset)
          [self successBlock]([NSDictionary infoFromALAsset:alAsset]);
      }];
    } failureBlock: ^(NSError *error) {
      // Typically you should handle an error more gracefully than this.
      NSLog(@"No groups to be enumerated.");
    }];
  } else {
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    
    if (photo && video)
      fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d", PHAssetMediaTypeVideo, PHAssetMediaTypeImage];
    else if (video)
      fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeVideo];
    else
      fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
      if (status == PHAuthorizationStatusAuthorized) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:fetchOptions];
        
        if (fetchResult.count == 0) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have any assets" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
          });
        }
        typeof(self) weakSelf = self;
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
        [window addSubview:HUD];
        [HUD show:YES];
        
        [[fetchResult objectAtIndex:0] requestMetadataWithBlock:^(NSDictionary *metadata) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            [weakSelf successBlock](metadata);
          });
        }];
      }
      else {
        dispatch_async(dispatch_get_main_queue(), ^{
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have authorization!\nGive this app permission to access your photo library in your settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
          return;
        });
      }
    }];
  }
}

- (void)setNavBarItems
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.logoutButton = [[UIBarButtonItem alloc] initWithTitle:GCLocalizedString(@"picker.logout") style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)setLogoutNavBarButton:(BOOL)toBeAdded
{
    if(toBeAdded == YES)
        [self.navigationItem setRightBarButtonItem:self.logoutButton];
    else
        [self.navigationItem setRightBarButtonItem:nil];
}

- (void)logout
{
    GCClient *apiClient = [GCClient sharedClient];
    [apiClient clearCookiesForChute];
    [apiClient clearAuthorizationHeader];
    [[GCPhotoPickerConfiguration configuration] removeAllAccounts];
    
    [self setLogoutNavBarButton:NO];
    [self.tableView reloadData];
}


- (void)cancel
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
    {
        [self.delegate imagePickerControllerDidCancel:(PhotoPickerViewController *)self.navigationController];
    }
}

#pragma mark - UIImagePicker Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancelBlock]();
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
    
    // Saving the video / // Get the new unique filename
        NSString *sourcePath = [[info objectForKey:UIImagePickerControllerMediaURL]relativePath];
        UISaveVideoAtPathToSavedPhotosAlbum(sourcePath,self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    else {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        [self successBlock](info);
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info
{
    [self successBlock](info);
}

#pragma mark - Callbacks

- (void (^)(id selectedItems))successBlock
{
    void (^successBlock)(id selectedItems) = ^(id selectedItems){
        if ([selectedItems isKindOfClass:[NSDictionary class]] && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
            [self.delegate imagePickerController:(PhotoPickerViewController *)self.navigationController didFinishPickingMediaWithInfo:selectedItems];
        }
        else if ([selectedItems isKindOfClass:[NSArray class]] && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingArrayOfMediaWithInfo:)]) {
            [self.delegate imagePickerController:(PhotoPickerViewController *)self.navigationController didFinishPickingArrayOfMediaWithInfo:selectedItems];
        }
    };
    return successBlock;
}

- (void (^)(void))cancelBlock
{
    void (^cancelBlock)(void) = ^{
        if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
        {
            [self.delegate imagePickerControllerDidCancel:(PhotoPickerViewController *)self.navigationController];
        }
    };
    return cancelBlock;
}

#pragma mark - Saving ALAsset

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
  NSLog(@"PATH:%@", videoPath);
    [self getLatestPhoto:NO andVideo:YES];
}

#pragma mark - Setters

- (void)setIsMultipleSelectionEnabled:(BOOL)isMultipleSelectionEnabled
{
    if(_isMultipleSelectionEnabled != isMultipleSelectionEnabled)
        _isMultipleSelectionEnabled = isMultipleSelectionEnabled;
}


@end
