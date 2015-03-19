//
//  GCAssetsTableViewController.h
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 3/14/14.
//  Copyright (c) 2014 Chute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GCPhotoPickerViewController.h"
#import <Photos/Photos.h>

@interface GCAssetsTableViewController : UITableViewController

/**
 Collection (album) that holds the PHAssets
 */
@property (nonatomic, strong) PHCollection *collection;

/**
 Array of assets that need to be shown in collectionView.
 */
@property (nonatomic, strong) NSArray *assets;

/**
 String used to specify for which service it should ask for media data.
 */
@property (strong, nonatomic) NSString *serviceName;

/**
 The shortcut used to specify for which account it should ask for media data.
 */
@property (strong, nonatomic) NSString *accountID;

/**
 Number used to specify for which album it should ask for media data.
 */
@property (strong, nonatomic) NSNumber *albumID;


/**
 BOOL value with which is determined if the user can select multiple assets (YES) or not (NO).
 */
@property (nonatomic) BOOL isMultipleSelectionEnabled;

/**
 BOOL value with which is determined if the user is looking for an asset from the local-source (YES) or from online source (NO)
 */
@property (nonatomic) BOOL isItDevice;


/**
 A block that gets called when user has selected asset(s).
 */
@property (readwrite, copy) void (^successBlock)(id selectedItems);

/**
 A block that gets called when user cancels photo picking.
 */
@property (readwrite, copy) void (^cancelBlock)(void);

///----------------------------------
/// @name Setting NavigationBar items
///----------------------------------

/**
 Sets cancel button in the right corner of NavigationBar.
 
 @return UIBarButtonItem
 */
- (UIBarButtonItem *)cancelButton;

/**
 Sets cancel and done buttons in right corner of NavigationBar.
 
 @return NSArray of UIBarButtonItem objects.
 */
- (NSArray *)doneAndCancelButtons;

@end
