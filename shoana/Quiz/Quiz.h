#import <Foundation/Foundation.h>
#import "QuizItem.h"
// クラスが存在することを宣言
//@class QuizItem;

@interface Quiz : NSObject

// クイズデータの配列
@property (retain, nonatomic) NSArray *quizItemsArray;

// 出題済みの配列
@property (retain, nonatomic) NSMutableArray *usedQuizItems;

@property (nonatomic) BOOL isKokuhukuMode;
@property (nonatomic) int jakutenNo;

// 次の問題を返すメソッド
- (QuizItem *)nextQuiz;
//- (NewQuizItem *)indicatedQuiz:(int)indicatedNo;

- (id)initWithKokuhukuMode:(int)indicatedNo;

// 出題済みの情報をクリアするメソッド
- (void)clear;

// データファイルからクイズデータを読み込むメソッド
- (BOOL)readFromFile:(NSString *)filePath;

//CSVファイルからクイズデータを読み込むメソッド
- (BOOL)readFromCSV:(NSString *)filePath;

@end
