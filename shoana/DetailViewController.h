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

@property (weak, nonatomic) NSString *strConfigKey;//ConfigViewControllerで設定する問題モード
//@property (strong, nonatomic) NSDate *detailItem;
@property (strong, nonatomic) Quiz *quiz;//章番号はquiz.
@property int quizNo;//何番目の問題か（章番号ではなく章の中の問題番号)
//@property (weak, nonatomic) NSNumber *quizNo;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

//@property (weak, nonatomic) IBOutlet UILabel *questionContentLabel;
@property (weak, nonatomic) IBOutlet UITextView *questionContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *answer1Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer2Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer3Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer4Btn;

@end

