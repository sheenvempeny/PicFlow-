//
//  NSDictionary+ALAsset.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 8/6/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "NSDictionary+ALAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>


@implementation NSDictionary (ALAsset)

+ (NSDictionary *)infoFromALAsset:(ALAsset *)asset
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto)
        [mediaInfo setObject:(NSString *)kUTTypeImage forKey:UIImagePickerControllerMediaType];

    else if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo)
        [mediaInfo setObject:(NSString *)kUTTypeVideo forKey:UIImagePickerControllerMediaType];
        
    [mediaInfo setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:UIImagePickerControllerOriginalImage];
    [mediaInfo setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];

    return mediaInfo;
}

@end
