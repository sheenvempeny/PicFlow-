//
//  PhotoCell.m
//  GCAPIv2TestApp
//
//  Created by Chute Corporation on 7/25/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCPhotoCell.h"

@implementation GCPhotoCell

@synthesize imageView;
@synthesize overlayView;
@synthesize videoView;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.duration = [[UILabel alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 15, self.contentView.frame.size.width - 3, 13)];
    self.duration.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.duration.textColor = [UIColor whiteColor];
    self.duration.textAlignment = NSTextAlignmentRight;
    self.duration.shadowColor = [UIColor blackColor];
    self.duration.shadowOffset = CGSizeMake(1, 0);
    self.imageView = [[UIImageView alloc] initWithFrame:[self.contentView frame]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.overlayView = [[UIImageView alloc] initWithFrame:[self.contentView frame]];
    self.videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 19, 20, 20)];
    [self.overlayView setImage:[UIImage imageNamed:@"overlay.png"]];
    [self.contentView insertSubview:self.imageView atIndex:1];
    [self.contentView insertSubview:self.videoView atIndex:2];
    [self.contentView insertSubview:self.duration atIndex:3];
    [self.contentView insertSubview:self.overlayView atIndex:4];
    [self.overlayView setHidden:YES];
  }
  return self;
}

- (void)setSelected:(BOOL)selected
{
  [super setSelected:selected];
  [self.overlayView setHidden:!selected];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
