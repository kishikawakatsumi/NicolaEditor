//
//  NCLNoteCell.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/18.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLNoteCell.h"

@implementation NCLNoteCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    selectedBackgroundView.image = [UIImage imageNamed:@"selected_background_view"];
    
    UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(15.0, 0.0, CGRectGetWidth(selectedBackgroundView.bounds) - 15.0, 1.0 / [[UIScreen mainScreen] scale])];
    separatorTop.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [selectedBackgroundView addSubview:separatorTop];
    
    UIView *separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(15.0, CGRectGetHeight(selectedBackgroundView.bounds), CGRectGetWidth(selectedBackgroundView.bounds) - 15.0, 1.0 / [[UIScreen mainScreen] scale])];
    separatorBottom.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [selectedBackgroundView addSubview:separatorBottom];
    
    self.selectedBackgroundView = selectedBackgroundView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
}

@end
