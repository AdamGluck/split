//
//  MealItem.m
//  split
//
//  Created by Andrew Beinstein on 6/26/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "MealItem.h"



@implementation MealItem


- (NSMutableArray *)peopleWhoAteItem
{
    if (!_peopleWhoAteItem) _peopleWhoAteItem = [[NSMutableArray alloc] init];
    return _peopleWhoAteItem;
}

- (void)addPerson:(NSString *)person
{
    [self.peopleWhoAteItem addObject:person];
}


@end
