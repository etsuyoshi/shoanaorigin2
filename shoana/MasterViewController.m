//
//  MasterViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//  Icon : ~/書類/workspace/学習アプリ/question
//  プロジェクト名（画面上表示名）変更方法
//  http://tech.librastudio.co.jp/index.php/2016/10/05/post-1038/

/*
 * 問題：節=QuizSector(Quiz配列を保有)
 *      章=Quiz(QuizItem配列を保有)
 *      問=QuizItem
 */

/*
 * to do :全部終わったら戻る(done)、正誤表示(done)、成績表（done:回答数、誤答数を表示したテーブルビュー→タップしたら間違えたカテゴリ分布＠パイチャート）
 * to do (done):Quizインスタンスを生成する際にQuizResultから過去の成績を取得して属性にセットする（detailviewconで使用しているため）
 * to do :(done)masterviewconを再描画する際の回答したかどうかのフラグを作成→viewDidAppear内で設定
 * to do :(done)モード選択が正しく反映されない（解説非表示モードなど）
 * to do :(done)ポートフォリオ、財務などの他科目(Quiz.sectorName)の問題の読み込み＆科目名をセルに表示する
 * to do（次回ver） :弱点克服モードの設定(configviewconで設定＠２箇所、Quizインスタンスの設定、detailviewconでも設定不要？)
 */

#import "QuizSector.h"
#import "SiwakeSector.h"
#import "MasterTableViewCell.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SiwakeViewController.h"//in case: siwake
#import "ResultViewController.h"
#import "ResultModel.h"
#import "ConfigViewController.h"

#import "Siwake.h"


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
#ifdef QUIZ_FLAG
    QuizSector *quizSector;
#else
    SiwakeSector *siwakeSector;
#endif


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
#ifdef QUIZ_FLAG
    self.title = @"証券アナリスト問題集";
#else
    self.title = @"簿記３級仕訳問題集";
#endif
    // Do any additional setup after loading the view, typically from a nib.
    
    UINib *nib = [UINib nibWithNibName:@"MasterTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"masterCell"];
    
    arrImgCells = [NSArray arrayWithObjects:
                   @"tokyo_tower2", @"water2", @"light", @"bird", @"building", @"desk", @"sunset", @"wood", @"aman", nil];
    //streetは暗すぎて表示に適さない
    
#ifdef QUIZ_FLAG
    //全ファイル読み込み実行
    quizSector = [[QuizSector alloc]init];
    [quizSector readAll];//全csvデータ読み込み
    
    
    NSLog(@"before transit kaitou = %@, seikai = %@",
          ((QuizItem *)((Quiz *)quizSector.quizSectsArray[0]).quizItemsArray[0]).kaitou,
          ((QuizItem *)((Quiz *)quizSector.quizSectsArray[0]).quizItemsArray[0]).seikai);
    
    
    
    //section=1における全questionNo,kaitou,seikai,strSentenceを見てみよう
    for(QuizItem *quizItem in ((Quiz *)quizSector.quizSectsArray[0]).quizItemsArray){
        NSLog(@"section = %@, questionNo = %d, kaitou=%@, seikai=%@, sentence=%@",
              quizItem.sectorName, quizItem.intQuestionNo, quizItem.kaitou, quizItem.seikai, quizItem.question);
    }
    
#else
    siwakeSector = [[SiwakeSector alloc]init];
    [siwakeSector readAll];
    
    NSLog(@"siwake count = %ld", ((Siwake *)siwakeSector.quizSectsArray[0]).siwakeItemsArray.count);
#endif
    
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
    
    //諸々の情報を更新する（成績表の更新がしたいのではなく、self.strConfigKeyの更新)
    [self updateInfo];
    
}

