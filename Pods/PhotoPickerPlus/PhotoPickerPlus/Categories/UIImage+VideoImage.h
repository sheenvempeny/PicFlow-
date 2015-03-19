//
//  UIImage+VideoImage.h
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 1/30/14.
//  Copyright (c) 2014 Chute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VideoImage)

+ (UIImage *)makeImageFromBottomImage:(UIImage *)bottomImage withFrame:(CGRect)bottomImageFrame andTopImage:(UIImage *)topImage withFrame:(CGRect)topImageFrame;


@end
