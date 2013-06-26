//
//  ImageOCR.m
//  split
//
//  Created by Andrew Beinstein on 6/25/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "ImageOCR.h"
#import "Tesseract.h"

@implementation ImageOCR

//@property (strong, nonatomic) UIImage *digitImage;
//@property (strong, nonatomic) NSNumber *digitNumber;

- (ImageOCR *)initWithImage:(UIImage *)digitImage
{
    self = [super init];
    if (self) {
        self.digitImage = digitImage;
    }
    return self;
}

- (NSDecimalNumber *)parseImage:(UIImage *)digitImage
{
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setVariableValue:@"0123456789." forKey:@"tessedit_char_whitelist"];
    [tesseract setImage:self.digitImage];
    BOOL isRecognized = [tesseract recognize];
    if (isRecognized) {
        NSString *recognizedText = [tesseract recognizedText];
        NSLog(@"%@", recognizedText);
//        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//        [f setNumberStyle:NSNumberFormatterDecimalStyle];
//        NSNumber *myNumber = [f numberFromString:recognizedText];
        NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:recognizedText];
//        NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:-2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];        
        if (price) {
            return price;
        } else {
            return nil;
        }
    }
    [tesseract clear];
    return nil;
}



// Lazy instantiation methods
- (UIImage *)digitImage
{
    if (!_digitImage) _digitImage = [[UIImage alloc] init];
    return _digitImage;
}

- (NSDecimalNumber *)digitNumber
{
    if (!_digitNumber) _digitNumber = [[NSDecimalNumber alloc] init];
    return _digitNumber;
}

- (NSNumber *)setDigitNumber
{
    _digitNumber = [self parseImage:self.digitImage];
    return _digitNumber;
}



@end
