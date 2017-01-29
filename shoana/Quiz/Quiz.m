#import "Quiz.h"
#import "QuizItem.h"
#import "ResultModel.h"

@implementation Quiz{
    NSMutableArray *arrWrongNo;
}

// プロパティに対応するインスタンス変数とアクセッサメソッドの生成
@synthesize quizItemsArray = _quizItemsArray;
@synthesize usedQuizItems = _usedQuizItems;
//@synthesize isKokuhukuMode = _isKokuhukuMode;
//@synthesize jakutenNo = _jakutenNo;
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
        //_isKokuhukuMode = false;
        _arrCategory = nil;
        _strKaitoukaisu = nil;
        _strSeikaisu = nil;
        _section  = 0;
        
//        self.isOrdered = YES;
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
        //_isKokuhukuMode = isKokuhuku;
        
        arrWrongNo = [NSMutableArray array];
        //ResultModel *myResultModel = [[ResultModel alloc]initWithSection:nil];//代入必要！
        
        
    }
    
    return self;
}

-(int)nextQuiz:(int)nowNo{
    int returnValue = -1;
    
    if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_STANDARD] ||
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_NO_EXP] ||
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST]){
        returnValue = nowNo + 1;
    }else if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_JAKUTEN]){
        //既出問題の格納
        NSMutableArray *arrNew = [NSMutableArray arrayWithArray:self.quizItemsArray];
        [arrNew removeObjectsInArray:self.usedQuizItems];
        int noInNew = (int)random() % [arrNew count];
        returnValue = (int)[arrNew[noInNew] integerValue];
        arrNew = nil;
    }else if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST_RANDOM]){
        //未実装
        //弱点克服モードの場合、過去に誤った問題が一個もない場合があるので、その場合はDetialViewCon側で通常モードにしてあげて、このクラスで一個もない状態にならないようにしてあげる必要がある
        //最初にself.quizItemsArrayの中に過去誤った問題だけを設定する
    }else{
        //フラグなしの場合（万が一）
        returnValue = nowNo + 1;
    }
    
    
    
//    //以下でやっていることを上記に実現して行く（途中）
//    if(self.isOrdered){
//        returnValue = nowNo + 1;
//    }else if(self.isRandom){
//        
//        //既出問題の格納
//        NSMutableArray *arrNew = [NSMutableArray arrayWithArray:self.quizItemsArray];
//        [arrNew removeObjectsInArray:self.usedQuizItems];
//        int noInNew = (int)random() % [arrNew count];
//        returnValue = (int)[arrNew[noInNew] integerValue];
//        arrNew = nil;
//    }else if(self.isKokuhukuMode){
//        
//    
//    }else{
//        //フラグの立て忘れの場合はisOrderedとする
//        returnValue = nowNo + 1;
//    }
    
    
    [self.usedQuizItems addObject:[NSNumber numberWithInt:returnValue]];
    
    for(int i = 0;i<self.usedQuizItems.count;i++){
        NSLog(@"used[%d] = %@", i, self.usedQuizItems[i]);
    }
    NSLog(@"nowNo = %d", returnValue);
    
    return returnValue;
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
                    NSString *questionNo = [eachInLine objectAtIndex:1];//Q0010
                    int intQuestionNo = (int)[[questionNo substringWithRange:NSMakeRange(1, 3)] integerValue];
                    NSString *questionStr = [eachInLine objectAtIndex:2];
                    NSString *sentence =[eachInLine objectAtIndex:3];
                    curItem.sectorName = sectionNo;
                    if(self.section == 0){
                        self.section = (int)[[sectionNo substringFromIndex:((NSString *)sectionNo).length-3] integerValue];
                        NSLog(@"section ======== %d", self.section);
                    }
                    
                    
                    
                    NSLog(@"question(%d) = %@", [arrMCategory containsObject:questionStr], questionStr);
                    if(![arrMCategory containsObject:questionStr]){
                        [arrMCategory addObject:questionStr];
                    }
                    
                    NSString *strQuestionNo = [questionNo substringWithRange:NSMakeRange(1,3)];//"Q0010"->"001"
                    questionNo = [NSString stringWithFormat:@"%@",
                                  [NSString stringWithFormat:@"%d",[strQuestionNo intValue]]];//="001"->"1"
                    curItem.questionNo = questionNo;
                    curItem.intQuestionNo = intQuestionNo;
                    
                    ResultModel *myResultModel = [[ResultModel alloc] initWithSection:self];
                    curItem.kaitou = [NSString stringWithFormat:@"%d", [myResultModel getAnswer:[questionNo intValue]]];
                    curItem.seikai = [NSString stringWithFormat:@"%d", [myResultModel getCorrect:[questionNo intValue]]];
                    
                    
                    curItem.category = questionStr;
                    curItem.question = sentence;
                    curItem.rightNo = (int)[[eachInLine objectAtIndex:9] integerValue];//right answer No;
                    curItem.rightAnswer = [eachInLine objectAtIndex:10];//right answer string
                    curItem.explanation = [eachInLine objectAtIndex:11];//kaisetu
                    
                    // 選択肢の配列に追加
                    for(int selectionIndex = 4;selectionIndex < 9;selectionIndex ++){
                        [curChoices addObject:[eachInLine objectAtIndex:selectionIndex]];
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
    
    
    self.arrCategory = (NSArray *)arrMCategory;
    
    return YES;
}

//self.quizItemsArrayがMutableではないため全部入れ替える
-(BOOL)updateAllResult{
    ResultModel *myResultModel = [[ResultModel alloc] initWithSection:self];
    NSMutableArray *arrQuizItems_tmp = [NSMutableArray array];
    for(int i = 0;i < self.quizItemsArray.count;i++){
        
        @autoreleasepool {
            
            QuizItem *tmpQuizItem = self.quizItemsArray[i];
            tmpQuizItem.seikai = [NSString stringWithFormat:@"%d", [myResultModel getCorrect:i]];
            tmpQuizItem.kaitou = [NSString stringWithFormat:@"%d", [myResultModel getAnswer:i]];
            [arrQuizItems_tmp addObject:tmpQuizItem];
            tmpQuizItem = nil;
        }
    }
    
    self.quizItemsArray = (NSArray *)arrQuizItems_tmp;
    
    return YES;
}

@end
