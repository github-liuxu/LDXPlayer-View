//
//  ViewController.m
//  LDXPlayer View
//
//  Created by bmd on 2017/3/24.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "LDXPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    LDXPlayer *player = [LDXPlayer palyer];
    player.frame = CGRectMake(0, 0, 375, 200);
    [player setOldFrame:player.frame];
    [player updatePlayerWith:[NSURL URLWithString:@"https://tianmavideo.meishe-app.com/video/2017/03/23/task-1-79302969-BBC4-062E-001D-6FB6C0D6F0DD.mp4"]];
    [self.view addSubview:player];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
