//
//  NSDictionary+GCAccountAsset.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 8/30/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "NSDictionary+GCAccountAsset.h"
#import "GCAccountAssets.h"
#import "GCAsset.h"
#import "GCPhotoPickerConfiguration.h"
#import "GetChute.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSDictionary (GCAccountAsset)

+ (NSDictionary *)dictionaryFromGCAccountAssets:(GCAccountAssets *)asset
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:asset.id forKey:@"id"];
    [dictionary setValue:asset.caption forKey:@"caption"];
    [dictionary setValue:asset.thumbnail forKey:@"thumbnail"];
    [dictionary setValue:asset.videoUrl forKey:@"video_url"];
    [dictionary setValue:asset.imageUrl forKey:@"image_url"];
    if (asset.videoUrl != nil)
        [dictionary setValue:@"video" forKey:@"file_type"];

    [dictionary setValue:asset.dimensions forKey:@"dimensions"];
    
    return dictionary;
}

+ (NSDictionary *)infoFromGCAccountAsset:(GCAccountAssets *)asset
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    
    UIImage *image = [self loadImageWithURL:[NSURL URLWithString:[asset imageUrl]]];
    
    if(asset.videoUrl !=nil) {
        [mediaInfo setObject:(NSString *)kUTTypeVideo forKey:UIImagePickerControllerMediaType];
        [mediaInfo setObject:[NSURL URLWithString:[asset videoUrl]] forKey:UIImagePickerControllerReferenceURL];
    }
    else {
        [mediaInfo setObject:(NSString *)kUTTypeImage forKey:UIImagePickerControllerMediaType];
        [mediaInfo setObject:[NSURL URLWithString:[asset imageUrl]] forKey:UIImagePickerControllerReferenceURL];
    }
    
    if(image)
        [mediaInfo setObject:image forKey:UIImagePickerControllerOriginalImage];
    
    return mediaInfo;
    
}

+ (NSDictionary *)infoFromGCAsset:(GCAsset *)asset
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    UIImage *image = [self loadImageWithURL:[NSURL URLWithString:[asset thumbnail]]];
    
    if ([asset.type isEqualToString:@"video"]) {
        [mediaInfo setObject:(NSString *)kUTTypeVideo forKey:UIImagePickerControllerMediaType];
        [mediaInfo setObject:[NSURL URLWithString:[asset videoUrl]] forKey:UIImagePickerControllerReferenceURL];
    }
    else {
        [mediaInfo setObject:(NSString *)kUTTypeImage forKey:UIImagePickerControllerMediaType];
        [mediaInfo setObject:[NSURL URLWithString:[asset url]] forKey:UIImagePickerControllerReferenceURL];
    }
    
    if (image) {
        [mediaInfo setObject:image forKey:UIImagePickerControllerOriginalImage];
    }
    
    return mediaInfo;
}

+ (UIImage *)loadImageWithURL:(NSURL *)url
{
    if ([[GCPhotoPickerConfiguration configuration] loadImagesFromWeb] == NO){
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:20.0];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data && !error) {
        return [UIImage imageWithData:data];
    }
    else {
        GCLogWarning(@"Error loading image from web. %@", [error localizedDescription]);
        return nil;
    }
}

@end
