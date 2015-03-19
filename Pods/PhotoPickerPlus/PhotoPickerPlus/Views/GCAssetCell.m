//
//  AssetCell.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 3/17/14.
//  Copyright (c) 2014 Chute. All rights reserved.
//

#import "GCAssetCell.h"

#define IS_IOS7 [[UIDevice currentDevice].systemVersion hasPrefix:@"7"]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface GCAssetCell ()

@property (nonatomic, strong) UIImageView   *overlayView;

@end

@implementation GCAssetCell

@synthesize overlayView, imageView, titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
      self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 55, 55)];
      self.videoView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
      self.duration = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 52, 13)];
      [self setSeparatorInset:UIEdgeInsetsMake(0, 85, 0, 0)];
    } else {
      self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
      self.videoView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 20, 20)];
      self.duration = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 52, 13)];
    }
    
    self.duration.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.duration.textAlignment = NSTextAlignmentRight;
    self.duration.textColor = [UIColor whiteColor];
    self.overlayView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    [self.overlayView setImage:[UIImage imageNamed:@"overlay.png"]];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + 15, 8, self.contentView.bounds.size.width - (self.imageView.frame.origin.x + self.imageView.frame.size.width) - 23, 40)];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [self.titleLabel setNumberOfLines:2];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView insertSubview:self.imageView atIndex:1];
    [self.contentView insertSubview:self.videoView atIndex:2];
    [self.contentView insertSubview:self.duration atIndex:3];
    [self.contentView insertSubview:self.overlayView atIndex:4];
    [self.contentView addSubview:self.titleLabel];
    [self.overlayView setHidden:YES];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  [self.overlayView setHidden:!selected];
}

@end
