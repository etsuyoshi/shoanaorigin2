//
//  ResultViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/12.
//  Copyright © 2017年 com.endo. All rights reserved.
//

//http://scurityanalysts.han-be.com/que1_zai/1-7.html
//
@import Charts;
#import "ResultModel.h"
#import "ResultListViewController.h"


/*
 * 間違えた問題のみ表示→誤回答のシェアを表示
 */
#import "ResultViewController.h"

//#import "Shoana-Swift.h"

@interface ResultViewController ()<ChartViewDelegate>{
    PieChartView *pieChartView;
    int section;
}

@end

@implementation ResultViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setupPieChartView];
    [pieChartView animateWithXAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    pieChartView = [[PieChartView alloc]
                    initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                             self.view.bounds.size.width)];
    pieChartView.center = self.view.center;
    pieChartView.delegate = self;
    pieChartView.entryLabelColor = UIColor.whiteColor;
    pieChartView.entryLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    pieChartView.chartDescription.text = @"チャートの説明";
    pieChartView.chartDescription.enabled = NO;
    [self.view addSubview:pieChartView];

    [self updateChartData];
    
    
    //問題を全て解答した直後の成績画面であればルートに戻る終了ボタンを追加する
    if(self.isAfterQuiz){
        [self setNavigationBar];
    }else{
        //コンフィグ画面からん遷移した時のナビゲーションバー
        [self setNavigationBarFromMaster];
    }
}

-(void)setNavigationBarFromMaster{
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc]
                                initWithTitle:@"弱点リスト"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(tappedList)];
    self.navigationItem.rightBarButtonItem = btnRight;
    
}

-(void)setNavigationBar{
    
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc]
                                 initWithTitle:@"終了"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(tappedQuit)];
    // ナビゲーションバーの左側に追加する。
    self.navigationItem.rightBarButtonItem = btnRight;
    
    
    
}

//誤答問題リストへ移動
-(void)tappedList{
    ResultListViewController *listView = [[ResultListViewController alloc]init];
    [self.navigationController pushViewController:listView animated:YES];
}

