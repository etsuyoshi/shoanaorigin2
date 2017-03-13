//
//  Siwake.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/02/26.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import "Siwake.h"
#import "SiwakeItem.h"
#import "ResultModel.h"




@implementation Siwake{
    NSMutableArray *arrWrongNo;
}

// プロパティに対応するインスタンス変数とアクセッサメソッドの生成
@synthesize siwakeItemsArray = _siwakeItemsArray;
@synthesize usedSiwakeItems = _usedSiwakeItems;
@synthesize arrCategory = _arrCategory;

// 初期化処理
- (id)init
{
    self = [super init];
    if (self)
    {
        // インスタンス変数の初期化
        _siwakeItemsArray = nil;
        _usedSiwakeItems = [[NSMutableArray alloc] init];
        _arrCategory = nil;
        //_section  = 0;//defined by superclass
        
        //        self.isOrdered = YES;
    }
    return self;
}

- (id)initWithKokuhuku:(BOOL)isKokuhuku{
    
    self = [super init];
    if (self)
    {
        // インスタンス変数の初期化
        _siwakeItemsArray = nil;
        _usedSiwakeItems = [[NSMutableArray alloc] init];
        
        //弱点克服モード
        //_isKokuhukuMode = isKokuhuku;
        
        arrWrongNo = [NSMutableArray array];
    }
    
    return self;
}

-(int)nextQuiz:(int)nowNo{
    int returnValue = -1;
    
    if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_STANDARD] ||
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_NO_EXP] ||
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST]){
        returnValue = nowNo + 1;
    }else if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_JAKUTEN]){//現状弱点克服モードはConfigViewControllerで選択できないようになっている
        //弱点克服モードの場合、最初にself.siwakeItemsArrayの中に過去誤った問題だけを設定する
        //また過去に誤った問題が一個もない場合があるので、
        //その場合はDetialViewCon側で通常モードにしてあげて、このクラスで一個もない状態にならないようにしてあげる必要がある
        //既出問題の格納:実際に既に終了した問題はインスタンス生成時に実施すべき（以下はWIP)
        NSMutableArray *arrNew = [NSMutableArray arrayWithArray:self.siwakeItemsArray];
        [arrNew removeObjectsInArray:self.usedSiwakeItems];
        //int noInNew = (int)random() % [arrNew count];
        int noInNew = (int)arc4random_uniform((int)[arrNew count]);
        //NSLog(@"arc = %d", arc4random_uniform(100));
        returnValue = (int)[arrNew[noInNew] integerValue];
        arrNew = nil;
    }else if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST_RANDOM]){
        
        //まだ解いてない問題配列usedSiwakeItemsからランダムに選む（乱数生成のシードは時間で変更するようにする）
        if(!self.usedSiwakeItems){//もし(万が一)既問配列がnullなら初期化
            self.usedSiwakeItems = [NSMutableArray array];
            
            //returnValue = (int)(random() % [self.siwakeItemsArray count]);//全体の中から選ぶ
            returnValue = (int)arc4random_uniform((int)[self.siwakeItemsArray count]);
        }else{
            //usedではない番号を取得
            //returnValue = (int)[self.usedSiwakeItems[(int)(random() % [self.usedSiwakeItems count])] integerValue];
            //returnValue = (int)arc4random_uniform((int)[self.usedSiwakeItems count]);
            
            //未解決問題配列を生成
            NSMutableArray *arrNew = [NSMutableArray array];
            for(int i = 0 ;i < self.siwakeItemsArray.count;i++){
                //usedになければ追加する
                if([self.usedSiwakeItems indexOfObject:[NSNumber numberWithInt:i]]==NSNotFound){
                    [arrNew addObject:[NSNumber numberWithInt:i]];
                }
            }
            
            //arrNewの中からランダムに番号を生成する
            returnValue = (int)arc4random_uniform(((int)[arrNew count]));
            arrNew = nil;
        }
        
    }else{
        //フラグなしの場合（万が一）
        returnValue = nowNo + 1;
    }
    
    //過去問の追加
    [self.usedSiwakeItems addObject:[NSNumber numberWithInt:returnValue]];
    
    for(int i = 0;i<self.usedSiwakeItems.count;i++){
        NSLog(@"used[%d] = %@", i, self.usedSiwakeItems[i]);
    }
    NSLog(@"nowNo = %d", returnValue);
    
    return returnValue;
}


// 出題済みの情報をクリアするメソッド
- (void)clear
{
    // 出題済みの配列を空にする
    [_usedSiwakeItems removeAllObjects];
}


