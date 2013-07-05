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
    BOOL shouldReloadForNewItem; // set this before reloading the tableview if you want the check marks to go away
    CGPoint highlightStart;
}


@property (strong, nonatomic) IBOutlet UITextField *amountField;
@property (strong, nonatomic) IBOutlet UITableView *nameTable;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) NSMutableArray * items; // each item is a dictionary key = price, value = array of people
@property (strong, nonatomic) NSMutableArray * selectedPeople;
@property (strong, nonatomic) UIImageView * activeHighlight;
@property (strong, nonatomic) NSDecimalNumber * taxAmount;
@property (strong, nonatomic) NSDictionary * currentAmountOwedPerPerson;
@property (strong, nonatomic) NSString * currentAmount;

@end

@implementation SBGLImageViewController

@synthesize names = _names;
@synthesize items = _items;
@synthesize selectedPeople = _selectedPeople;
@synthesize currentAmountOwedPerPerson = _currentAmountOwedPerPerson;

-(NSDictionary *) currentAmountOwedPerPerson{
    if (!_currentAmountOwedPerPerson)
        _currentAmountOwedPerPerson = [[NSDictionary alloc] init];
    
    return _currentAmountOwedPerPerson;
}

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
    
    self.checkImageView.image = [UIImage imageNamed:@"robust.jpg"];
    [self configureTapGestureRecognizer];
    [self configurePanGestureRecognizer];
    [self configureTableView];
    highlighted = NO;

}

-(void)viewWillAppear:(BOOL)animated{
    shouldReloadForNewItem = YES;
}

-(void) configureTableView{
    self.nameTable.backgroundColor = [UIColor clearColor];
    
    CGFloat offset =  (float)([self.names count] + 1) * 44;
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.nameTable.frame.size.width, self.view.frame.size.height - offset)];
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

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]){
        highlightStart = [touch locationInView:self.checkImageView];
    }
    
    return YES;
}

-(void) viewPanned: (UIPanGestureRecognizer *) recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        if (highlighted){
            [self grabInformationFromTableViewAndClearIt];
        }
    }
    
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
        [self grabInformationFromTableViewAndClearIt];
    }
    
    [self.view endEditing:YES];
    
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
    
    
    if (indexPath.row == 1 && indexPath.section == 0 && !tax){
        tax = YES;
        
    } else if (cell.accessoryView.hidden && indexPath.section != 0){
        
        [self.selectedPeople addObject: self.names[indexPath.row]];
        
    } else if (indexPath.row == 1 && indexPath.section == 0 && tax){
        
        tax = NO;
        
    } else {
        
        [self.selectedPeople removeObject: self.names[indexPath.row]];
        
    }
    
    
    NSMutableArray *tempItems = [self.items mutableCopy];
    
    if (([self.selectedPeople count] || tax) && [self numberFromHighlightedView].intValue){
        
        MealItem *tempItem = [[MealItem alloc] init];
        tempItem.price = [self numberFromHighlightedView].floatValue;
        tempItem.peopleWhoAteItem = [self.selectedPeople copy];
            
        [tempItems addObject: tempItem];
        
    } else if (tax){
        self.taxAmount = [self numberFromHighlightedView];
    }
    
    Check * check = [[Check alloc] initWithMealItems:tempItems people:[self.names mutableCopy] tax:self.taxAmount tipPercentage:0.0];
    self.currentAmountOwedPerPerson = [check calculateAmounts];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.nameTable reloadData];
    
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
    cell.accessoryView.hidden = YES;
    
    // the code below should probably be restructured
    if (indexPath.section == 0 && indexPath.row == 0){
        
        [self configureAmountFieldCell:cell];
        
    } else {
        // this is in all the rest beside the first row
        UIImageView *checkmark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        checkmark.image = [UIImage imageNamed:@"check-mark-in-white-md.png"];
        cell.accessoryView = checkmark;
        
        //this is the location of the "Tax Field"
        if (indexPath.section == 0 && indexPath.row == 1){
            
            cell = [self configureCellForTaxRow:cell];

        } else if (indexPath.section == 1){
            
            cell = [self configureCellForNameRow:cell atIndexPath:indexPath];
            
        }
        

    }
    
    return cell;
}

