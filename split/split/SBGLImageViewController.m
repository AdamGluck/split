//
//  SBGLViewController.m
//  split
//
//  Created by Adam Gluck on 6/25/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "SBGLImageViewController.h"

@interface SBGLImageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>{
    BOOL highlighted;
}

@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) NSMutableDictionary * keyPriceValuePeopleWhoOweIt;
@property (strong, nonatomic) UIView * activeHighlight;

@end

@implementation SBGLImageViewController

@synthesize names = _names;
@synthesize keyPriceValuePeopleWhoOweIt = _keyPriceValuePeopleWhoOweIt;

-(NSArray *) names {
    if (!_names)
        _names = [[NSArray alloc] init];
    
    return _names;
}

-(NSMutableDictionary *) keyPriceValuePeopleWhoOweIt{
    if (!_keyPriceValuePeopleWhoOweIt)
        _keyPriceValuePeopleWhoOweIt = [[NSMutableDictionary alloc] init];
    
    return _keyPriceValuePeopleWhoOweIt;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.checkImageView.image = [UIImage imageNamed:@"robust.jpg"];
    highlighted = NO;
}

-(void) configureTapGestureRecognizer{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

/*
-(void) presentImagePicker{
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;
    BOOL ok = [UIImagePickerController isSourceTypeAvailable:type];
    if (!ok){
        UIAlertView * typeNotAvailable = [[UIAlertView alloc] initWithTitle:@"Camera Not Working" message:@"For some reason your camera is not working, try again or have your friend download the app." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [typeNotAvailable show];
    } else {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.sourceType = type;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:type];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage * im = info[UIImagePickerControllerOriginalImage];
    
    if (im){
        self.checkImageView.image = im;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
 */

#pragma mark - UIGestureRecognizer

-(void) viewTapped: (UITapGestureRecognizer *) recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        if (!highlighted){
            CGPoint location = [recognizer locationInView:self.view];
            [self createHighlightAtLocation:location];
        }
        
        if (highlighted){
            
        }
        
        
    }
}

-(void) createHighlightAtLocation: (CGPoint) location{
    self.activeHighlight = [[UIView alloc] initWithFrame:CGRectMake(location.x, location.y, 30, 10)];
    UIColor * highlighter = [UIColor colorWithRed:250.0/255.0 green:245.0/255.0 blue:151.0/255.0 alpha:.6];
    self.activeHighlight.backgroundColor = highlighter;
    highlighted = YES;
}

-(void) grabImageInHighlightedView{
    
    if (highlighted){
        UIImage * checkImage = self.checkImageView.image;
    }
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
