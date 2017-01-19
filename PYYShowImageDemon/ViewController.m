//
//  ViewController.m
//  PYYShowImageDemon
//
//  Created by Snake on 17/1/18.
//  Copyright © 2017年 IAsk. All rights reserved.
//

#import "ViewController.h"
#import "PYYShowImage.h"
#import "PYPhoto.h"
#import "PYYShowImageScrollVIewVCViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < 15; i++) {
        PYPhoto *model = [[PYPhoto alloc] init];
        switch (i) {
            case 0:
                model.URL = @"http://img17.3lian.com/d/file/201701/14/c40a0c498eeb33de0f0d586f2c2fc5bf.jpg";
                break;
            case 1:
                model.URL = @"http://img17.3lian.com/d/file/201701/14/552548be1141c5fb907972d46e87ada6.jpg";
                break;
            case 2:
                model.URL = @"http://img17.3lian.com/d/file/201701/14/bef0b315f11cf49b275c688c43a9c48d.jpg";
                break;
            case 3:
                model.URL = @"http://img17.3lian.com/d/file/201701/14/be8819edcdb35ed0b33bd9384cfdf000.jpg";
                break;
            default:
                model.URL = @"http://img17.3lian.com/d/file/201701/14/bedaeedb981131e3f075bbff8e18f279.jpg";
                break;
        }
        
        [arr addObject:model];
    }
    
    PYYShowImage *showImage = [[PYYShowImage alloc] initWithImageArray:arr];
    showImage.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 300);
    showImage.number = 15;
    [showImage startInitUI];
    
    showImage.SeeBigImageBlock = ^NSArray<NSNumber *>*(NSArray<PYPhoto *> *dataSource, NSUInteger index) {
        PYYShowImageScrollVIewVCViewController *vc = [[PYYShowImageScrollVIewVCViewController alloc] initWithImageArray:dataSource index:index];
        [self presentViewController:vc animated:YES completion:nil];
        return nil;
    };
    [self.view addSubview:showImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
