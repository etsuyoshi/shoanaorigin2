//
//  ResultViewController.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/12.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;
#import "Quiz.h"
#import "Siwake.h"

@interface ResultViewController : UIViewController

@property (strong, nonatomic) Quiz *myQuiz;//one section
@property (strong, nonatomic) NSArray *arrQuiz;//all section
@property BOOL isAfterQuiz;//問題解答直後の成績画面かどうか→トップに戻るボタンを追加

@end
