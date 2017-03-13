//
//  Siwake.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/02/26.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SiwakeItem.h"
#import "Quiz.h"

//@interface Siwake : NSObject
@interface Siwake : Quiz


//@property (strong, nonatomic) NSString *sectionName;
//@property int section;

// クイズのカテゴリ名称
@property (retain, nonatomic) NSArray *arrCategory;
// クイズデータの配列
@property (retain, nonatomic) NSArray *siwakeItemsArray;

// 出題済みの配列
@property (retain, nonatomic) NSMutableArray *usedSiwakeItems;


//@property (strong, nonatomic) NSString *strConfigKey;

// 次の問題を返すメソッド
- (int)nextSiwake:(int)nowNo;

//- (id)initWithKokuhukuMode:(int)indicatedNo;
- (id)initWithKokuhuku:(BOOL)isKokuhuku;

// 出題済みの情報をクリアするメソッド
- (void)clear;

//CSVファイルからクイズデータを読み込むメソッド
- (BOOL)readFromCSV:(NSString *)filePath;
- (BOOL)updateAllResult;

@end
