#import "Quiz.h"
#import "QuizItem.h"
#import "ResultModel.h"

@implementation Quiz{
    NSMutableArray *arrWrongNo;
}

// プロパティに対応するインスタンス変数とアクセッサメソッドの生成
@synthesize quizItemsArray = _quizItemsArray;
@synthesize usedQuizItems = _usedQuizItems;
@synthesize isKokuhukuMode = _isKokuhukuMode;
@synthesize jakutenNo = _jakutenNo;
@synthesize arrCategory = _arrCategory;
@synthesize strSeikaisu = _strSeikaisu;
@synthesize strKaitoukaisu = _strKaitoukaisu;

// 初期化処理
- (id)init
{
    self = [super init];
    if (self)
    {
        // インスタンス変数の初期化
        _quizItemsArray = nil;
        _usedQuizItems = [[NSMutableArray alloc] init];
        _isKokuhukuMode = false;
        _arrCategory = nil;
        _strKaitoukaisu = nil;
        _strSeikaisu = nil;
        _section  = 0;
        
        self.isOrdered = YES;
    }
    return self;
}

- (id)initWithKokuhuku:(BOOL)isKokuhuku{
    
    self = [super init];
    if (self)
    {
        // インスタンス変数の初期化
        _quizItemsArray = nil;
        _usedQuizItems = [[NSMutableArray alloc] init];
        
        //弱点克服モード
        _isKokuhukuMode = isKokuhuku;
        
        arrWrongNo = [NSMutableArray array];
        ResultModel *myResultModel = [[ResultModel alloc]initWithSection:nil];//代入必要！
        
        
    }
    
    return self;
}

-(int)nextQuiz:(int)nowNo{
    int returnValue = -1;
    if(self.isOrdered){
        returnValue = nowNo + 1;
    }else if(self.isRandom){
        
        //既出問題の格納
        NSMutableArray *arrNew = [NSMutableArray arrayWithArray:self.quizItemsArray];
        [arrNew removeObjectsInArray:self.usedQuizItems];
        int noInNew = (int)random() % [arrNew count];
        returnValue = (int)[arrNew[noInNew] integerValue];
        arrNew = nil;
    }else if(self.isKokuhukuMode){
        
    
    }else{
        //フラグの立て忘れの場合はisOrderedとする
        returnValue = nowNo + 1;
    }
    
    
    [self.usedQuizItems addObject:[NSNumber numberWithInt:returnValue]];
    
    for(int i = 0;i<self.usedQuizItems.count;i++){
        NSLog(@"used[%d] = %@", i, self.usedQuizItems[i]);
    }
    NSLog(@"nowNo = %d", returnValue);
    
    return returnValue;
}

// 次の問題を返すメソッド:instanceではなくint型の整数を返す
- (int)nextQuizPast:(int)nowNo{
    // 使用していない問題の配列を作成する
    NSMutableArray *tempArray;
    tempArray = [NSMutableArray arrayWithArray:self.quizItemsArray];
    [tempArray removeObjectsInArray:self.usedQuizItems];
    
    // すでに全て出題済みのときは「nil」を返して終了
    if ([tempArray count] == 0)
        return -1;
    
    // 返す問題を決定する
    NSInteger ind = 0;
    if(!self.isOrdered){
        ind = nowNo+1;
    }else if(!self.isRandom){
        for(;;){
            ind = random() % [tempArray count];
            if(ind != nowNo){
                break;
            }
        }
    }
//    意味不明
//    if(!_isKokuhukuMode){
//        ind = random() % [tempArray count];
//        NSLog(@"%ld@Quiz:nextQuiz_%d", ind, _isKokuhukuMode);
//    }else{
//        ind = _jakutenNo - 1;//ind=0がNo001に相当する
//        NSLog(@"%ld@Quiz:nextQuiz_%d", ind, _isKokuhukuMode);
//    }
    
    // 返す問題を取得する:instanceが必要な場合
//    QuizItem *item = [tempArray objectAtIndex:ind];
//    
//    // 使用済みの配列に追加する
//    [_usedQuizItems addObject:item];
    // 取得した問題を返す
    //return item;
    return (int)ind;
}
//
//- (QuizItem *)indicatedQuiz:(int)indicatedNo
//{
//    // 使用していない問題の配列を作成する
//    NSMutableArray *tempArray;
//    tempArray = [NSMutableArray arrayWithArray:self.quizItemsArray];
//    [tempArray removeObjectsInArray:self.usedQuizItems];
//
//    // すでに全て出題済みのときは「nil」を返して終了
//    if ([tempArray count] == 0)
//        return nil;
//
//    // 返す問題を決定する
//    NSInteger ind = indicatedNo;
//
//    // 返す問題を取得する
//    QuizItem *item = [tempArray objectAtIndex:ind];
//
//    // 使用済みの配列に追加する
//    [_usedQuizItems addObject:item];
//
//    // 取得した問題を返す
//    return item;
//}

