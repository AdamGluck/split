//
//  Price.h
//  split
//
//  Created by Andrew Beinstein on 6/26/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Price : NSDecimalNumber

- (Price *)initWithNumber:(NSNumber *)number;
- (NSString *)description;


- (Price *)divideByPrice:(Price *)price;


@end
