//
//  NCLTextViewController.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCLNote;

@interface NCLTextViewController : UIViewController

@property (nonatomic) NCLNote *note;

@end

@interface NCLTextView : UITextView

@end
