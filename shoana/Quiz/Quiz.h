//章ごとの問題の集まり


#import <Foundation/Foundation.h>
// クラスが存在することを宣言
//@class QuizItem;
#import "QuizItem.h"

@interface Quiz : NSObject

@property (strong, nonatomic) NSString *sectionName;
@property int section;

// クイズのカテゴリ名称
@property (retain, nonatomic) NSArray *arrCategory;
// クイズデータの配列
@property (retain, nonatomic) NSArray *quizItemsArray;

// 出題済みの配列
@property (retain, nonatomic) NSMutableArray *usedQuizItems;


@property (strong, nonatomic) NSString *strConfigKey;
/*
 *以下、QUIZ_CONFIG_KEYを格納するバリエーション変数でカバーする（isOrderedなどは消去してgoNextメソッドなどを修正する）
 */
//@property (nonatomic) int isOrdered;
//@property (nonatomic) int isRandom;
//@property (nonatomic) BOOL isKokuhukuMode;
//@property (nonatomic) int jakutenNo;

// 次の問題を返すメソッド
- (int)nextQuiz:(int)nowNo;
//- (NewQuizItem *)indicatedQuiz:(int)indicatedNo;

//- (id)initWithKokuhukuMode:(int)indicatedNo;
- (id)initWithKokuhuku:(BOOL)isKokuhuku;

// 出題済みの情報をクリアするメソッド
- (void)clear;

// データファイルからクイズデータを読み込むメソッド
//- (BOOL)readFromFile:(NSString *)filePath;

//CSVファイルからクイズデータを読み込むメソッド
- (BOOL)readFromCSV:(NSString *)filePath;
- (BOOL)updateAllResult;

//誤った回数が多い順に問題番号を返す
-(NSArray *)getArrayWithSortByMistakes;
@end
