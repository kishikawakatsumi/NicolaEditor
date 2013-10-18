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
    self.selectedBackgroundView = selectedBackgroundView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
}

@end
