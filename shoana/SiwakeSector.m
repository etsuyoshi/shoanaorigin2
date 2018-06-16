//
//  SiwakeSector.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/03/06.
//  Copyright © 2017年 com.endo. All rights reserved.
//


#import "SiwakeSector.h"

@implementation SiwakeSector


// 初期化処理
- (id)init
{
    self = [super init];
    if (self)
    {
        // インスタンス変数の初期化
        self.quizSectsArray = [NSMutableArray array];
    }
    return self;
}


/*
 * 全csvファイルを読み込む（連番で存在するまで）
 */
-(BOOL)readAll{
#ifdef QUIZ_FLAG
    NSArray *arrKamoku = @[@"shoanakeizai", @"shoanazaimu", @"shoanaportfolio"];
    for(int kamoku = 0;kamoku < arrKamoku.count;kamoku++){
        for(int sect = 1;sect < 100;sect++){
            @autoreleasepool {
                NSString *strKamoku = arrKamoku[kamoku];
                BOOL isSuccess = [self readData:sect kamoku:strKamoku];
                if(!isSuccess){//when failure
                    NSLog(@"all file reading finsihed!!");
                    break;
                }else{
                    NSLog(@"shoanakeizai%03d reading... success!", sect);
                }
                strKamoku = nil;
            }
        }
    }
#else
    //仕訳問題
    for(int noSection = 1;noSection <= 8;noSection++){
        [self readData:noSection kamoku:@"siwake"];
    }
#endif

    if(self.quizSectsArray.count > 0){
        return TRUE;
    }else{
        return FALSE;
    }
    
}


-(BOOL)readData:(int)noSection kamoku:(NSString *)strKamoku{
    // クイズ出題画面用のビューコントローラを取得するための入れ物
    //QuizRunningViewController *vc;
    //NSString *fileName = [NSString stringWithFormat:@"shoanakeizai%03d", noSection];
    NSString *fileName = [NSString stringWithFormat:@"%@%03d", strKamoku, noSection];
    
    
    // クイズデータを読み込む
    Siwake *siwake = [[Siwake alloc]init];
    
    //quiz.sectionName = strKamoku;
    //@[@"shoanakeizai", @"shoanazaimu", @"shoanaportfolio"];
//    if([strKamoku isEqualToString:@"shoanakeizai"]){
//        quiz.sectionName = @"経済";
//    }else if([strKamoku isEqualToString:@"shoanazaimu"]){
//        quiz.sectionName = @"財務";
//    }else if([strKamoku isEqualToString:@"shoanaportfolio"]){
//        quiz.sectionName = @"ポートフォリオ";
//    }
    siwake.sectionName = @"仕訳";
    //self.quiz = [[Quiz alloc] init];
    
    // クイズデータのファイルパスを取得する
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    
    
    path = [bundle pathForResource:fileName ofType:@"csv"];
    
    //pathは存在しなければnullになる！
    if(!path){
        return FALSE;
    }
    
    // ファイルから読み込んで、ローカル変数quizデータに格納する
    //[quiz readFromCSV:path];
    [siwake readFromCSV:path];
    
    
    //[self.quizSectsArray addObject:quiz];
    [self.quizSectsArray addObject:siwake];
    
    
    // 2回目以降の場合があるので、出題済みの情報をクリアする
    //        [self.quiz clear];
    
    // クイズ出題画面用のビューコントローラを取得する
    //vc = segue.destinationViewController;
    
    // クイズ情報を設定する
    //        [vc setQuiz:self.quiz];
    //[vc setQuiz:quiz];
    return TRUE;
}



@end
