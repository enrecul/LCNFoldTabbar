//
//  ViewController.m
//  LCNFoldTabbar
//
//  Created by 黄春涛 on 16/1/14.
//  Copyright © 2016年 黄春涛. All rights reserved.
//

#import "ViewController.h"
#import "LCNFoldTabbar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LCNFoldTabbar *foldTab = [[LCNFoldTabbar alloc] init];
    
    [self.view addSubview:foldTab];
    
}

@end
