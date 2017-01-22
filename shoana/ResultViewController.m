//
//  ResultViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/12.
//  Copyright © 2017年 com.endo. All rights reserved.
//
@import Charts;

/*
 * 間違えた問題のみ表示→誤回答のシェアを表示
 */
#import "ResultViewController.h"

//#import "Shoana-Swift.h"

@interface ResultViewController ()<ChartViewDelegate>{
    PieChartView *pieChartView;
}

@end

@implementation ResultViewController

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
    pieChartView.descriptionText = @"チャートの説明";
    
    [self.view addSubview:pieChartView];
    
    
    [self setupPieChartView:pieChartView];
    [self updateChartData];
    [pieChartView animateWithXAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
    
    
   
    
    
    
    
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(100, 100, 100, 100);
//    btn.center  = self.view.center;
//    btn.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:btn];
//    
//    [btn addTarget:self action:@selector(tappedBtn) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateChartData{
    //NSLog(@"%s, range = %f, count = %d", __func__, range, count);
    int count = 5;//データ数
    //    double mult = range;
    double mult = .5f;//multiples:倍率
    
    NSArray *arrChartLabels =
    @[
      @"Party A", @"Party B", @"Party C", @"Party D", @"Party E", @"Party F",
      @"Party G", @"Party H", @"Party I", @"Party J", @"Party K", @"Party L",
      @"Party M", @"Party N", @"Party O", @"Party P", @"Party Q", @"Party R",
      @"Party S", @"Party T", @"Party U", @"Party V", @"Party W", @"Party X",
      @"Party Y", @"Party Z"
      ];
    
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [values addObject:
         [[PieChartDataEntry alloc]
          initWithValue:(arc4random_uniform(mult) + mult / 5)
          label:arrChartLabels[i % arrChartLabels.count]]];
    }
    
    PieChartDataSet *dataSet =
    [[PieChartDataSet alloc] initWithValues:values label:@"Election Results"];
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



- (void)setupPieChartView:(PieChartView *)chartView
{
    chartView.usePercentValuesEnabled = YES;
    chartView.drawSlicesUnderHoleEnabled = NO;
    chartView.holeRadiusPercent = 0.58;
    chartView.transparentCircleRadiusPercent = 0.61;
    chartView.chartDescription.enabled = NO;
    [chartView setExtraOffsetsWithLeft:5.f top:10.f right:5.f bottom:5.f];
    
    chartView.drawCenterTextEnabled = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"第１章成績\n100回回答中"];
    [centerText setAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f],
                                NSParagraphStyleAttributeName: paragraphStyle
                                } range:NSMakeRange(0, centerText.length)];
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f],
                                NSForegroundColorAttributeName: UIColor.grayColor
                                } range:NSMakeRange(1, centerText.length - 1)];
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.f],
                                NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]
                                } range:NSMakeRange(centerText.length - 3, 3)];
    chartView.centerAttributedText = centerText;
    
    chartView.drawHoleEnabled = YES;
    chartView.rotationAngle = 0.0;
    chartView.rotationEnabled = YES;
    chartView.highlightPerTapEnabled = YES;
    
    ChartLegend *l = chartView.legend;
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
