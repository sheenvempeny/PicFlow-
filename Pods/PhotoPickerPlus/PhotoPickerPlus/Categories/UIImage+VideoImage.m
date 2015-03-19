//
//  UIImage+VideoImage.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 1/30/14.
//  Copyright (c) 2014 Chute. All rights reserved.
//

#import "UIImage+VideoImage.h"

@implementation UIImage (VideoImage)

+ (UIImage *)makeImageFromBottomImage:(UIImage *)bottomImage withFrame:(CGRect)bottomImageFrame andTopImage:(UIImage *)topImage withFrame:(CGRect)topImageFrame
{
  CGSize newSize = CGSizeMake(bottomImage.size.width, bottomImage.size.height);
  UIGraphicsBeginImageContext( newSize );
  
  // Use existing opacity as is
  [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
  
  // Apply supplied opacity if applicable
  [topImage drawInRect:topImageFrame blendMode:kCGBlendModeNormal alpha:1];
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();

  return newImage;
}

@end
