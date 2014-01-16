//
//  ViewController2.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import "ViewController2.h"
#import "ViewController.h"
#import "TSNavigatioController.h"
#import "AppDelegate.h"

@interface ViewController2 () <UITextFieldDelegate>

@end

@implementation ViewController2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)go2next:(id)sender {
    ViewController *debugPanel = [[ViewController alloc] init];
//    float seed = arc4random() % 2;
//	[self.navigationController pushViewController:debugPanel animated:seed < 0.5 ? YES : NO];
    [self.navigationController pushViewController:debugPanel animated:YES];
}

- (IBAction)popModelView:(id)sender {
    ViewController *debugPanel = [[ViewController alloc] init];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(CloseModel)];
    [[debugPanel navigationItem] setLeftBarButtonItem:cancel];
    
    TSNavigatioController *navController = [[TSNavigatioController alloc] initWithRootViewController:debugPanel];
    [[AppDelegate instance].viewController presentModalViewController:navController animated:YES];
}

- (void)CloseModel
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.transform = CGAffineTransformMakeTranslation(0, -200);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.transform = CGAffineTransformIdentity;
}

@end
