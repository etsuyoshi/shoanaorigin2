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
 * to do :全部終わったら戻る(done)、正誤表示(done)、成績表（done:回答数、誤答数を表示したテーブルビュー→タップしたら間違えたカテゴリ分布＠パイチャート）
 * to do (done):Quizインスタンスを生成する際にQuizResultから過去の成績を取得して属性にセットする（detailviewconで使用しているため）
 * to do :masterviewconを再描画する際の回答したかどうかのフラグを作成→viewDidAppear内で設定
 * to do（次回ver） :弱点克服モードの設定(configviewconで設定＠２箇所、Quizインスタンスの設定、detailviewconでも設定不要？)
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
    BOOL didUpdate;//成績を更新するかどうかの判断（問題を解くか成績表に遷移したかどうかで判定）
    
    NSArray *arrImgCells;//セルの背景の画像名配列
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
    
    arrImgCells = [NSArray arrayWithObjects:
                   @"tokyo_tower2", @"water2", @"light", @"bird", @"building", @"desk", @"sunset", @"wood", @"aman", nil];
    //streetは暗すぎて表示に適さない
    
    //全ファイル読み込み実行
    quizSector = [[QuizSector alloc]init];
    [quizSector readAll];//全csvデータ読み込み
    
    //回答と正解数の配列セットアップ
    [self setAnswerAndCorrect];
    didUpdate = NO;//初回起動の場合は何も更新してない状況にする
    
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

-(void)setAnswerAndCorrect{
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
                NSLog(@"get correct = %d", [myResultModel getCorrect:j]);
                sumAnswer += [myResultModel getAnswer:j];
                sumCorrect += [myResultModel getCorrect:j];
                
            }
            //[arrMRatioCorrects addObject:[NSNumber numberWithInteger:sum]];
            [arrMAnswers addObject:[NSNumber numberWithInteger:sumAnswer]];
            [arrMCorrects addObject:[NSNumber numberWithInteger:sumCorrect]];
            
            tmpQuiz = nil;
            myResultModel = nil;
            
        }
    }
    
}

-(void)goConfig{
    NSLog(@"%s", __func__);
    didUpdate = YES;//成績表を更新する可能性のある設定画面に遷移したらアップデートしたことにする
    ConfigViewController *confViewCon = [[ConfigViewController alloc]init];
    [self.navigationController pushViewController:confViewCon animated:YES];
}

-(void)goResult{
    NSLog(@"%s", __func__);
    
    if(quizSector.quizSectsArray.count > 0){
        ResultViewController *resultViewCon = [[ResultViewController alloc] init];
        resultViewCon.arrQuiz = quizSector.quizSectsArray;
//      PieChartViewController *resultViewCon = [[PieChartViewController alloc]init];
        [self.navigationController pushViewController:resultViewCon animated:YES];
    }
}




- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s", __func__);
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%s", __func__);
    
    
    //ステータスが変わったかどうかのフラグ
    if(didUpdate){//成績表を更新した場合に限って更新する
        for(int i = 0;i < quizSector.quizSectsArray.count;i++){
            @autoreleasepool {
                Quiz *tmpQuiz = quizSector.quizSectsArray[i];
                [tmpQuiz updateAllResult];
                quizSector.quizSectsArray[i] = tmpQuiz;
            }
        }
        [self setAnswerAndCorrect];
        
        [self.tableView reloadData];
        didUpdate = NO;//次回以降更新しないように最新状態であるようにする
    }
    
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
        [self.quiz updateAllResult];//解答状況を最新にする
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
    MasterTableViewCell *cell = (MasterTableViewCell *)
    [tableView dequeueReusableCellWithIdentifier:@"masterCell" forIndexPath:indexPath];
    
//    MasterTableViewCell *cell =
//    (MasterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"masterCell"];
//    if(!cell){
//        cell = [[MasterTableViewCell alloc]
//        initWithStyle:UITableViewCellStyleDefault
//                reuseIdentifier:@"masterCell"];
////        [[UITableViewCell alloc]
////                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"masterCell"];
//    }
    
        
    //背景画像の設定
    cell.img_back.image = [UIImage imageNamed:arrImgCells[indexPath.row % (int)arrImgCells.count]];
    NSLog(@"%s, indexpath.row = %d, %@",
          __func__, (int)indexPath.row,
          (NSString *)arrImgCells[indexPath.row % (int)arrImgCells.count]);
    
    
    //セル上の表示文言の設定
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
        
        
        
        //lbl_seitourituにグラデーションレイヤーを付ける場合
//        NSLog(@"layer count = %ld", cell.lbl_seitouritu.layer.sublayers.count);
//        //cell.lbl_seitouritu.layer.sublayers = nil;//なんども上塗りしないように
//        //ある一定以上のレイヤーを削除する(以下で追加したレイヤーのため）
//        if(cell.lbl_seitouritu.layer.sublayers.count > 10){
//            for(int i = 10;i < cell.lbl_seitouritu.layer.sublayers.count;i++){
//                [cell.lbl_seitouritu.layer.sublayers[i] removeFromSuperlayer];
//            }
//        }
//        
//        CAGradientLayer *gradient = [CAGradientLayer layer];
//        gradient.frame = cell.lbl_seitouritu.bounds;
//        gradient.colors =
//        [NSArray arrayWithObjects:
//         (id)[[UIColor colorWithWhite:1.f alpha:0.1f]CGColor],
//         (id)[[UIColor whiteColor]CGColor], nil];
//        [cell.lbl_seitouritu.layer addSublayer:gradient];
        
        
                                   
    }

    
    
    
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
    didUpdate = YES;//問題を解いた（解こうとした）場合に更新したことにする
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
