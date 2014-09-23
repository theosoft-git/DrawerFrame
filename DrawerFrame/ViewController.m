//
//  ViewController.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *scNavigationStyle;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    switch ([AppDelegate instance].navigationStyle) {
        default:
        case TSNavigationStyleIOS7:
            self.scNavigationStyle.selectedSegmentIndex = 0;
            break;
        case TSNavigationStyleDrawer:
            self.scNavigationStyle.selectedSegmentIndex = 1;
            break;
        case TSNavigationStyleCascade:
            self.scNavigationStyle.selectedSegmentIndex = 2;
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)go2nextPage:(id)sender {
    ViewController2 *debugPanel = [[ViewController2 alloc] init];
	[self.navigationController pushViewController:debugPanel animated:YES];
}

- (IBAction)navigationStyleChanged:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        default:
        case 0:
            [AppDelegate instance].navigationStyle = TSNavigationStyleIOS7;
            break;
        case 1:
            [AppDelegate instance].navigationStyle = TSNavigationStyleDrawer;
            break;
        case 2:
            [AppDelegate instance].navigationStyle = TSNavigationStyleCascade;
            break;
    }
}

- (TSNavigationStyle)navigationStyle
{
    return [AppDelegate instance].navigationStyle;
}
@end
