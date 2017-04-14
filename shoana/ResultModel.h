//
//  ResultModel.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/19.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quiz.h"
#import "Siwake.h"

@interface ResultModel : NSObject

@property int section;
@property int allQuizCount;
@property (nonatomic, strong) NSMutableArray *arrAnswerInSection;//当該セクションにおける問題数の回答数
@property (nonatomic, strong) NSMutableArray *arrCorrectInSection;//該当セクションにおける問題数の正解数


- (id)initWithSection:(Quiz *)myQuiz;
-(BOOL)setResult:(int)quizNo isCorrect:(BOOL)isCorrect;
-(BOOL)resetAllData;
-(int)getAnswer:(int)quizNo;
-(NSArray *)getAnswers;
-(int)getCorrect:(int)quizNo;
-(NSArray *)getCorrects;

-(int)getInCorrectWithoutNo:(int)withoutNo withThreashold:(int)threashold;
@end
