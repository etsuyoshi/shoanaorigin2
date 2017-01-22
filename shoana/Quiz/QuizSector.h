//
//  QuizSector.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/09.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quiz.h"

@interface QuizSector : NSObject

@property (retain, nonatomic) NSMutableArray *quizSectsArray;

// データファイルから全クイズデータを読み込むメソッド
- (BOOL)readAll;

@end
