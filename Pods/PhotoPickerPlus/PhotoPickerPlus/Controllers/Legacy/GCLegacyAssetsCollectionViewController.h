//
//  GCLegacyAssetsCollectionViewController.h
//  PhotoPickerPlus-SampleApp
//
//  Created by Aranea | Oliver Dimitrov on 2/11/15.
//  Copyright (c) 2015 Chute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GCPhotoPickerViewController.h"

@interface GCLegacyAssetsCollectionViewController : UICollectionViewController

/**
 ALAssetsGroup used to enumerate assets from local-source.
 */
@property (nonatomic, strong) ALAssetsGroup *assetGroup;


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

///------------------------------------
/// @name Setting CollectionView layout
///------------------------------------

/**
 Instance method for setting collectionView layout when initializing new CollectionViewController.
 
 @return UICollectionViewFlowLayout that is used for initializing new CollectionViewController.
 */
+ (UICollectionViewFlowLayout *)setupLayout;

@end
