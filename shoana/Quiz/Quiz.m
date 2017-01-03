#import "Quiz.h"
#import "QuizItem.h"

@implementation Quiz

// プロパティに対応するインスタンス変数とアクセッサメソッドの生成
@synthesize quizItemsArray = _quizItemsArray;
@synthesize usedQuizItems = _usedQuizItems;
@synthesize isKokuhukuMode = _isKokuhukuMode;
@synthesize jakutenNo = _jakutenNo;

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
    }
    return self;
}

- (id)initWithKokuhukuMode:(int)jakutenNo{
    
    self = [super init];
    if (self)
    {
        // インスタンス変数の初期化
        _quizItemsArray = nil;
        _usedQuizItems = [[NSMutableArray alloc] init];
        
        //弱点克服モード
        _isKokuhukuMode = TRUE;
        
        //弱点の問題番号
        _jakutenNo = jakutenNo;
        
    }
    
    return self;
}

// 次の問題を返すメソッド
- (QuizItem *)nextQuiz
{
    // 使用していない問題の配列を作成する
    NSMutableArray *tempArray;
    tempArray = [NSMutableArray arrayWithArray:self.quizItemsArray];
    [tempArray removeObjectsInArray:self.usedQuizItems];
    
    // すでに全て出題済みのときは「nil」を返して終了
    if ([tempArray count] == 0)
        return nil;
    
    // 返す問題を決定する
    NSInteger ind = 0;
    if(!_isKokuhukuMode){
        ind = random() % [tempArray count];
        NSLog(@"%ld@Quiz:nextQuiz_%d", ind, _isKokuhukuMode);
    }else{
        ind = _jakutenNo - 1;//ind=0がNo001に相当する
        NSLog(@"%ld@Quiz:nextQuiz_%d", ind, _isKokuhukuMode);
    }
    
    // 返す問題を取得する
    QuizItem *item = [tempArray objectAtIndex:ind];
    
    // 使用済みの配列に追加する
    [_usedQuizItems addObject:item];
    
    // 取得した問題を返す
    return item;
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
- (BOOL)readFromFile:(NSString *)filePath
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
    QuizItem *curItem = nil;
    NSMutableArray *curChoices = nil;
    
    for (NSString *line in linesArray)
    {
        @autoreleasepool
        {
            // 空白行のときはブロックの終了
            if ([line length] == 0)
            {
                if (curItem && curChoices)
                {
                    // 選択肢を決定
                    curItem.choicesArray = curChoices;
                    
                    // 配列にクイズデータを追加
                    [newItemsArray addObject:curItem];
                }
                
                // クリア
                curItem = nil;
                curChoices = nil;
            }
            else
            {
                // 作成中の「QuizItem」クラスのインスタンスがなければ
                // 確保する
                if (!curItem)
                {
                    //alloc(allocation)で生成して、initで初期化する
                    curItem = [[QuizItem alloc] init];
                    curChoices = [[NSMutableArray alloc] init];
                }
                
                // プロパティ「question」が設定されていないときは
                // この行は問題文
                if (!curItem.question)
                {
                    curItem.question = line;
                }
                else
                {
                    // プロパティ「rightAnswer」が設定されていないときは
                    // この行は正解
                    if (!curItem.rightAnswer)
                    {
                        curItem.rightAnswer = line;
                    }
                    
                    // 選択肢の配列に追加
                    [curChoices addObject:line];
                }
            }
        }
    }//for-loop
    
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
    
    return YES;
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
    NSMutableArray *newItemsArray = [NSMutableArray array];
    QuizItem *curItem = nil;//Current Item
    NSMutableArray *curChoices = nil;//Current Choices
    
    //一行の中でカンマに区切られた値
    //   0      1       2       3     4     5  6  7  8    9         10  11
    //【章番号、問題番号、問題種別、質問文、選択肢１、２、３、４、５、正解番号、正解文章、解説
    NSArray *eachInLine = nil;
    
    for (NSString *line in linesArray)
    {
        @autoreleasepool
        {
            //最終行ならば終了
            if([line isEqualToString:@"[EOF]"]){
                break;//for-loopの終了条件がlineArrayの個数だけなのでこの終了判定は不要だけど念のため！
            }else{
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
                    
                    
                    
                    NSString *sectionNo = [eachInLine objectAtIndex:0];
                    //                NSString *questionNo_temp = [eachInLine objectAtIndex:1];
                    //                NSString *questionNo = [questionNo_temp substringWithRange:NSMakeRange(1,3)];
                    //                NSString *questionNo_temp = [@"abcdefgh" substringWithRange:NSMakeRange(1,3)];
                    //                NSString *questionNo = [questionNo_temp substringWithRange:NSMakeRange(1, 3)];
                    //                NSString *questionNo = [eachInLine objectAtIndex:1];
                    //                NSString *questionNo = [@"Q0010" substringWithRange:NSMakeRange(1,3)];
                    NSString *questionNo = [eachInLine objectAtIndex:1];
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
                    curItem.questionNo = questionNo;
                    
                    
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
                    curItem.question = [NSString stringWithFormat:@"【%@】%@:解答回数:%ld回, 正解率%@%%\n %@",
                                        questionStr,
                                        questionNo,
                                        answering,
                                        seikairitu,
                                        sentence];
                    
                    curItem.rightAnswer = [eachInLine objectAtIndex:10];
                    curItem.explanation = [eachInLine objectAtIndex:11];
                    
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
                    
                }
                
                // クリア
                curItem = nil;
                curChoices = nil;
            }
        }
    }
    
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
    
    return YES;
}


@end
