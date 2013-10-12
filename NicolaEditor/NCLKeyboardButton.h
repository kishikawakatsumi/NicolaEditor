//
//  NCLKeyboardButton.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/07.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCLKeyboardButton : UIButton

@property (nonatomic) NSInteger index;

- (id)initWithIndex:(NSInteger)index;

@end
