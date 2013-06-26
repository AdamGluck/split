//
//  ImageOCR.h
//  split
//
//  Created by Andrew Beinstein on 6/25/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageOCR : NSObject

@property (strong, nonatomic) UIImage *digitImage;
@property (strong, readonly, nonatomic) NSDecimalNumber *digitNumber;

- (ImageOCR *)initWithImage:(UIImage *)digitImage;

@end
