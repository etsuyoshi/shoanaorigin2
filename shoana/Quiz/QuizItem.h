#import <Foundation/Foundation.h>

@interface QuizItem : NSObject

//章番号
@property (copy, nonatomic) NSString *sectorName;

//章名称
@property (copy, nonatomic) NSString *category;

//問題番号
@property (copy, nonatomic) NSString *questionNo;

@property int intQuestionNo;

// 問題文
@property (copy, nonatomic) NSString *question;

@property int rightNo;

// 正解
@property (copy, nonatomic) NSString *rightAnswer;

// 選択肢の配列
@property (strong, nonatomic) NSArray *choicesArray;

// 説明文
@property (copy, nonatomic) NSString *explanation;

// 回答回数
@property (strong, nonatomic) NSString *kaitou;
@property (strong, nonatomic) NSString *seikai;


// ランダムに並び替えられた選択肢の配列
@property (readonly, nonatomic) NSArray *randomChoicesArray;

// 答えが合っているかチェックするメソッド
- (BOOL)checkIsRightAnswer:(NSString *)answer;
-(BOOL)checkIsRightNo:(int)answerNo;
@end
