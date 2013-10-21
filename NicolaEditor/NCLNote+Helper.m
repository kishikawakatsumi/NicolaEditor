//
//  NCLNote+Helper.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLNote+Helper.h"
#import "NSString+Helper.h"
#import <NLCoreData/NLCoreData.h>

@implementation NCLNote (Helper)

- (void)awakeFromInsert
{
    self.identifier = [NSString UUIDString];
    self.createdAt = [NSDate date];
    self.updatedAt = self.createdAt;
    [super awakeFromInsert];
}

- (void)willSave
{
    if (self.isUpdated) {
         [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
    }
    [super willSave];
}

+ (NCLNote *)insertNewNoteWithContent:(NSString *)content
{
    NCLNote *note = [self insertInContext:[NSManagedObjectContext mainContext]];
    
    __block NSString *title = nil;
    [content enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        title = line;
        *stop = YES;
    }];
    
    note.title = title;
    note.content = content;
    
    [note.managedObjectContext saveNested];
    
    return note;
}

@end
