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

@interface ViewController2 () <UITextFieldDelegate, UIAlertViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtField;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *switch_isDrawerView;

@end

@implementation ViewController2

- (BOOL)isDrawerView
{
    return [super isDrawerView] && (_switch_isDrawerView == nil ? YES : _switch_isDrawerView.on);
}

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
    self.view.transform = CGAffineTransformMakeTranslation(0, -150);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.transform = CGAffineTransformIdentity;
}

- (void)backToPreviousViewController
{
    if (_txtField.text.length == 0) {
        [_txtField resignFirstResponder];
        
        [super backToPreviousViewController];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您写的内容还没有提交哦，是否继续编辑？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"退出", nil ];
    [alert addButtonWithTitle:@"继续编辑"];
    alert.cancelButtonIndex = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [super backToPreviousViewController];
            break;
            
        default:
            [self cancelBackToPreviousViewController];
            break;
    }
}

@end
