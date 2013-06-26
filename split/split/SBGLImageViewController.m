//
//  SBGLViewController.m
//  split
//
//  Created by Adam Gluck on 6/25/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "SBGLImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageOCR.h"

@interface SBGLImageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>{
    BOOL highlighted;
    CGPoint highlightStart;
}


@property (strong, nonatomic) IBOutlet UITextField *amountField;
@property (strong, nonatomic) IBOutlet UITableView *nameTable;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) NSMutableDictionary * keyPriceValuePeopleWhoOweIt;
@property (strong, nonatomic) UIImageView * activeHighlight;

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
    NSLog(@"view loaded with %@", self.names);
    self.checkImageView.image = [UIImage imageNamed:@"robust.jpg"];
    [self configureTapGestureRecognizer];
    [self configurePanGestureRecognizer];
    highlighted = NO;
}

-(void) configureTapGestureRecognizer{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.delegate = self;
    [self.checkImageView addGestureRecognizer:tap];
}

-(void) configurePanGestureRecognizer{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanned:)];
    pan.delegate = self;
    [self.checkImageView addGestureRecognizer:pan];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]){
        highlightStart = [touch locationInView:self.checkImageView];
    }
    
    return YES;
}

-(void) viewPanned: (UIPanGestureRecognizer *) recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint location = [recognizer locationInView:self.checkImageView];
        CGSize highlightSize = CGSizeMake(location.x - highlightStart.x, location.y - highlightStart.y);
        
        [self createHighlightAtLocation:highlightStart withSize:highlightSize];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        self.nameTable.hidden = NO;
        [self.nameTable reloadData];
        highlighted = YES;
    }
    
    
}
-(void) viewTapped: (UITapGestureRecognizer *) recognizer{
    
    if (highlighted){
        [self dismissTableView];
    }
        
}

-(void) createHighlightAtLocation: (CGPoint) location withSize: (CGSize) size{
    
    if (_activeHighlight){
        [_activeHighlight removeFromSuperview];
        _activeHighlight = nil;
    }
    
    self.activeHighlight = [[UIImageView alloc] initWithFrame:CGRectMake(location.x, location.y, 0, 20)];
    
    UIColor * highlighter = [UIColor colorWithRed:250.0/255.0 green:245.0/255.0 blue:151.0/255.0 alpha:.6];
    self.activeHighlight.backgroundColor = highlighter;
    
    [self.view insertSubview:self.activeHighlight aboveSubview:self.checkImageView];
    
    self.activeHighlight.frame = CGRectMake(self.activeHighlight.frame.origin.x, self.activeHighlight.frame.origin.y, size.width, size.height);

}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section == 0)
        return 1;
    else
        return [self.names count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"nameCell";

    if (indexPath.section == 0){
        CellIdentifier = @"amount";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0 && highlighted){
        UIImage * image = [self grabImageInHighlightedView];
        if (image){
            NSLog(@"image");
            ImageOCR * parsedImage = [[ImageOCR alloc] initWithImage:image];
            self.amountField = (UITextField *)
            [cell viewWithTag:1];
            self.amountField.text = [NSString stringWithFormat:@"%@", parsedImage.digitNumber];
        }
    }
    
    if (indexPath.section == 1){
        cell.textLabel.text = self.names[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableView utility functions

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

-(UIImage *) grabImageInHighlightedView{
    
    NSLog(@"grab image called");
    UIImage * digitImage = nil;
    
    if (self.activeHighlight){
        NSLog(@"no active highlight");
        float scale = [[UIScreen mainScreen] scale];
        UIImage * scaledImage = [[self class] imageWithImage:self.checkImageView.image scaledToSize:self.checkImageView.frame.size];
        
        CGImageRef image = CGImageCreateWithImageInRect(scaledImage.CGImage, CGRectMake(self.activeHighlight.frame.origin.x * scale, self.activeHighlight.frame.origin.y * scale, self.activeHighlight.frame.size.width * scale, self.activeHighlight.frame.size.height * scale));
        
        digitImage = [UIImage imageWithCGImage:image];

        CGImageRelease(image);
        
    }
    

    
    return digitImage;
    
}



-(void) dismissTableView{
    self.nameTable.hidden = YES;
    [self.activeHighlight removeFromSuperview];
    highlighted = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