//終了する
-(void)tappedQuit{
    //ダイアログを開いてイェスならばチェックマークをつける
    UIAlertController * alertController =
    [UIAlertController
     alertControllerWithTitle:@"お疲れ様でした！"
     message:@"全て終了しますか？"
     preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:
     [UIAlertAction
      actionWithTitle:@"終了する"
      style:UIAlertActionStyleDefault
      handler:^(UIAlertAction *alert){
          
          [self.navigationController popToRootViewControllerAnimated:YES];
      }]];
    
    [alertController addAction:
     [UIAlertAction
      actionWithTitle:@"キャンセル"
      style:UIAlertActionStyleCancel
      handler:^(UIAlertAction *alert){
          //何もしない
      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)updateChartData{
    //NSLog(@"%s, range = %f, count = %d", __func__, range, count);
    //int count = 5;//データ数@default
    //    double mult = range;
    //double mult = .5f;//multiples:倍率
    
    NSMutableArray *arrDataForGraph = [NSMutableArray array];
    NSMutableArray *arrLabelForGraph = [NSMutableArray array];
    
    
    NSLog(@"%s", __func__);
    NSLog(@"count = %ld", self.arrQuiz.count);
    
    
    /*
     * セクション指定があれば当該セクションにおける誤った問題番号を、なければ全セクションの誤った回数を表示する
     */

    if(self.myQuiz){//Quizインスタンスの指定があれば該当セクションのみラベルでの集計結果を表示する
#ifdef QUIZ_FLAG
        ResultModel *myResult = [[ResultModel alloc]initWithSection:self.myQuiz];
#else
        ResultModel *myResult = [[ResultModel alloc]initWithSection:(Siwake *)self.myQuiz];
#endif
        section = self.myQuiz.section;
        NSArray *arrAnswer = [myResult getAnswers];
        NSArray *arrCorrect = [myResult getCorrects];
        
        NSLog(@"arrAnswer.count = %ld", [arrAnswer count]);
        NSLog(@"arrCorrect.count = %ld", [arrCorrect count]);
        
        //問題番号別に過去に誤った回数を格納する
        if(arrAnswer){
            for(int i = 0;i < arrAnswer.count;i++){
                int numOfWrong = (int)[arrAnswer[i] integerValue] - (int)[arrCorrect[i] integerValue];
                [arrDataForGraph addObject:[NSNumber numberWithInt:numOfWrong]];
                [arrLabelForGraph addObject:[NSString stringWithFormat:@"NO.%d", i]];
            }
        }
        
        self.title = @"苦手問題";
        
    }else if(self.arrQuiz){//MasterViewConrollerから遷移した場合はこちら
        section = -1;
        
        NSLog(@"all sector mode");
        
        //セクション指定がなければi=0から100くらいまでのセクションで存在するセクションに対して集計して、誤った回数のみ集計
#ifdef QUIZ_FLAG
        for(Quiz *myQuiz in self.arrQuiz){
            @autoreleasepool {
                ResultModel *myResult = [[ResultModel alloc]initWithSection:myQuiz];
#else
        for(Siwake *myQuiz in self.arrQuiz){
            @autoreleasepool {
                ResultModel *myResult = [[ResultModel alloc]initWithSection:(Siwake *)myQuiz];
#endif
                
                
                NSArray *arrAnswer = [myResult getAnswers];
                NSArray *arrCorrect = [myResult getCorrects];
                //        NSMutableArray *arrWrongs = [NSMutableArray array];
                
                int sumAnswer = 0;
                int sumCorrect = 0;
                //問題番号別に過去に誤った回数を格納する
                if(arrAnswer){
                    for(int i = 0;i < arrAnswer.count;i++){
                        sumAnswer += (int)[arrAnswer[i] integerValue];
                        sumCorrect += (int)[arrCorrect[i] integerValue];
//                        int numOfWrong = (int)[arrAnswer[i] integerValue] - (int)[arrCorrect[i] integerValue];
                        //                [arrWrongs addObject:[NSNumber numberWithInt:numOfWrong]];
//                        [arrDataForGraph addObject:[NSNumber numberWithInt:numOfWrong]];
//                        [arrLabelForGraph addObject:[NSString stringWithFormat:@"NO.%d", i]];
                    }
                }
                
                if(sumAnswer > 0){
                    [arrDataForGraph addObject:[NSNumber numberWithInt:sumAnswer-sumCorrect]];
                
#ifdef QUIZ_FLAG
                    [arrLabelForGraph addObject:[NSString stringWithFormat:@"SECT.%d", myQuiz.section]];
#else
                    [arrLabelForGraph addObject:[NSString stringWithFormat:@"SECT.%d", ((Siwake *)myQuiz).section]];
                    
                    NSLog(@"add section = %@",
                          [NSString stringWithFormat:@"SECT.%d", ((Siwake *)myQuiz).section]);
#endif
                
                }
                
            }
        }
        self.title = @"苦手セクション";
        
    }
            
    int sumAllAnswer = 0;//全回答数
    for(int i = 0;i < arrDataForGraph.count;i++){
        sumAllAnswer += (int)[arrDataForGraph[i] integerValue];
    }
    NSLog(@"sumAllAnswer = %d", sumAllAnswer);
    
    if(sumAllAnswer == 0){
        //まだ一度も解答したことがない人
        arrDataForGraph = [NSMutableArray arrayWithObjects:
                           @10,@10,@10,@10,@10, nil];
        arrLabelForGraph = [NSMutableArray arrayWithObjects:
                            @"demo1", @"demo2", @"demo3", @"demo4", @"demo5", nil];
        
    }
//    NSArray *arrChartLabels =
//    @[
//      @"Party A", @"Party B", @"Party C", @"Party D", @"Party E", @"Party F",
//      @"Party G", @"Party H", @"Party I", @"Party J", @"Party K", @"Party L",
//      @"Party M", @"Party N", @"Party O", @"Party P", @"Party Q", @"Party R",
//      @"Party S", @"Party T", @"Party U", @"Party V", @"Party W", @"Party X",
//      @"Party Y", @"Party Z"
//      ];
    
    NSLog(@"arr data count = %ld", arrDataForGraph.count);
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrDataForGraph.count; i++)
    {
//        [values addObject:
//         [[PieChartDataEntry alloc]
//          initWithValue:(arc4random_uniform(mult) + mult / 5)
//          label:arrChartLabels[i % arrChartLabels.count]]];
        
        [values addObject:
         [[PieChartDataEntry alloc]
            initWithValue:[arrDataForGraph[i] integerValue]
                    label:arrLabelForGraph[i]]];
        
        
    }
    
    PieChartDataSet *dataSet =
    [[PieChartDataSet alloc] initWithValues:values label:@""];
    dataSet.sliceSpace = 2.0;
    
    
    // add a lot of colors
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:UIColor.whiteColor];
    
    pieChartView.data = data;
    [pieChartView highlightValues:nil];
    
}

-(void)tappedBtn{
    NSLog(@"%s", __func__);
    [self.navigationController popToRootViewControllerAnimated:YES];
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



- (void)setupPieChartView{
    NSLog(@"%s %@", __func__, pieChartView.chartDescription);
    pieChartView.usePercentValuesEnabled = YES;
    pieChartView.drawSlicesUnderHoleEnabled = NO;
    pieChartView.holeRadiusPercent = 0.58;
    pieChartView.transparentCircleRadiusPercent = 0.61;
    pieChartView.chartDescription.enabled = NO;
    [pieChartView setExtraOffsetsWithLeft:5.f top:10.f right:5.f bottom:5.f];
    pieChartView.drawCenterTextEnabled = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    //円グラフの中心に文字列を配布するならここに格納する
    NSMutableAttributedString *centerText = nil;
    
    if(self.arrQuiz){
        int countAllQuiz = 0;
        NSLog(@"array = %ld", self.arrQuiz.count);
        
#ifdef QUIZ_FLAG
        for(int i = 0;i < self.arrQuiz.count;i++){
            @autoreleasepool {
                Quiz *quiz = (Quiz *)self.arrQuiz[i];
                NSArray *arrQuizItems = quiz.quizItemsArray;
                for(int j = 0;j < arrQuizItems.count; j++){
                    QuizItem *quizItem = arrQuizItems[j];
                    NSLog(@"j = %d, quiz items kaitou = %@", j, quizItem.kaitou);
                    if(!([quizItem isEqual:[NSNull null]] ||
                       quizItem == nil)){
                        countAllQuiz += (int)[quizItem.kaitou integerValue];
                    }
                    quizItem = nil;
                }
                quiz = nil;
            }
            //NSLog(@"i=%d, quizNo = %ld", i, ((Quiz *)self.arrQuiz[i]).kai);
//            countAllQuiz += ((Quiz *)self.arrQuiz[i]).quizItemsArray.count;
        }
#else
        for(int i =0;i < self.arrQuiz.count;i++){
            countAllQuiz += ((Siwake *)self.arrQuiz[i]).siwakeItemsArray.count;
        }
#endif
        NSLog(@"countAllQuiz = %ld", countAllQuiz);
        NSString *strPlain =
        [NSString stringWithFormat:
         @"全問中誤答数\n(%ld問解答中)", countAllQuiz];
        
        centerText =
        [[NSMutableAttributedString alloc] initWithString:strPlain];
    }else if(self.myQuiz){
        
#ifdef QUIZ_FLAG
        NSString *strPlain =
        [NSString stringWithFormat:
         @"第%d章成績\n%ld問解答中",
         self.myQuiz.section,
         self.myQuiz.quizItemsArray.count];
#else
        NSString *strPlain =
        [NSString stringWithFormat:
         @"第%d章成績\n%(%ld問解答中)",
         ((Siwake *)self.myQuiz).section,
         ((Siwake *)self.myQuiz).siwakeItemsArray.count];
        
#endif
        
        centerText =
        [[NSMutableAttributedString alloc] initWithString:strPlain];
    }else{
        centerText =
        [[NSMutableAttributedString alloc] initWithString:@"第１章成績\n100問回答中"];
    }
    //NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    
    [centerText setAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f],
                                NSParagraphStyleAttributeName: paragraphStyle
                                }
                        range:NSMakeRange(0, centerText.length)];
    
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f],
                                NSForegroundColorAttributeName: UIColor.grayColor
                                }
                        range:NSMakeRange(1, centerText.length - 1)];
    
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.f],
                                NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]
                                }
                        range:NSMakeRange(6 , centerText.length - 6)];
                        //range:NSMakeRange(centerText.length - 6, 6)];
    
    pieChartView.centerAttributedText = centerText;
    
    pieChartView.drawHoleEnabled = YES;
    pieChartView.rotationAngle = 0.0;
    pieChartView.rotationEnabled = YES;
    pieChartView.highlightPerTapEnabled = YES;
    
    
    ChartLegend *l = pieChartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationVertical;
    l.drawInside = NO;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected : %@", entry);
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}



@end
