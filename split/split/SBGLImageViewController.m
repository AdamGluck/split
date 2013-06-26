//
//  SBGLViewController.m
//  split
//
//  Created by Adam Gluck on 6/25/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "SBGLImageViewController.h"

@interface SBGLImageViewController ()

@end

@implementation SBGLImageViewController

@synthesize names = _names;

-(NSArray *) names {
    if (!_names)
        _names = [[NSArray alloc] init];
    
    return _names;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@", self.names);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
