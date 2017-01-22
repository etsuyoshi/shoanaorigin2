//
//  MasterViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//

/*
 * 問題：節=QuizSector(Quiz配列を保有)
 *      章=Quiz(QuizItem配列を保有)
 *      問=QuizItem
 */


/*
 * to do :全部終わったら戻る、正誤表示、成績表（回答数、誤答数を表示したテーブルビュー→タップしたら間違えたカテゴリ分布＠パイチャート）
 */

//#import "Quiz.h"
#import "QuizSector.h"
#import "MasterTableViewCell.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ResultViewController.h"
#import "ResultModel.h"
#import "ConfigViewController.h"

//test
#import "PieChartViewController.h"

@interface MasterViewController (){
    //NSMutableArray *arrMRatioCorrects;
    NSMutableArray *arrMAnswers;
    NSMutableArray *arrMCorrects;
}

@property NSMutableArray *objects;
@end

@implementation MasterViewController

@synthesize quiz = _quiz;
QuizSector *quizSector;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    UINib *nib = [UINib nibWithNibName:@"MasterTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"masterCell"];
    
    
    //全ファイル読み込み実行
    quizSector = [[QuizSector alloc]init];
    [quizSector readAll];//全csvデータ読み込み
    
    
    //arrMRatioCorrects = [NSMutableArray array];
    arrMAnswers = [NSMutableArray array];
    arrMCorrects = [NSMutableArray array];
    for(int i = 0;i < quizSector.quizSectsArray.count;i++){
        @autoreleasepool {
            Quiz *tmpQuiz = (Quiz *)quizSector.quizSectsArray[i];
            ResultModel *myResultModel = [[ResultModel alloc] initWithSection:tmpQuiz];
            
            int sumAnswer = 0;
            int sumCorrect = 0;
            for(int j = 0;j < tmpQuiz.quizItemsArray.count;j++){
                //セクションごとに回答率をarrMRatioCorrectsに格納する(未回答なら-1とする)
                NSLog(@"get answer = %d", [myResultModel getAnswer:j]);
                NSLog(@"get correct = %d", [myResultModel getCorrects:j]);
                sumAnswer += [myResultModel getAnswer:j];
                sumCorrect += [myResultModel getCorrects:j];
                
            }
            //[arrMRatioCorrects addObject:[NSNumber numberWithInteger:sum]];
            [arrMAnswers addObject:[NSNumber numberWithInteger:sumAnswer]];
            [arrMCorrects addObject:[NSNumber numberWithInteger:sumCorrect]];
            
            tmpQuiz = nil;
            myResultModel = nil;
            
        }
    }
    
    
    // UIBarButtonItemに表示文字列を渡して、インスタンス化します。
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc]
                            initWithTitle:@"成績"
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(goResult)];
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
                                initWithTitle:@"設定"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(goConfig)];
    
    // ナビゲーションバーの左側に追加する。
    self.navigationItem.rightBarButtonItem = btnRight;
    self.navigationItem.leftBarButtonItem = btnLeft;
    
    
}

-(void)goConfig{
    NSLog(@"%s", __func__);
    
    ConfigViewController *confViewCon = [[ConfigViewController alloc]init];
    [self.navigationController pushViewController:confViewCon animated:YES];
}

-(void)goResult{
    NSLog(@"%s", __func__);
    
    ResultViewController *resultViewCon = [[ResultViewController alloc] init];
//    PieChartViewController *resultViewCon = [[PieChartViewController alloc]init];
    [self.navigationController pushViewController:resultViewCon animated:YES];
}




- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        //controller.quiz = self.quiz;
        //[controller setDetailItem:object];
        [controller setQuiz:(Quiz *)(self.quiz)];
        controller.quizNo = 0;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return quizSector.quizSectsArray.count;
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return self.objects.count;
    NSLog(@"count = %ld", quizSector.quizSectsArray.count);
    //return _quiz.quizItemsArray.count;
    return quizSector.quizSectsArray.count;
    //return ((Quiz *)quizSector.quizSectsArray[section]).quizItemsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"masterCell" forIndexPath:indexPath];
    MasterTableViewCell *cell = (MasterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"masterCell" forIndexPath:indexPath];
    NSLog(@"%s, indexpath.row = %d", __func__, (int)indexPath.row);
    @autoreleasepool {
        Quiz *quiz = (Quiz *)quizSector.quizSectsArray[indexPath.row];
        QuizItem *quizItem = quiz.quizItemsArray[0];
        
        cell.lbl_sector.text = quizItem.sectorName;
        //cell.lbl_name.text = [NSString stringWithFormat:@"概要%ld", indexPath.row];
        cell.lbl_name.text = [[quiz.arrCategory subarrayWithRange:NSMakeRange(0, 2)] componentsJoinedByString:@","];//先頭の上位要素のみ取得
        
        //cell.lbl_seitouritu.text = [NSString stringWithFormat:@"%@", arrMRatioCorrects[indexPath.row]];
        NSString *strSeitouritu = nil;
        if([arrMAnswers[indexPath.row] integerValue] > 0){
            strSeitouritu = [NSString stringWithFormat:@"%d/%d(正答率:%@%%)",
                                       (int)[arrMCorrects[indexPath.row] integerValue],
                                       (int)[arrMAnswers[indexPath.row] integerValue],
                                       [NSString stringWithFormat:@"%3.1f",
                                        (float)[arrMCorrects[indexPath.row] integerValue]/
                                        (float)[arrMAnswers[indexPath.row] integerValue]*100]];
        }else{
            strSeitouritu = @"未回答";
        }
        cell.lbl_seitouritu.text = strSeitouritu;
                                   
    }

//    NSDate *object = self.objects[indexPath.row];
//    cell.textLabel.text = [object description];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
//    return YES;
    return NO;
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSDate *object = self.objects[indexPath.row];
//    DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
    DetailViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"detail"];
    //NSLog(@"sending quiz = %@", quizSector.quizSectsArray[indexPath.row]);
    [controller setQuiz:quizSector.quizSectsArray[indexPath.row]];
    controller.quizNo = (int)indexPath.row;
    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
}

@end
