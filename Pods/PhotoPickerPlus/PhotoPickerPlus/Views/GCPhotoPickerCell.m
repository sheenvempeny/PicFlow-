//
//  PhotoPickerCell.m
//  GCAPIv2TestApp
//
//  Created by Chute Corporation on 7/24/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCPhotoPickerCell.h"

@implementation GCPhotoPickerCell
@synthesize titleLabel, imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 235, 25)];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.titleLabel];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 44, 44)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, 65, 0, 0)];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

@end
