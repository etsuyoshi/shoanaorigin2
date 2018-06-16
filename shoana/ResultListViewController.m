//
//  ResultListViewController.m
//  shoana
//
//  Created by Tsuyoshi Endo on 2018/06/03.
//  Copyright © 2018年 com.endo. All rights reserved.
//
// tableviewでX問(回答数)中、Y問を間違えています。

#ifdef QUIZ_FLAG
#import "QuizSector.h"
#else
#import "SiwakeSector.h"
#endif



#import "DetailViewController.h"
#import "ResultListViewController.h"
@import Charts;

@interface ResultListViewController (){
    UITableView *tableView;
    
    //cell表示コンテンツ
    NSMutableArray *arrSectionContents;
    NSMutableArray *arrSectionType;
    
    //sect0[row0, row1, row2, ...], sect1[row0, row1, row2, ...]
    NSMutableArray *arrQuestionSectionNo;
    
}

@end

@implementation ResultListViewController
#ifdef QUIZ_FLAG
    QuizSector *quizSectorResult;
#else
    SiwakeSector *siwakeSectorResult;
#endif


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"誤答問題（誤答回数順）";
    
#ifdef QUIZ_FLAG
    //全ファイル読み込み実行
    quizSectorResult = [[QuizSector alloc]init];
    [quizSectorResult readAll];//全csvデータ読み込み
    
    
#else
    siwakeSectorResult = [[SiwakeSector alloc]init];
    [siwakeSectorResult readAll];
    
