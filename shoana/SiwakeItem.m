//
//  SiwakeItem.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/02/25.
//  Copyright © 2017年 com.endo. All rights reserved.
//  問題１個ごとに格納する

#import "SiwakeItem.h"

@implementation SiwakeItem

@synthesize sectorName = _sectorName;
@synthesize category = _category;
@synthesize questionNo = _questionNo;
@synthesize question = _question;
@synthesize explanation = _explanation;
@synthesize kaitou = _kaitou;
@synthesize seikai = _seikai;

//仕分け特有
@synthesize dictCorrectKari = _dictCorrectKari;
@synthesize dictCorrectKasi = _dictCorrectKasi;
@synthesize arrMSelectWords = _arrMSelectWords;
@synthesize arrMSelectNumbers = _arrMSelectNumbers;

// 初期化処理
- (id)init
{
    self = [super init];
    if (self)
    {
        // インスタンス変数を初期化
        _sectorName = nil;
        _category = nil;
        _questionNo = nil;
        _question = nil;
//        _rightAnswer = nil;
//        _choicesArray = nil;
        _explanation = nil;
        _kaitou = nil;
        _seikai = nil;
        
        _dictCorrectKari = nil;
        _dictCorrectKasi = nil;
        _arrMSelectWords = nil;
        _arrMSelectNumbers = nil;
    }
    return self;
}

// 選択肢をランダムに入れ替えた配列を返す
- (NSArray *)randomChoicesArray
{
    // 並び替えた選択肢を格納する配列
    //    NSMutableArray *newArray = [NSMutableArray array];
    
    // 取り出す前の選択肢を格納した配列
    NSMutableArray *remainArray;
    //remainArray = [NSMutableArray arrayWithArray:self.choicesArray];
    
    //    return newArray;//→ランダムにしないで順番通りを返す
    return remainArray;
}


/*
 * 辞書についてはNSDictionary isEqualToDictionary:で一行確認ができるので以下不要。。
 */

/* 回答された状態の仕分け表をdict形式で受け取って各キーとバリューが正しいかどうか判定する
 * dictAnswer
 *  ["kari":["kamoku1":"value1", "kamoku2":"value2"],
 *   "kasi":["kamoku3":"value3", "kamoku4":"value4"]]
 */
-(BOOL)checkIsRightDict:(NSDictionary *)dictAnswer{
    NSDictionary *dictAnswerKari = dictAnswer[@"kari"];//借方の回答
    NSDictionary *dictAnswerKasi = dictAnswer[@"kasi"];//貸方の回答
    
    //karikata check
    if(![dictAnswerKari isEqual:[NSNull null]] & ![dictAnswerKasi isEqual:[NSNull null]]){
        //借方の判定が通れば貸方のチェックを行う
        if([self checkIsRightWith:@"kari"
                       answerDict:dictAnswerKari]){
            return [self checkIsRightWith:@"kasi"
                               answerDict:dictAnswerKasi];
        }
    }
    
    return NO;
}

//借方と貸方の両方をチェックできるようにkari-kasi両方ともチェックできるメソッド（やっていることは同じチェック）
-(BOOL)checkIsRightWith:(NSString *)kariKasiKeys
             answerDict:(NSDictionary *)answerDicts{

    
    NSDictionary *dictCorrects = nil;
    if([kariKasiKeys isEqualToString:@"kari"]){
        dictCorrects = self.dictCorrectKari;
    }else{
        dictCorrects = self.dictCorrectKasi;
    }
    
    NSArray *arrAnswerKeys = answerDicts.allKeys;
    
    //正解の勘定科目（キー）の個数が回答した勘定科目の個数と異なるならreturn false
    if([arrAnswerKeys count] != [dictCorrects.allKeys count]){
        return NO;
    }
    // 回答の借方を一つ一つ確認する
    for(int i = 0;i < arrAnswerKeys.count;i++){
        //回答された回答内の借方に正解の借方の項目(key)があれば、その番号の値を参照して正解と等しいか判定する
        if([dictCorrects.allKeys containsObject:arrAnswerKeys[i]]){
            NSLog(@"回答した勘定科目(%@)が正解に含まれています",
                  dictCorrects[arrAnswerKeys[i]]);
            //対応する値を型名不明のまま受け取る(次に型名判定をして数値であれば正解不正解の判定を行う）
            id correctValue = dictCorrects[arrAnswerKeys[i]];
            if([correctValue isKindOfClass:[NSNumber class]]){//数字なら
                if([correctValue integerValue] == [answerDicts[arrAnswerKeys[i]] integerValue]){
                    return YES;
                }
            }
            NSLog(@"勘定科目(%@)に対する値(%ld)が正解(%ld)ではありません",
                  dictCorrects[arrAnswerKeys[i]],
                  [answerDicts[arrAnswerKeys[i]] integerValue],
                  [correctValue integerValue]);
            return NO;
        }else{
            return NO;
        }
    }
    
    return NO;
}



@end