//CSVファイルからデータを読み込む
- (BOOL)readFromCSV:(NSString *)filePath
{
    // ファイルを読み込む
    NSString *fileData;
    fileData = [NSString stringWithContentsOfFile:filePath
                                         encoding:NSUTF8StringEncoding
                                            error:NULL];
    
    if (!fileData)
        return NO;  // 読み込み失敗
    
    // 改行文字で分割する
    NSArray *linesArray = [fileData componentsSeparatedByString:@"\n"];
    if (!linesArray || [linesArray count] == 0)
        return NO;  // ファイルの内容が正しくない
    
    // ファイルの内容を解析する
    SiwakeItem *curItem = nil;//Current Item
    NSMutableArray *arrMCategory = [NSMutableArray array];
    
    //一行の中でカンマに区切られた値
    //   0      1       2       3     4     5  6  7  8    9         10  11
    //【章番号、問題番号、問題種別、質問文、選択肢１、２、３、４、５、正解番号、正解文章、解説
    
    //   0      1       2       3        4     5  　　6  　　　7  　　 8,9,10,11,12,13,14,15,16,18,18,19, 20
    //【章番号、問題番号、問題種別、問題文、借方項目、借方値,貸方項目、貸方値、語群1,2,3, 4,  5, 6, 7, 8,9, 10,11,12,解説文
    
    
    NSMutableArray *arrAllWord = [NSMutableArray array];
    for(NSString *line in linesArray){
        
        @autoreleasepool {
            if([line rangeOfString:@"[EOF]"].location != NSNotFound){
                break;
            }
            
            //comma separate => array
            NSArray *eachInLine = [line componentsSeparatedByString:@","];
            [arrAllWord addObject:eachInLine];
        }
    }
    
    
    
    int maxLengthExplanationStr = 0;
    NSMutableArray *arrMSiwake = [NSMutableArray array];
//    int rowNo = 0
//    for(NSArray *arrInLine in arrAllWord){//各行に対して
    for(int rowNo = 0;rowNo < arrAllWord.count;rowNo++){
        
        @autoreleasepool {
            //一行文を単語配列に変換
            NSArray *arrInLine = arrAllWord[rowNo];
            curItem = [[SiwakeItem alloc]init];
            
            NSString *sectionNo = arrInLine[0];//章番号
            NSLog(@"sectionNo = %@", sectionNo);
            if([sectionNo length] < 4){
                //最初の列の文字長が4以上でなければ次の行をみる
                continue;
            }
            if(![[sectionNo substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"SECT"]){
                NSLog(@"left(sectionNo,4) = %@", [sectionNo substringWithRange:NSMakeRange(0, 4)]);
                arrInLine = nil;
                curItem = nil;
                sectionNo = nil;
                //問題レコードでなければ次の行に移行する
                continue;
            }
            if(self.section == 0){
                self.section = (int)[[sectionNo substringFromIndex:((NSString *)sectionNo).length-3] integerValue];
            }
            
            
            
            NSString *questionNo = arrInLine[1];//問題番号
            int intQuestionNo = (int)[[questionNo substringWithRange:NSMakeRange(1, 3)] integerValue];//Q0010->001->1
            
            NSString *questionKindStr = arrInLine[2];//問題種別
            NSString *questionSentence = arrInLine[3];//問題文
            
            curItem.question = [self getLinedSentence:questionSentence];
            curItem.sectorName = sectionNo;
            curItem.questionNo = questionNo;
            curItem.intQuestionNo = intQuestionNo;
            curItem.category = questionKindStr;
            
            
            //3未満しか格納してなくて当該種類を含んでいなければ追加
            if(![arrMCategory containsObject:questionKindStr] && arrMCategory.count < 3){
                [arrMCategory addObject:questionKindStr];
            }
            
            
            
            NSMutableDictionary *dictKari = [NSMutableDictionary dictionary];
            NSMutableDictionary *dictKasi = [NSMutableDictionary dictionary];
            NSLog(@"row_dash start");
            for(int row_dash = 0;;row_dash++){
            //for(;;rowNo++){
                //NSArray *arrInLine_dash = arrAllWord[row_dash];
                
                //借方
                NSString *strKariKey   = arrAllWord[rowNo+row_dash][4];
                NSString *strKariValue = arrAllWord[rowNo+row_dash][5];
                [dictKari setObject:strKariValue forKey:strKariKey];
                //貸方
                NSString *strKasiKey   = arrAllWord[rowNo+row_dash][6];
                NSString *strKasiValue = arrAllWord[rowNo+row_dash][7];
                [dictKasi setObject:strKasiValue forKey:strKasiKey];
                
                //終了条件:①次の行がEOFもしくは②次の問題番号の右端がゼロである場合はbreak;
                if(rowNo+row_dash+1 >= arrAllWord.count){//①
                    rowNo += row_dash;
                    break;
                }
                NSString *questionNo_dash = arrAllWord[rowNo+row_dash+1][1];//②次の行を参照する
                int nextRightNumber = (int)[[questionNo_dash substringWithRange:NSMakeRange(4,1)] integerValue];
                
                //次の行のrightNumberがゼロになるように。
                if(nextRightNumber == 0){
                    rowNo += row_dash;
                    
                    questionNo_dash = nil;
                    strKasiKey = nil;
                    strKasiValue = nil;
                    break;
                }
            }
            
            curItem.dictCorrectKari = dictKari;
            curItem.dictCorrectKasi = dictKasi;
            
            
            //選択肢語群
            curItem.arrMSelectWords = [NSMutableArray array];
            for(int i = 8;i <= 19;i++){
                if(![((NSString *)arrInLine[i]) isEqualToString:@"-"]){
                    [curItem.arrMSelectWords addObject:arrInLine[i]];
                }
            }
            
            curItem.arrMSelectNumbers = [NSMutableArray array];
            //arrMSelectNumberに格納する
            if(((int)arc4random() * 100) %2 == 0){
                for(int i = 0;i < curItem.dictCorrectKari.allValues.count;i++){
                    if(![curItem.arrMSelectNumbers containsObject:curItem.dictCorrectKari.allValues[i]]){
                        [curItem.arrMSelectNumbers addObject:[NSString stringWithFormat:@"%@",curItem.dictCorrectKari.allValues[i]]];
                    }
                }
                for(int i = 0;i < curItem.dictCorrectKasi.allValues.count;i++){
                    if(![curItem.arrMSelectNumbers containsObject:curItem.dictCorrectKasi.allValues[i]]){
                        [curItem.arrMSelectNumbers addObject:[NSString stringWithFormat:@"%@",curItem.dictCorrectKasi.allValues[i]]];
                    }
                }
            }else{
                for(int i = 0;i < curItem.dictCorrectKasi.allValues.count;i++){
                    if(![curItem.arrMSelectNumbers containsObject:curItem.dictCorrectKasi.allValues[i]]){
                        [curItem.arrMSelectNumbers addObject:[NSString stringWithFormat:@"%@",curItem.dictCorrectKasi.allValues[i]]];
                    }
                }
                for(int i = 0;i < curItem.dictCorrectKari.allValues.count;i++){
                    if(![curItem.arrMSelectNumbers containsObject:curItem.dictCorrectKari.allValues[i]]){
                        [curItem.arrMSelectNumbers addObject:[NSString stringWithFormat:@"%@",curItem.dictCorrectKari.allValues[i]]];
                    }
                }
            }
            
            //個数が一個しか入ってない場合は半分、２倍の数字も格納しておく
            if(curItem.arrMSelectNumbers.count == 1){
                int targetNumber = (int)[curItem.arrMSelectNumbers[0] integerValue];
                [curItem.arrMSelectNumbers addObject:[NSNumber numberWithInt:(targetNumber * 2)]];
                [curItem.arrMSelectNumbers addObject:[NSNumber numberWithInt:(targetNumber / 2)]];
            }
            
            curItem.explanation = [self getLinedSentence:arrInLine[20]];//説明文@シャープを改行にした文字列
            maxLengthExplanationStr =
            maxLengthExplanationStr>[curItem.explanation length]?maxLengthExplanationStr:(int)[curItem.explanation length];
            
            ResultModel *myResultModel = [[ResultModel alloc] initWithSection:self];
            curItem.kaitou = [NSString stringWithFormat:@"%d", [myResultModel getAnswer:[questionNo intValue]]];
            curItem.seikai = [NSString stringWithFormat:@"%d", [myResultModel getCorrect:[questionNo intValue]]];
            
            [arrMSiwake addObject:curItem];
        }
    }
    
    NSLog(@"maxLengthExplanationStr = %d", maxLengthExplanationStr);
    
    self.arrCategory = (NSArray *)arrMCategory;
    self.siwakeItemsArray = (NSArray *)arrMSiwake;
    
    return YES;
}

//self.siwakeItemsArrayがMutableではないため全部入れ替える
-(BOOL)updateAllResult{
    ResultModel *myResultModel = [[ResultModel alloc] initWithSection:self];
    NSMutableArray *arrSiwakeItems_tmp = [NSMutableArray array];
    for(int i = 0;i < self.siwakeItemsArray.count;i++){
        
        @autoreleasepool {
            
            SiwakeItem *tmpSiwakeItem = self.siwakeItemsArray[i];
            tmpSiwakeItem.seikai = [NSString stringWithFormat:@"%d", [myResultModel getCorrect:i]];
            tmpSiwakeItem.kaitou = [NSString stringWithFormat:@"%d", [myResultModel getAnswer:i]];
            [arrSiwakeItems_tmp addObject:tmpSiwakeItem];
            tmpSiwakeItem = nil;
        }
    }
    
    self.siwakeItemsArray = (NSArray *)arrSiwakeItems_tmp;
    
    return YES;
}

-(NSString *)getLinedSentence:(NSString *)strParam{
    @autoreleasepool {
        
        NSArray *arrExp = [strParam componentsSeparatedByString:@"#"];
        
        NSString *strReturn = [arrExp componentsJoinedByString:@"\n"];
        
        arrExp = nil;
        
        return strReturn;
    }
}


@end
