#import <Foundation/Foundation.h>

@interface QuizItem : NSObject

//章番号
@property (copy, nonatomic) NSString *sectorName;

//問題番号
@property (copy, nonatomic) NSString *questionNo;

// 問題文
@property (copy, nonatomic) NSString *question;

// 正解
@property (copy, nonatomic) NSString *rightAnswer;

// 選択肢の配列
@property (strong, nonatomic) NSArray *choicesArray;

// 説明文
@property (copy, nonatomic) NSString *explanation;


// ランダムに並び替えられた選択肢の配列
@property (readonly, nonatomic) NSArray *randomChoicesArray;

// 答えが合っているかチェックするメソッド
- (BOOL)checkIsRightAnswer:(NSString *)answer;

@end
