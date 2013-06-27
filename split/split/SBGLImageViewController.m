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
#import "MealItem.h"
#import "Check.h"
#import "SBGLPresentDataViewController.h"

@interface SBGLImageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>{
    BOOL highlighted;
    BOOL tax;
    CGPoint highlightStart;
}


@property (strong, nonatomic) IBOutlet UITextField *amountField;
@property (strong, nonatomic) IBOutlet UITableView *nameTable;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) NSMutableArray * items; // each item is a dictionary key = price, value = array of people
@property (strong, nonatomic) NSMutableArray * selectedPeople;
@property (strong, nonatomic) UIImageView * activeHighlight;
@property (strong, nonatomic) NSDecimalNumber * taxAmount;

@end

@implementation SBGLImageViewController

@synthesize names = _names;
@synthesize items = _items;
@synthesize selectedPeople = _selectedPeople;

-(NSArray *) names {
    if (!_names)
        _names = [[NSArray alloc] init];
    
    return _names;
}

-(NSMutableArray *) items {
    if (!_items)
        _items = [[NSMutableArray alloc] init];
    
    return _items;
}

-(NSMutableArray *) selectedPeople{
    if (!_selectedPeople)
        _selectedPeople = [[NSMutableArray alloc] init];
    
    return _selectedPeople;
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
    
    self.nameTable.backgroundColor = [UIColor clearColor];
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.nameTable.frame.size.width, self.view.frame.size.height)];
    footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6f];
    self.nameTable.tableFooterView = footerView;

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
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 1 && indexPath.section == 0 && cell.accessoryView.hidden){
        
        tax = YES;
        cell.accessoryView.hidden = NO;
        
    } else if (cell.accessoryView.hidden && indexPath.section != 0){
        
        // this works because the rows are indexed by 
        [self.selectedPeople addObject: self.names[indexPath.row]];
        
        if (cell.accessoryView.hidden){
            cell.accessoryView.hidden = NO;
        } else {
            UIImageView *checkmark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
            checkmark.image = [UIImage imageNamed:@"check-mark-in-white-md.png"];
            cell.accessoryView = checkmark;
        }
        
    } else {
        [self.selectedPeople removeObject: self.names[indexPath.row]];
        cell.accessoryView.hidden = YES;

        if (tax) tax = NO;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
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
        return 2;
    else
        return [self.names count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"nameCell";

    if (indexPath.section == 0 && indexPath.row == 0){
        CellIdentifier = @"amount";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView * backGroundView = [[UIImageView alloc] initWithFrame:cell.frame];
    backGroundView.backgroundColor = [UIColor blackColor];
    backGroundView.alpha = .6f;
    cell.backgroundView = backGroundView;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0 && indexPath.row == 0 && highlighted){
        UIImage * image = [self grabImageInHighlightedView];
        
        if (image){
            ImageOCR * parsedImage = [[ImageOCR alloc] initWithImage:image];
            self.amountField = (UITextField *)[cell viewWithTag:1];
            self.amountField.text = [NSString stringWithFormat:@"%@", parsedImage.digitNumber];
        }
    } else {
        UIImageView *checkmark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        checkmark.image = [UIImage imageNamed:@"check-mark-in-white-md.png"];
        cell.accessoryView = checkmark;
        
        if (indexPath.section == 0 && indexPath.row == 1)
            cell.textLabel.text = @"Tax";
        else if (indexPath.section == 1)
            cell.textLabel.text = self.names[indexPath.row];
        
        cell.accessoryView.hidden = YES;

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
    
    UIImage * digitImage = nil;
    
    if (self.activeHighlight){
        float scale = [[UIScreen mainScreen] scale];
        UIImage * scaledImage = [[self class] imageWithImage:self.checkImageView.image scaledToSize:self.checkImageView.frame.size];
        
        CGImageRef image = CGImageCreateWithImageInRect(scaledImage.CGImage, CGRectMake(self.activeHighlight.frame.origin.x * scale, self.activeHighlight.frame.origin.y * scale, self.activeHighlight.frame.size.width * scale, self.activeHighlight.frame.size.height * scale));
        
        digitImage = [UIImage imageWithCGImage:image];

        CGImageRelease(image);
        
    }
    
    return digitImage;
    
}



-(void) dismissTableView{
    
    // grab relevent data and add it to self.items which will be sent to model
    if ([self.selectedPeople count]){
        NSString * priceForItem = self.amountField.text;
        NSMutableArray * selectedPeopleForItem = [self.selectedPeople copy];
        MealItem * item = [[MealItem alloc] init];
        item.price = [priceForItem floatValue];
        item.peopleWhoAteItem = selectedPeopleForItem;
        
        NSLog(@"item.price = %f, item.peopleWhoAteItem = %@", item.price, item.peopleWhoAteItem);
        [self.items addObject:item];
        
        NSLog(@"items %@", self.items);
        
    } else if (tax){
        self.taxAmount = [NSDecimalNumber decimalNumberWithString:self.amountField.text];
        tax = NO;
    }
    
    // clear out self.selectedPeople so that we do not keep adding to it
    [self.selectedPeople removeAllObjects];
    
    // clean up table
    self.nameTable.hidden = YES;
    [self.activeHighlight removeFromSuperview];
    highlighted = NO;
    
    [self.nameTable reloadData];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"present"]){
        
        Check * check = [[Check alloc] initWithMealItems:self.items people:[self.names mutableCopy] tax:self.taxAmount tipPercentage:20.0];

        NSDictionary * amounts = [[check calculateAmounts] mutableCopy];
        
        NSLog(@"amounts = %@", amounts);
        ((SBGLPresentDataViewController*) segue.destinationViewController).presentedData = [[NSMutableDictionary alloc] initWithDictionary:amounts];
        
        NSLog(@"data before segue %@", ((SBGLPresentDataViewController *) segue.destinationViewController).presentedData);
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
