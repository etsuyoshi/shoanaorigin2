//
//  SiwakeItem.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/02/25.
//  Copyright © 2017年 com.endo. All rights reserved.
//
#import "QuizItem.h"
#import <Foundation/Foundation.h>

//@interface SiwakeItem : NSObject
@interface SiwakeItem : QuizItem

//章番号
//@property (copy, nonatomic) NSString *sectorName;
//
////章名称
//@property (copy, nonatomic) NSString *category;
//
////問題番号
//@property (copy, nonatomic) NSString *questionNo;
//
//@property int intQuestionNo;
//
//// 問題文
//@property (copy, nonatomic) NSString *question;
//
//
//// 説明文
//@property (copy, nonatomic) NSString *explanation;
//
//// 回答回数
//@property (strong, nonatomic) NSString *kaitou;
//@property (strong, nonatomic) NSString *seikai;

// 正解：借方と貸方の辞書
@property (strong, nonatomic) NSDictionary *dictCorrectKari;
@property (strong, nonatomic) NSDictionary *dictCorrectKasi;

// 選択語群
@property (strong, nonatomic) NSMutableArray *arrMSelectWords;

// csvに格納されていないので回答(dictKari/kasi)から作成する必要がある。
// 数字の選択肢については回答（科目が複数ケースも含む）の前後数単位分を用意する
@property (strong, nonatomic) NSMutableArray *arrMSelectNumbers;



// 答えが合っているかチェックするメソッド
//-(BOOL)checkIsRightNo:(NSDictionary *)dictAnswer;
-(BOOL)checkIsRightDict:(NSDictionary *)dictAnswer;

//@property int rightNo;
//
//// 正解
//@property (copy, nonatomic) NSString *rightAnswer;
//
//// 選択肢の配列
//@property (strong, nonatomic) NSArray *choicesArray;
//
//// ランダムに並び替えられた選択肢の配列
//@property (readonly, nonatomic) NSArray *randomChoicesArray;


@end


