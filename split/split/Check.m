//
//  Check.m
//  split
//
//  Created by Andrew Beinstein on 6/26/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "Check.h"

@interface Check()

@property (strong, nonatomic) NSDecimalNumberHandler *priceHandler;

@end

@implementation Check

// designated initalizer
- (Check *)initWithMealItems:(NSMutableArray *)mealItems people:(NSMutableArray *)people tax:(NSDecimalNumber *)tax tipPercentage:(float)tipPercentage
{
    self = [super init];
    if (self) {
        for (id item in mealItems){
            assert([item isKindOfClass:[MealItem class]]);
        }
        self.mealItems = mealItems;
        
        for (id item in people){
            assert([item isKindOfClass:[NSString class]]);
        }
        self.people = people;
        
        self.tax = tax;
        self.tipPercentage = tipPercentage;
        self.priceHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    }
    return self;
}

- (NSDictionary *)calculateAmounts
{
    NSMutableDictionary *amountsDict = [[NSMutableDictionary alloc] init];
    float totalFoodCost = 0.0;
    
    
    // First, add meal items
    for (MealItem *item in self.mealItems){
        float itemPrice = item.price;
        totalFoodCost += itemPrice;
        NSMutableArray *peopleWhoAteItem = item.peopleWhoAteItem;
        int numPeople = [peopleWhoAteItem count];
        
        for (NSString *name in peopleWhoAteItem) {
            float amountOwed = itemPrice / numPeople;
            
            NSNumber *currentAmountOwed = [amountsDict objectForKey:name];
            if (currentAmountOwed){
                amountsDict[name] = [NSNumber numberWithFloat:amountOwed + currentAmountOwed.floatValue];
            } else {
                amountsDict[name] = [NSNumber numberWithFloat:amountOwed];
            }
        }
    }
    
    
    // Then, add tax and tip information
    float totalTip = (totalFoodCost + self.tax.floatValue) * (self.tipPercentage / 100);
    
    NSMutableDictionary * newAmountsDict = [[NSMutableDictionary alloc] init];
    
    for (NSString *person in amountsDict){
        float foodCost = ((NSNumber *)amountsDict[person]).floatValue;
        float fractionCost = foodCost / totalFoodCost;
        float fractionTax = self.tax.floatValue * fractionCost;
        float fractionTip = totalTip * fractionCost;
        float totalOwed = foodCost + fractionTax + fractionTip;
        NSDecimalNumber *totalOwed_unformatted = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:totalOwed]decimalValue]];
        NSDecimalNumber *totalOwed_formatted = [totalOwed_unformatted decimalNumberByRoundingAccordingToBehavior:self.priceHandler];
        newAmountsDict[person] = totalOwed_formatted;
    }
    
    return [newAmountsDict copy];
}



@end