// 出題済みの情報をクリアするメソッド
- (void)clear
{
    // 出題済みの配列を空にする
    [_usedQuizItems removeAllObjects];
}

// txtデータファイルからクイズデータを読み込むメソッド(このプログラムでは使わずにreadFromCSVを使用)
//- (BOOL)readFromFile:(NSString *)filePath
//{
//    // ファイルを読み込む
//    NSString *fileData;
//    fileData = [NSString stringWithContentsOfFile:filePath
//                                         encoding:NSUTF8StringEncoding
//                                            error:NULL];
//    
//    NSMutableArray *arrMCategory = [NSMutableArray array];
//    
//    if (!fileData)
//        return NO;  // 読み込み失敗
//    
//    // 改行文字で分割する
//    NSArray *linesArray = [fileData componentsSeparatedByString:@"\n"];
//    if (!linesArray || [linesArray count] == 0)
//        return NO;  // ファイルの内容が正しくない
//    
//    // ファイルの内容を解析する
//    NSMutableArray *newItemsArray = [NSMutableArray array];
//    QuizItem *curItem = nil;
//    NSMutableArray *curChoices = nil;
//    
//    for (NSString *line in linesArray)//lineは個別の要素(カンマ区切りのトークン要素)
//    {
//        @autoreleasepool
//        {
//            // 空白行のときはブロックの終了
//            if ([line length] == 0)
//            {
//                if (curItem && curChoices)
//                {
//                    // 選択肢を決定
//                    curItem.choicesArray = curChoices;
//                    
//                    // 配列にクイズデータを追加
//                    [newItemsArray addObject:curItem];
//                }
//                
//                // クリア
//                curItem = nil;
//                curChoices = nil;
//            }
//            else
//            {
//                // 作成中の「QuizItem」クラスのインスタンスがなければ
//                // 確保する
//                if (!curItem)
//                {
//                    //alloc(allocation)で生成して、initで初期化する
//                    curItem = [[QuizItem alloc] init];
//                    curChoices = [[NSMutableArray alloc] init];
//                }
//                
//                // プロパティ「question」が設定されていないときは
//                // この行は問題文
//                if (!curItem.question)
//                {
//                    curItem.question = line;
//                    
//                    NSLog(@"question(%d) = %@", [arrMCategory containsObject:line], line);
//                    if(![arrMCategory containsObject:line]){
//                        [arrMCategory addObject:line];
//                    }
//                }
//                else
//                {
//                    // プロパティ「rightAnswer」が設定されていないときは
//                    // この行は正解
//                    if (!curItem.rightAnswer)
//                    {
//                        curItem.rightAnswer = line;
//                    }
//                    
//                    // 選択肢の配列に追加
//                    [curChoices addObject:line];
//                }
//            }
//        }
//    }//for-loop
//    
//    // 最後のクイズデータを登録する
//    if (curItem && curChoices)
//    {
//        // 選択肢を決定
//        curItem.choicesArray = curChoices;
//        
//        // 配列にクイズデータを追加
//        [newItemsArray addObject:curItem];
//    }
//    
//    // プロパティにセット
//    self.quizItemsArray = newItemsArray;
//    
//    
//    
//    //カテゴリを追加
//    self.arrCategory = (NSArray *)arrMCategory;
//    
//    return YES;
//}


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
    NSMutableArray *newItemsArray = [NSMutableArray array];
    QuizItem *curItem = nil;//Current Item
    NSMutableArray *curChoices = nil;//Current Choices
    
    NSMutableArray *arrMCategory = [NSMutableArray array];
    
    //一行の中でカンマに区切られた値
    //   0      1       2       3     4     5  6  7  8    9         10  11
    //【章番号、問題番号、問題種別、質問文、選択肢１、２、３、４、５、正解番号、正解文章、解説
    NSArray *eachInLine = nil;
    
    for (NSString *line in linesArray)
    {
        NSLog(@"line = %@", line);
        @autoreleasepool
        {
            //最終行ならば終了
            //if([line isEqualToString:@"[EOF]"]){
            if([line rangeOfString:@"[EOF]"].location != NSNotFound){
                break;//for-loopの終了条件がlineArrayの個数だけなのでこの終了判定は不要だけど念のため！
            }else{
                NSLog(@"curItem = %@", curItem);
                // 作成中の「QuizItem」クラスのインスタンスがなければ確保する
                if (!curItem){
                    //alloc(allocation)で生成して、initで初期化する
                    curItem = [[QuizItem alloc] init];
                    curChoices = [[NSMutableArray alloc] init];
                }
                
                //カンマで区切られた各項目をeachInLine配列に格納する
                eachInLine = [line componentsSeparatedByString:@","];
                
                
                if(!(([[eachInLine objectAtIndex:0] isEqualToString:@"[EOF]"])||
                     ([[eachInLine objectAtIndex:0] isEqualToString:@"章番号"]))){//最初と最後の行でなければ
                    
                    
                    
                    NSString *sectionNo = [eachInLine objectAtIndex:0];//SECT001
                    //                NSString *questionNo_temp = [eachInLine objectAtIndex:1];
                    //                NSString *questionNo = [questionNo_temp substringWithRange:NSMakeRange(1,3)];
                    //                NSString *questionNo_temp = [@"abcdefgh" substringWithRange:NSMakeRange(1,3)];
                    //                NSString *questionNo = [questionNo_temp substringWithRange:NSMakeRange(1, 3)];
                    //                NSString *questionNo = [eachInLine objectAtIndex:1];
                    //                NSString *questionNo = [@"Q0010" substringWithRange:NSMakeRange(1,3)];
                    NSString *questionNo = [eachInLine objectAtIndex:1];
                    int intQuestionNo = (int)[[questionNo substringWithRange:NSMakeRange(1, 3)] integerValue];
                    //                    NSLog(@"%@", questionNo);
                    NSString *questionStr = [eachInLine objectAtIndex:2];
                    NSString *sentence =[eachInLine objectAtIndex:3];
                    //カンマで区切られた各項目eachを個別に分割
                    //                curItem.question = [NSString stringWithFormat:@"【%@】No%@ 〜 %@ 〜\n %@",
                    //                                    sectionNo,
                    //                                    questionNo,
                    //                                    questionStr,
                    //                                    sentence];
                    curItem.sectorName = sectionNo;
                    if(self.section == 0){
                        self.section = (int)[[sectionNo substringFromIndex:((NSString *)sectionNo).length-3] integerValue];
                        NSLog(@"section ======== %d", self.section);
                    }
                    curItem.questionNo = questionNo;
                    curItem.intQuestionNo = intQuestionNo;
                    
                    
                    NSLog(@"question(%d) = %@", [arrMCategory containsObject:questionStr], questionStr);
                    if(![arrMCategory containsObject:questionStr]){
                        [arrMCategory addObject:questionStr];
                    }
                    
                    
                    //過去の回答履歴を取得
                    NSUserDefaults* eachQuestionDefaults = [NSUserDefaults standardUserDefaults];
                    NSInteger answering = [eachQuestionDefaults stringForKey:[NSString stringWithFormat:@"Answer%@%@", sectionNo, questionNo]].integerValue;
                    NSInteger UncorrectAns = [eachQuestionDefaults stringForKey:[NSString stringWithFormat:@"UncorrectAns%@%@", sectionNo, questionNo]].integerValue;
                    NSLog(@"%@", [NSString stringWithFormat:@"UncorrectAns%@%@", sectionNo, questionNo]);
                    NSString* seikairitu = @"0";
                    
                    if(answering != 0){
                        seikairitu = [NSString stringWithFormat:@"%d",
                                      (int)(((double)answering - (double)UncorrectAns)/(double)answering * 100.0f)];
                    }
                    //                    NSLog(@"%@", seikairitu);
                    questionNo = [questionNo substringWithRange:NSMakeRange(1,3)];//="XXX"
                    questionNo = [NSString stringWithFormat:@"No%@",
                                  [NSString stringWithFormat:@"%d",[questionNo intValue]]];//="NoX"
//                    curItem.question = [NSString stringWithFormat:@"【%@】%@:解答回数:%ld回, 正解率%@%%\n %@",
//                                        questionStr,
//                                        questionNo,
//                                        answering,
//                                        seikairitu,
//                                        sentence];
                    curItem.category = questionStr;
                    curItem.question = sentence;
                    curItem.seikai = [NSString stringWithFormat:@"%d", (int)answering - (int)UncorrectAns];
                    curItem.kaitou = [NSString stringWithFormat:@"%d", (int)answering];
                    NSLog(@"seikai = %@", curItem.seikai);
                    NSLog(@"kaitou = %@", curItem.kaitou);
                    
                    curItem.rightNo = (int)[[eachInLine objectAtIndex:9] integerValue];//right answer No;
                    curItem.rightAnswer = [eachInLine objectAtIndex:10];//right answer string
                    curItem.explanation = [eachInLine objectAtIndex:11];//kaisetu
                    
                    // 選択肢の配列に追加
                    for(int selectionIndex = 4;selectionIndex < 9;selectionIndex ++){
                        [curChoices addObject:[eachInLine objectAtIndex:selectionIndex]];
                        
                        //                        [curChoices addObject:[NSString stringWithFormat:@"(%d)%@",
                        //                                               selectionIndex - 3,
                        //                                               [eachInLine objectAtIndex:selectionIndex]]];
                    }
                    
                    //空白行である場合、txtファイルであれば選択肢を決定させる必要があるが、
                    //csvファイルである場合に空白行はないので、改行がなされた場合にのみ以下のコードを行う
                    if (curItem && curChoices)
                    {
                        // 選択肢を決定
                        curItem.choicesArray = curChoices;
                        
                        // 配列にクイズデータを追加
                        [newItemsArray addObject:curItem];
                    }
                    
                    NSLog(@"aaaaaaaa");
                }
                
                // クリア
                curItem = nil;
                curChoices = nil;
                NSLog(@"bbbbbbb");
            }
            
            NSLog(@"ccccc");
        }
        
        NSLog(@"dddd");
    }
    
    NSLog(@"exit");
    
    // 最後のクイズデータを登録する
    if (curItem && curChoices)
    {
        // 選択肢を決定
        curItem.choicesArray = curChoices;
        
        // 配列にクイズデータを追加
        [newItemsArray addObject:curItem];
    }
    
    // プロパティにセット
    self.quizItemsArray = newItemsArray;
    
    
    self.arrCategory = (NSArray *)arrMCategory;
    
    return YES;
}


@end
