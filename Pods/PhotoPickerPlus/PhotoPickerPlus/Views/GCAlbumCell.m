//
//  GCAlbumCell.m
//  PhotoPickerPlus-SampleApp
//
//  Created by ARANEA on 3/17/14.
//  Copyright (c) 2014 Chute. All rights reserved.
//

#import "GCAlbumCell.h"

@implementation GCAlbumCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.imageView setImage:[UIImage imageNamed:@"album_default"]];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.contentView.frame.size.height - 22, self.contentView.frame.size.width - 10, 21)];
        [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        
    }
    return self;
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
