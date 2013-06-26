//
//  SBGLNameDinersViewController.m
//  split
//
//  Created by Adam Gluck on 6/25/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "SBGLNameDinersViewController.h"
#import "SBGLImageViewController.h"

@interface SBGLNameDinersViewController ()

@property (strong, nonatomic) NSMutableArray * names;
@property (strong, nonatomic) NSMutableArray * textFields;

@end

@implementation SBGLNameDinersViewController

@synthesize names = _names;
@synthesize textFields = _textFields;

-(NSMutableArray *) names {
    if (!_names)
        _names = [[NSMutableArray alloc] init];
    
    return _names;
}

-(NSMutableArray *) textFields{
    if (!_textFields)
        _textFields = [[NSMutableArray alloc] init];
    
    return _textFields;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.numberOfDiners.intValue;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"nameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITextField * field = (UITextField *)[cell viewWithTag:1];
    
    [self.textFields addObject:field];
        
    return cell;
}

#pragma mark - Segue Functions

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toPicker"]){
        
        for (UITextField * textfield in self.textFields){
            if (![textfield.text isEqualToString:@""])
                [self.names addObject:textfield.text];
        }
        
        NSLog(@"segue prepared for");
        ((SBGLImageViewController *) segue.destinationViewController).names = self.names;
        NSLog(@"done with segue prepare");
    }
    
}

@end