-(void)setAnswerAndCorrect{
    arrMAnswers = [NSMutableArray array];
    arrMCorrects = [NSMutableArray array];
#ifdef QUIZ_FLAG
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
#else
    for(int i = 0;i < siwakeSector.quizSectsArray.count;i++){
        @autoreleasepool {
            Siwake *tmpSiwake = (Siwake *)siwakeSector.quizSectsArray[i];
            ResultModel *myResultModel = [[ResultModel alloc] initWithSection:tmpSiwake];
            int sumAnswer = 0;
            int sumCorrect = 0;
            NSLog(@"tmpSiwake.quizItemsArray.count = %ld",
                  tmpSiwake.siwakeItemsArray.count);
            
            for(int j = 0;j < tmpSiwake.siwakeItemsArray.count;j++){
                //セクションごとに回答率をarrMRatioCorrectsに格納する(未回答なら-1とする)
                NSLog(@"get answer = %d", [myResultModel getAnswer:j]);
                NSLog(@"get correct = %d", [myResultModel getCorrect:j]);
                sumAnswer += [myResultModel getAnswer:j];
                sumCorrect += [myResultModel getCorrect:j];
                
            }
            //[arrMRatioCorrects addObject:[NSNumber numberWithInteger:sum]];
            [arrMAnswers addObject:[NSNumber numberWithInteger:sumAnswer]];
            [arrMCorrects addObject:[NSNumber numberWithInteger:sumCorrect]];
            
            tmpSiwake = nil;
            myResultModel = nil;
        }
    }
    
#endif
    
}

-(void)goConfig{
    NSLog(@"%s", __func__);
    didUpdate = YES;//成績表を更新する可能性のある設定画面に遷移したらアップデートしたことにする
    ConfigViewController *confViewCon = [[ConfigViewController alloc]init];
    [self.navigationController pushViewController:confViewCon animated:YES];
}

