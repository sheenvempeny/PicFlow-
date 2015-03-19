//
//  PHAsset+Utilities.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aranea | Oliver Dimitrov on 2/13/15.
//  Copyright (c) 2015 Chute. All rights reserved.
//

#import "PHAsset+Utilities.h"
#import "GCPhotoPickerConfiguration.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@implementation PHAsset (Utilities)

+ (PHFetchOptions *)fetchOptions
{
  PHFetchOptions *fetchOptions = [PHFetchOptions new];
  
  NSString *mediaTypesAvailable = [[GCPhotoPickerConfiguration configuration] mediaTypesAvailable];
  
  if ([mediaTypesAvailable isEqualToString:@"Photos"])
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
  if ([mediaTypesAvailable isEqualToString:@"Videos"])
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeVideo];
  if ([mediaTypesAvailable isEqualToString:@"All Media"])
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d", PHAssetMediaTypeVideo, PHAssetMediaTypeImage];
  
  return fetchOptions;
}

- (void)requestMetadataWithBlock:(void (^)(NSDictionary *))block
{
  NSMutableDictionary *metadata = [NSMutableDictionary new];
  
  if(self.mediaType == PHAssetMediaTypeImage) {
    [metadata setObject:(NSString *)kUTTypeImage forKey:UIImagePickerControllerMediaType];

    PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc] init];
    editOptions.networkAccessAllowed = YES;
    [self requestContentEditingInputWithOptions:editOptions completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
      [metadata setObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:contentEditingInput.fullSizeImageURL]] forKey:UIImagePickerControllerOriginalImage];
      [metadata setObject:contentEditingInput.fullSizeImageURL forKey:UIImagePickerControllerReferenceURL];
      block(metadata);
    }];
  } else if (self.mediaType == PHAssetMediaTypeVideo) {
    [metadata setObject:(NSString *)kUTTypeMovie forKey:UIImagePickerControllerMediaType];
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        [metadata setObject:thumb forKey:UIImagePickerControllerOriginalImage];
        
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        [metadata setObject:urlAsset.URL forKey:UIImagePickerControllerReferenceURL];

      block(metadata);
    }];
  }
}

- (NSString *)getDuration
{
  NSInteger duration = round(self.duration);

  int min = duration/60;
  int seconds = duration - 60*min;
  
  return [NSString stringWithFormat:@"%i:%02i", min, seconds];
}

@end
