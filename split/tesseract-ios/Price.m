//
//  Price.m
//  split
//
//  Created by Andrew Beinstein on 6/26/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "Price.h"
@interface Price()

@property (strong, nonatomic) NSDecimalNumberHandler *defaultHandler;

@end

@implementation Price

@synthesize defaultHandler = _defaultHandler;


// designated initializer
- (Price *)initWithNumber:(NSNumber *)number
{
    self = [super init];
    if (self){
        self.defaultHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                 scale:2
                                                                                      raiseOnExactness:NO
                                                                                       raiseOnOverflow:NO
                                                                                      raiseOnUnderflow:NO
                                                                                   raiseOnDivideByZero:NO];
        self = (Price *)[self decimalNumberByRoundingAccordingToBehavior:self.defaultHandler];
    }
    return self;
}

- (Price *)divideByPrice:(Price *)price
{
    NSDecimalNumber *price_dec = [self decimalNumberByDividingBy:price withBehavior:self.defaultHandler];
    return [[Price alloc] initWithDecimalNumber:price_dec];
}

- (NSString *)description
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *price_description = [formatter stringFromNumber:self];
    return price_description;
}

@end
