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

@synthesize digitNumber = _digitNumber;

- (ImageOCR *)initWithImage:(UIImage *)digitImage
{
    self = [super init];
    if (self) {
        self.digitImage = digitImage;
    }
    return self;
}

/*
Takes an image, and parses it using the Tesseract OCR library.
Assumes the image encodes one price. 
*/
- (NSDecimalNumber *)parseImage:(UIImage *)digitImage
{
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setVariableValue:@"0123456789." forKey:@"tessedit_char_whitelist"];
    // POSSIBLE ENHANCEMENT
    // Set a variable value such that tesseract knows to only expect one line of text. 
    [tesseract setImage:self.digitImage];
    BOOL isRecognized = [tesseract recognize];
    if (isRecognized) {
        NSString *recognizedText = [tesseract recognizedText];
        NSLog(@"%@", recognizedText);
        NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:recognizedText];
    
        if (price) {
            NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
            
            return [price decimalNumberByRoundingAccordingToBehavior:handler ];
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
    if (!_digitNumber) _digitNumber = [self parseImage:self.digitImage];

    return _digitNumber;
}





@end