-(void) configureAmountFieldCell:(UITableViewCell *) cell{
    UIImage * image = [self grabImageInHighlightedView];
    
    if (image){
        ImageOCR * parsedImage = [[ImageOCR alloc] initWithImage:image];
        self.amountField = (UITextField *)[cell viewWithTag:1];
        self.amountField.text = [NSString stringWithFormat:@"$%.02f", parsedImage.digitNumber.floatValue];
    }
}

-(UITableViewCell *) configureCellForTaxRow: (UITableViewCell *) cell{
    cell.textLabel.text = @"Tax";
    
    if (self.taxAmount)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+$%.02f", self.taxAmount.floatValue];
    else
        cell.detailTextLabel.text = @"$0.00";
    
    cell.accessoryView.hidden = YES;
    
    return cell;
}

-(UITableViewCell *) configureCellForNameRow: (UITableViewCell *) cell atIndexPath: (NSIndexPath *) indexPath {
    
    NSString * name = self.names[indexPath.row];
    cell.textLabel.text = name;
    
    if (self.currentAmountOwedPerPerson[name])
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", ((NSDecimalNumber *) self.currentAmountOwedPerPerson[name]).floatValue];
    else
        cell.detailTextLabel.text = @"$0.00";
    
    if ([self shouldSetAccessoryViewForName:name]) {
        cell.accessoryView.hidden = NO;
    } else {
        cell.accessoryView.hidden = YES;
    }
    
    return cell;
}

-(BOOL) shouldSetAccessoryViewForName: (NSString *) name{
    
    for (NSString * selectedName in self.selectedPeople){
        if ([selectedName isEqualToString:name])
            return YES;
    }
    
    return NO;
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

-(NSDecimalNumber *) numberFromHighlightedView{
    UIImage * image = [self grabImageInHighlightedView];
    
    if (image){
        ImageOCR * parsedImage = [[ImageOCR alloc] initWithImage:image];
        return parsedImage.digitNumber;
    }
    
    return [NSDecimalNumber decimalNumberWithString:@"0.00"];
}



-(void) grabInformationFromTableViewAndClearIt{
    
    // grab relevent data and add it to self.items which will be sent to model
    // the first if makes sure that there is relevent information to grab

    
    NSString * number = self.amountField.text;
    NSString * amount = [number stringByReplacingOccurrencesOfString:@"[^0-9.]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [number length])];
    
    NSLog(@"%@ amount", amount);
    if ([self.selectedPeople count] && amount.floatValue){
        NSMutableArray * selectedPeopleForItem = [self.selectedPeople copy];
        MealItem * item = [[MealItem alloc] init];
        item.price =  amount.floatValue;
        item.peopleWhoAteItem = selectedPeopleForItem;
        
        [self.items addObject:item];
        
        
    } else if (tax){
        self.taxAmount = [NSDecimalNumber decimalNumberWithString:amount];
        tax = NO;
    }
    
    Check * check = [[Check alloc] initWithMealItems:self.items people:[self.names mutableCopy] tax:self.taxAmount tipPercentage:0.0];
    self.currentAmountOwedPerPerson = [check calculateAmounts];
        
    // clear out self.selectedPeople so that we do not keep adding to it
    [self.selectedPeople removeAllObjects];
    
    // remove highlight from view
    [self.activeHighlight removeFromSuperview];
    
    // note that there is no current highlight
    highlighted = NO;
        
    // reload data to reflect changes
    [self.nameTable reloadData];
    
}

-(void) shouldReloadForNewItem: (NSNumber *) new{
    shouldReloadForNewItem = new.boolValue;
    [self.nameTable reloadData];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"present"]){
        
        // grabs the last information
        if (highlighted)
            [self grabInformationFromTableViewAndClearIt];
        
        ((SBGLPresentDataViewController*) segue.destinationViewController).presentedData = [self.currentAmountOwedPerPerson mutableCopy];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
