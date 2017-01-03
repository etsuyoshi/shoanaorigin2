//
//  DetailViewController.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quiz.h"

@interface DetailViewController : UIViewController

//@property (strong, nonatomic) NSDate *detailItem;
@property (strong, nonatomic) Quiz *quiz;
@property int quizNo;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *questionContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *answer1Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer2Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer3Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer4Btn;

@end