#endif
    
    
    
    
    
    tableView=
    [[UITableView alloc]
     initWithFrame:self.view.bounds
     style:UITableViewStyleGrouped];
    
    tableView.backgroundColor = [UIColor whiteColor];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    //以下３配列の要素は全てsectionベース（各要素の中に問題文の配列が格納. i.e.2次元配列)
    arrSectionContents = [NSMutableArray new];
    arrSectionType = [NSMutableArray new];
    arrQuestionSectionNo = [NSMutableArray new];
    @autoreleasepool{
#ifdef QUIZ_FLAG
        for(Quiz *quiz in quizSectorResult.quizSectsArray){
#else
        for(Siwake *quiz in SiwakeSectorResult.quizSectsArray){
#endif
            [quiz updateAllResult];//なぜかデータ更新(userDef探索)しないと正しいデータが入らない
            NSMutableArray *arrCellContents = [NSMutableArray new];
            NSMutableArray *arrCellType = [NSMutableArray new];
            NSMutableArray *arrNo = [NSMutableArray new];
            
            
            NSArray *arrQuizItems = [(Quiz *)quiz getArrayWithSortByMistakes];
            int index_row = 0;
            for(QuizItem *tmpItem in arrQuizItems){
                
                int gotou = (int)[tmpItem.kaitou integerValue] - (int)[tmpItem.seikai integerValue];
                
                if(gotou > 0){
                    NSString *strContents = [NSString stringWithFormat:@"問%d(%d回不正解):%@",
                                             tmpItem.intQuestionNo,
                                             gotou,
                                             tmpItem.question];
                    [arrCellContents addObject:strContents];
                    [arrCellType addObject: [NSNumber numberWithInteger:1]];
                    [arrNo addObject:[NSNumber numberWithInteger:tmpItem.intQuestionNo]];
                    strContents = nil;
                }
                index_row = index_row + 1;
            }
            arrQuizItems = nil;
            if([arrCellContents count] == 0){
                [arrCellContents addObject:[NSString stringWithFormat:@"不正解した問題はありません"]];
                [arrCellType addObject: [NSNumber numberWithInteger:0]];
                [arrNo addObject:@"-"];
            }
            [arrSectionContents addObject:arrCellContents];
            [arrSectionType addObject:arrCellType];
            [arrQuestionSectionNo addObject:arrNo];
            
            arrCellContents = nil;
            arrCellType = nil;
            arrNo = nil;
        }
    }
    
    //テーブル更新
    [tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
#ifdef QUIZ_FLAG
    NSLog(@"quiz sector count = %ld", (int)quizSectorResult.quizSectsArray.count);
    return quizSectorResult.quizSectsArray.count;
#else
    NSLog(@"siwake sector count = %ld", siwakeSector.quizSectsArray.count);
    return siwakeSector.quizSectsArray.count;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numberOfRows = 0;
    //間違えた問題だけ表示する
    @autoreleasepool{
        Quiz *tmpQuiz = ((Quiz *)quizSectorResult.quizSectsArray[section]);
        numberOfRows = (int)[[tmpQuiz getArrayWithSortByMistakes] count];
        tmpQuiz = nil;
    }
    return MAX(1, numberOfRows);//必ず1以上にする
}

//バグ：指定している問題が違う
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //まずはアニメーションでdeselectするだけ
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    
    NSObject *questionNo = arrQuestionSectionNo[indexPath.section][indexPath.row];
    NSLog(@"section = %ld, row = %ld, questionNo = %@",
          indexPath.section, indexPath.row, questionNo);
    for(int i = 0 ;i < [arrQuestionSectionNo[indexPath.section] count];i++){
        NSLog(@"arrQuestionSectionNo[0][%d] = %@",
              i, arrQuestionSectionNo[0][i]);
    }
    
    
    if([questionNo isEqual:@"-"] || questionNo == nil || [questionNo isEqual:[NSNull null]]){
        return;
    }
    
#ifdef QUIZ_FLAG
    //DetailViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"detail"];
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *controller=  [stb instantiateViewControllerWithIdentifier:@"detail"];
    
    //DetailViewController *controller = [[DetailViewController alloc]init];
    Quiz *tmpQuiz = quizSectorResult.quizSectsArray[indexPath.section];
    [controller setQuiz:tmpQuiz];
    
#else
    SiwakeViewController *controller = [[SiwakeViewController alloc]init];
    //本来的にはここでインスタンス作成せずにviewdidloadで作成したグローバル変数から選択されたセル番号に応じたsiwakeセクションを返す
    Siwake *tmpSiwake = siwakeSector.quizSectsArray[indexPath.section];
    controller.siwake = tmpSiwake;
#endif
    
    controller.quizNo = (int)[(NSNumber *)questionNo integerValue]-1;
    controller.isSingle = YES;
    
    
    
    NSLog(@"quizNo @master = %d", controller.quizNo);
//    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//    controller.navigationItem.leftItemsSupplementBackButton = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
//    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//    controller.navigationItem.leftItemsSupplementBackButton = YES;
    
#ifdef QUIZ_FLAG
    tmpQuiz = nil;
#else
    tmpSiwake = nil;
#endif
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"title = %d", (int)section+1);
    
    
    @autoreleasepool {
#ifdef QUIZ_FLAG
        Quiz *quiz = (Quiz *)quizSectorResult.quizSectsArray[section];
#else
        Siwake *quiz = (Siwake *)siwakeSectorResult.quizSectsArray[section];
#endif
        NSString *strTitle =
        [NSString stringWithFormat:@"第%d章 %@", (int)section+1, quiz.sectionName];
        
        strTitle = [NSString stringWithFormat:@"%@, %@", strTitle,
            [[quiz.arrCategory
              subarrayWithRange:
              NSMakeRange(0, quiz.arrCategory.count>=2?2:(quiz.arrCategory.count))]//最大値２
             componentsJoinedByString:@","]];//先頭の上位要素のみ取得
    
    

        return strTitle;
    }



}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier = @"cell";
    UITableViewCell* cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    int cell_type = (int)[arrSectionType[indexPath.section][indexPath.row] integerValue];
    NSString *cell_str = arrSectionContents[indexPath.section][indexPath.row];
    
    cell.accessoryType = (cell_type==0)?UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = cell_str;
    
    
    return cell;

}

    

@end
