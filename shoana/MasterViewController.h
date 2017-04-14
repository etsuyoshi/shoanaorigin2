//
//  MasterViewController.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;


@class DetailViewController;
@class Quiz;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) Quiz *quiz;

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSString *strConfigKey;
@end