-(void)goResult{
    NSLog(@"%s", __func__);
    
#ifdef QUIZ_FLAG
    if(quizSector.quizSectsArray.count > 0){
        ResultViewController *resultViewCon = [[ResultViewController alloc] init];
        resultViewCon.arrQuiz = quizSector.quizSectsArray;
#else
    if(siwakeSector.quizSectsArray.count > 0){
        ResultViewController *resultViewCon = [[ResultViewController alloc] init];
        resultViewCon.arrQuiz = siwakeSector.quizSectsArray;
#endif
//      PieChartViewController *resultViewCon = [[PieChartViewController alloc]init];
        [self.navigationController pushViewController:resultViewCon animated:YES];
    }
}




- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s", __func__);
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    
    //ステータスが変わったかどうかのフラグ
    if(didUpdate){//成績表を更新した場合に限って更新する
        [self updateInfo];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%s", __func__);
    
    
    
    
}

-(void)updateInfo{
#ifdef QUIZ_FLAG
    for(int i = 0;i < quizSector.quizSectsArray.count;i++){
        @autoreleasepool {
            Quiz *tmpQuiz = quizSector.quizSectsArray[i];
            [tmpQuiz updateAllResult];
            quizSector.quizSectsArray[i] = tmpQuiz;
        }
    }
#else
    for(int i = 0;i < siwakeSector.quizSectsArray.count;i++){
        @autoreleasepool {
            Siwake *tmpSiwake = siwakeSector.quizSectsArray[i];
            [tmpSiwake updateAllResult];
            siwakeSector.quizSectsArray[i] = tmpSiwake;
        }
    }
#endif

    
    
    [self setAnswerAndCorrect];
    [self.tableView reloadData];
    
    
    
    //問題を選択した時に、どの問題（１問目）を選択するのか
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    self.strConfigKey = [userDef objectForKey:QUIZ_CONFIG_KEY];
    userDef = nil;
    
    didUpdate = NO;//次回以降更新しないように最新状態であるようにする
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        controller.quizNo = 0;
        //弱点モードの場合には最初の番号もすでに間違えた問題にする
        NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
        NSString *strConfigKey = [userdef objectForKey:QUIZ_CONFIG_KEY];
        if([strConfigKey isEqualToString:QUIZ_CONFIG_KEY_JAKUTEN]){
            
            int mistake_threahold = (int)[userdef integerForKey:USER_DEFAULTS_MISTAKE_THREASHOLD];
            
            ResultModel *resultModel = [[ResultModel alloc] initWithSection:self.quiz];
            
            //メニューボタンで選択した（できる）誤回答数の選定もできるようにする
            controller.quizNo = (int)[resultModel
                         getInCorrectWithoutNo:-1//without指定は何もない
                         withThreashold:mistake_threahold==0?1:mistake_threahold];//現在の番号以外で、過去に誤った問題番号を返す
            
        }
        //controller.quiz = self.quiz;
        //[controller setDetailItem:object];
        [self.quiz updateAllResult];//解答状況を最新にする
        [controller setQuiz:(Quiz *)(self.quiz)];
        
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
#ifdef QUIZ_FLAG
    NSLog(@"quiz sector count = %ld", quizSector.quizSectsArray.count);
    return quizSector.quizSectsArray.count;
#else
    NSLog(@"siwake sector count = %ld", siwakeSector.quizSectsArray.count);
    return siwakeSector.quizSectsArray.count;
#endif
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MasterTableViewCell *cell = (MasterTableViewCell *)
    [tableView dequeueReusableCellWithIdentifier:@"masterCell" forIndexPath:indexPath];
    
    NSLog(@"arrImgCells.count = %ld", arrImgCells.count);
    //背景画像の設定
    cell.img_back.image = [UIImage imageNamed:arrImgCells[indexPath.row % (int)arrImgCells.count]];
    
    cell.viewBlur.backgroundColor = [UIColor whiteColor];
    cell.viewBlur.alpha = 0.5f;
    
    NSLog(@"%s, indexpath.row = %d, %@",
          __func__, (int)indexPath.row,
          (NSString *)arrImgCells[indexPath.row % (int)arrImgCells.count]);
    
    
    //セル上の表示文言の設定
    @autoreleasepool {
#ifdef QUIZ_FLAG
        Quiz *quiz = (Quiz *)quizSector.quizSectsArray[indexPath.row];
#else
        Siwake *quiz = (Siwake *)siwakeSector.quizSectsArray[indexPath.row];
#endif
        cell.lbl_sector.text =
        [NSString stringWithFormat:@"第%d章 %@", (int)indexPath.row+1, quiz.sectionName];
        
        
        //cell.lbl_name.text = [NSString stringWithFormat:@"概要%ld", indexPath.row];
        cell.lbl_name.text =
        [[quiz.arrCategory
          subarrayWithRange:
          NSMakeRange(0, quiz.arrCategory.count>=2?2:(quiz.arrCategory.count))]//最大値２
         componentsJoinedByString:@","];//先頭の上位要素のみ取得
        
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
    didUpdate = YES;//問題を解いた（解こうとした）場合に状態を更新したことにする(回答状況が変更@更新されたらtableを更新するため)
    
#ifdef QUIZ_FLAG
    DetailViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"detail"];
    Quiz *tmpQuiz = quizSector.quizSectsArray[indexPath.row];
    [controller setQuiz:tmpQuiz];
    
    
    [FIRAnalytics logEventWithName:@"tap:quiz:top"
                        parameters:@{@"row":[NSNumber numberWithInt:(int)indexPath.row],
                                     @"section":tmpQuiz.sectionName}];
    
    
#else
    SiwakeViewController *controller = [[SiwakeViewController alloc]init];
    //本来的にはここでインスタンス作成せずにviewdidloadで作成したグローバル変数から選択されたセル番号に応じたsiwakeセクションを返す
    Siwake *tmpSiwake = siwakeSector.quizSectsArray[indexPath.row];
    controller.siwake = tmpSiwake;
//    siwakeViewCon.quizNo = 0;//テスト：最初の番号を指定
//    [self.navigationController pushViewController:siwakeViewCon animated:YES];
#endif
    
    //最初の1問目の選択
    if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST] ||
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_NO_EXP] ||
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_STANDARD]){
        controller.quizNo = 0;
    }else{
#ifdef QUIZ_FLAG
        controller.quizNo = (int)arc4random_uniform((int)tmpQuiz.quizItemsArray.count);
#else
        controller.quizNo = (int)arc4random_uniform((int)tmpSiwake.siwakeItemsArray.count);
#endif
    }
    NSLog(@"quizNo @master = %d", controller.quizNo);
    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
    
#ifdef QUIZ_FLAG
    tmpQuiz = nil;
#else
    tmpSiwake = nil;
#endif
}

@end
