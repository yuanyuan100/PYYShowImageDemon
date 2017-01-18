//
//  ViewController.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "ViewController.h"
#import "PYYShowImage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    PYYShowImage *showImage = [[PYYShowImage alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 80)];
    [showImage startInitUI];
    [self.view addSubview:showImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
