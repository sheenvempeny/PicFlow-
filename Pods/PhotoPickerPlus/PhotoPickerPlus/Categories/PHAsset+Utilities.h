//
//  PHAsset+Utilities.h
//  PhotoPickerPlus-SampleApp
//
//  Created by Aranea | Oliver Dimitrov on 2/13/15.
//  Copyright (c) 2015 Chute. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface PHAsset (Utilities)

+ (PHFetchOptions *)fetchOptions;
- (void)requestMetadataWithBlock:(void(^)(NSDictionary *metadata))block;
- (NSString *)getDuration;

@end
