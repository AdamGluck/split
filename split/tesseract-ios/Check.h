//
//  Check.h
//  split
//
//  Created by Andrew Beinstein on 6/26/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MealItem.h"

@interface Check : NSObject

@property (strong, nonatomic) NSMutableArray *mealItems; // array of MealItem objects
@property (strong, nonatomic) NSMutableArray *people; // array of NSString's
@property (strong, nonatomic) NSDecimalNumber *tax; // total tax on the check
@property (nonatomic) float tipPercentage; // Percentage value (not fraction!)

// Returns a dictionary indicating how much everybody owes
// Key: NSString representing a person name
// Value: NSDecimalNumber representing the amount that person owes
- (NSDictionary *)calculateAmounts;

- (Check *)initWithMealItems:(NSMutableArray *)mealItems people:(NSMutableArray *)people tax:(NSDecimalNumber *)tax tipPercentage:(float)tipPercentage;

@end
