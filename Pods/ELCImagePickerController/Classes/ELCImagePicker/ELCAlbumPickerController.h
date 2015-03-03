//
//  AlbumPickerController.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAssetSelectionDelegate.h"
#import "ELCAssetPickerFilterDelegate.h"

typedef enum
{
    EPhoto = 0,
    EVideo = 1
}EMedia;



@interface ELCAlbumPickerController : UITableViewController <ELCAssetSelectionDelegate>

@property (nonatomic, assign) EMedia mediaType;
@property (nonatomic, weak) id<ELCAssetSelectionDelegate> parent;
@property (nonatomic, strong) NSMutableArray *assetGroups;

// optional, can be used to filter the assets displayed
@property (nonatomic, weak) id<ELCAssetPickerFilterDelegate> assetPickerFilterDelegate;

@end

