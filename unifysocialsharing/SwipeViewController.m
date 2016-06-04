//
//  ViewController.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#import "SwipeViewController.h"
#import "DraggableViewBackground.h"


@interface SwipeViewController ()
@end

@implementation SwipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
    
    
    [draggableBackground.addButton addTarget:self action:NSSelectorFromString(@"plusButtonAction") forControlEvents:UIControlEventTouchUpInside];
    //[self.view bring to front]
}

-(void)plusButtonAction
{
    [self performSegueWithIdentifier:@"addSegue" sender:self];
}

@end
