//
//  ResultModel.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/19.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#define isDebug
#import "ResultModel.h"

@implementation ResultModel

- (id)initWithSection:(Quiz *)myQuiz {
    self = [super init];
    
    if (self) {
        self.section = myQuiz.section;
        
#ifdef QUIZ_FLAG
        self.allQuizCount = (int)myQuiz.quizItemsArray.count;
#else
        self.allQuizCount = (int)((Siwake *)myQuiz).siwakeItemsArray.count;
#endif

        //NSUserDefaultから過去のデータを取得して配列に格納する：なければ全部ぜろの要素数を取得する
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSUserDefaultsにNSArray,NSDictionaryなどをネストして保存できない！
//        NSArray *arrAnswer =
        self.arrAnswerInSection =
        (NSMutableArray *)[userDefaults arrayForKey:
         [NSString stringWithFormat:@"%@%d", USER_DEFAULTS_ANSWER, self.section]];
//        NSArray *arrCorrect =
        self.arrCorrectInSection =
         (NSMutableArray *)[userDefaults arrayForKey:
          [NSString stringWithFormat:@"%@%d", USER_DEFAULTS_CORRECT, self.section]];
        
        //[userDefaults ....]
        if(self.arrAnswerInSection.count > 0){
            //何もしない
        }else{
            
            //一度でもResultModelを初期化した際、過去データが存在しなければ全部ゼロとして格納する
            self.arrAnswerInSection = [NSMutableArray array];
            self.arrCorrectInSection = [NSMutableArray array];
            
#ifdef QUIZ_FLAG
            for(int i = 0;i < myQuiz.quizItemsArray.count;i++){
#else
            for(int i = 0;i < ((Siwake *)myQuiz).siwakeItemsArray.count;i++){
#endif
                [self.arrAnswerInSection addObject:[NSNumber numberWithInteger:0]];
                [self.arrCorrectInSection addObject:[NSNumber numberWithInteger:0]];
            }
            
            [userDefaults
             setObject:self.arrAnswerInSection
             forKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_ANSWER, self.section]];
            [userDefaults
             setObject:self.arrCorrectInSection
             forKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_CORRECT, self.section]];
            [userDefaults synchronize];
            
        }
        
        userDefaults = nil;
    }
    
    return self;
}

//全回答回数取得
-(int)getAnswer:(int)quizNo{
    NSLog(@"%s, quizNo = %d", __func__, quizNo);
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSArray *arrAnswers = [userDef arrayForKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_ANSWER, self.section]];
    if(arrAnswers){
        if(quizNo < arrAnswers.count){
            return (int)[arrAnswers[quizNo] integerValue];
        }
    }
    
    
    //未回答の場合
    return 0;
}

//問題番号を指定せずにセクション内のすべての回答数配列を取得する
-(NSArray *)getAnswers{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    NSArray *arrAnswers =
    [userDef arrayForKey:
     [NSString stringWithFormat:@"%@%d", USER_DEFAULTS_ANSWER, self.section]];
    userDef = nil;
    
    return arrAnswers;
}
//正答数取得
-(int)getCorrect:(int)quizNo{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSArray *arrCorrects = [userDef arrayForKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_CORRECT, self.section]];
    if(arrCorrects){
        if(quizNo < arrCorrects.count){
            return (int)[arrCorrects[quizNo] integerValue];
        }
    }
    //正解したことがない（正解したデータが存在しない）場合は0を明示的に返す
    return 0;
}

//問題番号を指定せずにセクション内のすべての正解数配列を取得する
-(NSArray *)getCorrects{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSArray *arrCorrects =
    [userDef arrayForKey:
     [NSString stringWithFormat:@"%@%d", USER_DEFAULTS_CORRECT, self.section]];
    userDef = nil;
    return arrCorrects;
}

-(BOOL)setResult:(int)quizNo isCorrect:(BOOL)isCorrect{
    NSLog(@"%s, %d, %d", __func__, quizNo, isCorrect);
    //NSLog(@"count = %d", self.arrAnswerInSection.count);
    if(quizNo >= self.arrAnswerInSection.count){//out of range array
        return FALSE;
    }
    int intAnswer = (int)[self.arrAnswerInSection[quizNo] integerValue];
    NSLog(@"before answer = %d", intAnswer);
    intAnswer++;
    NSLog(@"self.arr[quizno]=%@", self.arrAnswerInSection[quizNo]);
    self.arrAnswerInSection = [self.arrAnswerInSection mutableCopy];
    self.arrAnswerInSection[quizNo] = [NSNumber numberWithInteger:intAnswer];
    
    if(isCorrect){
        int intCorrect =(int)[self.arrCorrectInSection[quizNo] integerValue];
        intCorrect++;
        self.arrCorrectInSection = [self.arrCorrectInSection mutableCopy];
        self.arrCorrectInSection[quizNo] = [NSNumber numberWithInt:intCorrect];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.arrAnswerInSection
                     forKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_ANSWER, self.section]];
    [userDefaults setObject:self.arrCorrectInSection
                     forKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_CORRECT, self.section]];
    [userDefaults synchronize];
    
    userDefaults = nil;
    
    return YES;
}


-(BOOL)resetAllData{
    NSLog(@"%s", __func__);
    //remove all data
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_CORRECT,self.section]];
    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@%d", USER_DEFAULTS_ANSWER, self.section]];
    [userDefaults synchronize];
    userDefaults  = nil;
    return YES;
}

@end
