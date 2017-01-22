////
////  DemoBaseViewController.h
////  shoana
////
////  Created by EndoTsuyoshi on 2017/01/18.
////  Copyright © 2017年 com.endo. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//
//@interface DemoBaseViewController : UIViewController
//
//@end

//
//  DemoBaseViewController.h
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

@import Charts;
#import <UIKit/UIKit.h>
//#import "Shoana-Swift.h"

@interface DemoBaseViewController : UIViewController
{
@protected
    NSArray *parties;
}

@property (nonatomic, strong) IBOutlet UIButton *optionsButton;
@property (nonatomic, strong) IBOutlet NSArray *options;

@property (nonatomic, assign) BOOL shouldHideData;

- (void)handleOption:(NSString *)key forChartView:(ChartViewBase *)chartView;

- (void)updateChartData;

- (void)setupPieChartView:(PieChartView *)chartView;
- (void)setupRadarChartView:(RadarChartView *)chartView;
- (void)setupBarLineChartView:(BarLineChartViewBase *)chartView;

@end
