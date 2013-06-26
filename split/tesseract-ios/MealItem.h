//
//  MealItem.h
//  split
//
//  Created by Andrew Beinstein on 6/26/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Price.h"

@interface MealItem : NSObject

@property (nonatomic) float price;
@property (strong, nonatomic) NSMutableArray *peopleWhoAteItem; // will assume array of strings for now

- (void)addPerson:(NSString *)person;

@end