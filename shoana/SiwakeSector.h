//
//  SiwakeSector.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/03/06.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import "QuizSector.h"
#import "Siwake.h"

@interface SiwakeSector : QuizSector
//@property (retain, nonatomic) NSMutableArray *quizSectsArray;//defined superclass

// データファイルから全クイズデータを読み込むメソッド
- (BOOL)readAll;


@end
