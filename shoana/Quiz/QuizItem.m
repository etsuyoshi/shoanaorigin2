#import "QuizItem.h"
#import "ResultModel.h"

@implementation QuizItem

// プロパティに対応するインスタンス変数とアクセッサメソッドの生成
@synthesize sectorName = _sectorName;
@synthesize category = _category;
@synthesize questionNo = _questionNo;
@synthesize question = _question;
@synthesize rightAnswer = _rightAnswer;
@synthesize choicesArray = _choicesArray;
@synthesize explanation = _explanation;
@synthesize kaitou = _kaitou;
@synthesize seikai = _seikai;
@synthesize gotou = _gotou;

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
        _rightAnswer = nil;
        _choicesArray = nil;
        _explanation = nil;
        _kaitou = nil;
        _seikai = nil;
        _gotou = nil;
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
    remainArray = [NSMutableArray arrayWithArray:self.choicesArray];
    
    /*
     // すべて取り出すまで繰り返す
     while ([remainArray count] > 0)
     {
     // 乱数で取り出すインデックス番号を決定する
     NSInteger ind;
     ind = random() % [remainArray count];
     
     // 配列から取り出して、並び替えた配列に格納する
     [newArray addObject:[remainArray objectAtIndex:ind]];
     
     // 取り出す前の配列から削除する
     [remainArray removeObjectAtIndex:ind];
     }
     */
    
    //    return newArray;//→ランダムにしないで順番通りを返す
    return remainArray;
}

// 答えが合っているかチェックするメソッド
-(BOOL)checkIsRightNo:(int)answerNo{
    return answerNo == self.rightNo;
}


@end
