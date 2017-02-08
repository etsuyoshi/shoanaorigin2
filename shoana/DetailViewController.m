//
//  DetailViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//  http://tea-leaves.jp/home/ja/article/1374929836

#import "UILabel+FontSizeToFit.h"
#import "DetailViewController.h"
#import "ResultViewController.h"
#import "ResultModel.h"


@interface DetailViewController (){
    QuizItem *myQuizItem;
    BOOL isDispExplain;
    UIView *viewExp;//解説などを表示するビュー
}

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    //if (self.detailItem) {
    NSLog(@"%s, quiz.sect = %d", __func__, (int)_quiz.section);
    if (_quiz) {
        
        self.title = [NSString stringWithFormat:@"第%d章", self.quiz.section];
        
        //ランダム設定する
        self.quiz.strConfigKey = self.strConfigKey;
        //self.detailDescriptionLabel.text = [self.detailItem description];
        myQuizItem = (QuizItem *)self.quiz.quizItemsArray[self.quizNo];
        
        self.detailDescriptionLabel.text =
        [NSString stringWithFormat:@"第%d問【%@】過去回答：%@回, 誤回答数%d回",
         self.quizNo+1, myQuizItem.category,
         myQuizItem.kaitou, [myQuizItem.kaitou intValue] - [myQuizItem.seikai intValue]];
//            [NSString stringWithFormat:@"%@:%@",
//             myQuizItem.questionNo,myQuizItem.question];
        
        
        self.questionContentLabel.text = myQuizItem.question;
//        [self.answer1Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[0]) forState:UIControlStateNormal];
//        [self.answer2Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[1]) forState:UIControlStateNormal];
//        [self.answer3Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[2]) forState:UIControlStateNormal];
//        [self.answer4Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[3]) forState:UIControlStateNormal];
        
        
//        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        [style setAlignment:NSTextAlignmentCenter];
//        NSAttributedString *str =
//        [[NSAttributedString alloc]
//         initWithString:((NSString *)myQuizItem.randomChoicesArray[0])
//         attributes:@{NSParagraphStyleAttributeName:style}];
//        [str drawInRect:CGRectMake(0, 0, self.answer1Btn.bounds.size.width, self.answer1Btn.bounds.size.height)];
//        [self.answer1Btn setAttributedTitle:str forState:UIControlStateNormal];
        
        
        
        
        
//        [self.answer1Btn
//         setAttributedTitle:[self getAttriutedStringForSelectBtn:
//                             ((NSString *)myQuizItem.randomChoicesArray[0])]
//         forState:UIControlStateNormal];
        
        
        
        
        //改行
//        self.answer1Btn.titleLabel.numberOfLines = 0;
//        self.answer1Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        
        
        [self.answer1Btn addSubview:[self getAnswerLabel:0]];
        [self.answer2Btn addSubview:[self getAnswerLabel:1]];
        [self.answer3Btn addSubview:[self getAnswerLabel:2]];
        [self.answer4Btn addSubview:[self getAnswerLabel:3]];
        
        
        
        
        
        self.answer1Btn.tag = 0;
        self.answer2Btn.tag = 1;
        self.answer3Btn.tag = 2;
        self.answer4Btn.tag = 3;
        
        [self.answer1Btn addTarget:self action:@selector(tappedAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.answer2Btn addTarget:self action:@selector(tappedAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.answer3Btn addTarget:self action:@selector(tappedAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.answer4Btn addTarget:self action:@selector(tappedAnswer:) forControlEvents:UIControlEventTouchUpInside];
        
        
//        NSLog(@"detail");
//        QuizItem *item = self.quiz.quizItemsArray[0];
//        NSLog(@"sectorName = %@", item.sectorName);
//        NSLog(@"questionNo = %@", item.questionNo);
//        NSLog(@"question = %@", item.question);
//        NSLog(@"rightAnswer = %@", item.rightAnswer);
//        NSLog(@"explanation = %@", item.explanation);
//        NSLog(@"category count = %ld", quiz.arrCategory.count);
//        for(int i = 0;i < quiz.arrCategory.count; i++){
//            NSLog(@"category%d = %@", i, quiz.arrCategory[i]);
//        }

        
        
    }
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //auto layout でサイズを変える場合にはここでテキスト内容を修正する
     
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

-(void)tappedAnswer:(UIButton *)sender{
    NSLog(@"%s answer = %ld", __func__, sender.tag);
    
    NSLog(@"tapped: %ld, correctAnswer = %d", sender.tag, myQuizItem.rightNo);
    
    //BOOL isCorrect = myQuizItem.rightNo == sender.tag+1;
    BOOL isCorrect = [myQuizItem checkIsRightNo:(int)sender.tag+1];//rightNoは1起点の選択肢番号
    
    //成績の更新
    [self updateResult:isCorrect];
    
    
    
    NSLog(@"isdispexplain = %d", isDispExplain);
    if(isDispExplain){
        NSLog(@"解説表示");
        [self displayExplanation];
        //正解、不正解の描画(説明文の上に表示)
        [self drawIsCorrect:isCorrect];
        
    }else{//解説を表示しないですぐに次のページに行く場合
        NSLog(@"解説表示なしで次の問題へ");
        //正解、不正解の描画
        [self drawIsCorrect:isCorrect];
        
        //1.4秒後に次のページに遷移する
        [self performSelector:@selector(goNext)
                   withObject:nil
                   afterDelay:1.4f];
    }
}

-(void)displayExplanation{
    NSLog(@"%s", __func__);
    
    int margin = 30;
    viewExp = [[UIView alloc]initWithFrame:
                       CGRectMake(0, 0, self.view.bounds.size.width-margin,
                                  self.view.bounds.size.height - margin - self.navigationController.navigationBar.bounds.size.height)];
    viewExp.center =
    CGPointMake(self.view.center.x,
                self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height +
                (self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height)/2);
    viewExp.layer.borderColor = [[UIColor blackColor] CGColor];
    viewExp.layer.borderWidth = 2.f;
    viewExp.layer.cornerRadius = 10;
    viewExp.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewExp];
    
    
    
//    UILabel *lblExp = [[UILabel alloc]init];
//    lblExp.frame = CGRectMake(10, 10, viewExp.bounds.size.width-20,
//                              viewExp.bounds.size.height-20);
//    lblExp.text = myQuizItem.explanation;
//    lblExp.numberOfLines = 0;
//    [lblExp sizeToFit];
//    lblExp.lineBreakMode = NSLineBreakByWordWrapping;
//    lblExp.textColor = [UIColor blackColor];
//    [viewExp addSubview:lblExp];
    UITextView *textExp = [[UITextView alloc]init];
    textExp.frame = CGRectMake(10, 10, viewExp.bounds.size.width-20, viewExp.bounds.size.height-20);
    textExp.text = myQuizItem.explanation;
    textExp.editable = NO;
    [textExp sizeToFit];
    textExp.textColor = [UIColor blackColor];
    [viewExp addSubview:textExp];
    
    
    
    
    
    //全画面のどこかを押すと消えるようにする
//    UIView *allView = [[UIView alloc]initWithFrame:self.view.bounds];
//    allView.backgroundColor = [UIColor whiteColor];
//    allView.alpha = .1f;
//    [self.view addSubview:allView];
//    allView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *gesture =
//    [[UITapGestureRecognizer alloc]
//     initWithTarget:self
//     action:@selector(disappearExp:)];
//    [allView addGestureRecognizer:gesture];
    
    
    int marginBtn = 10;
    int widthBtn = (viewExp.bounds.size.width-marginBtn*3) / 2;
    int heightBtn = 64;
    //次へ進むボタン
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.frame = CGRectMake(0, 0, widthBtn, heightBtn);
    btnNext.center = CGPointMake(viewExp.bounds.size.width-marginBtn - widthBtn/2,
                                 viewExp.bounds.size.height - marginBtn - heightBtn/2);
    btnNext.layer.cornerRadius = 3;
    btnNext.layer.borderColor = [[UIColor blackColor] CGColor];
    btnNext.layer.borderWidth = 1;
    //btnNext.backgroundColor = [UIColor blueColor];
    [btnNext setTitle:@"次へ" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnNext.titleLabel.font = [UIFont systemFontOfSize:23.f];
    [viewExp addSubview:btnNext];
    
    //やめるボタン
    UIButton *btnStop = [UIButton buttonWithType:UIButtonTypeCustom];
    btnStop.frame = CGRectMake(0, 0, widthBtn, heightBtn);
    btnStop.center = CGPointMake(viewExp.bounds.size.width/4,
                                 viewExp.bounds.size.height-marginBtn-heightBtn/2);
    btnStop.layer.cornerRadius = 3;
    btnStop.layer.borderColor = [[UIColor blackColor] CGColor];
    btnStop.layer.borderWidth = 1;
    [btnStop setTitle:@"やめる" forState:UIControlStateNormal];
    [btnStop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnStop.titleLabel.font = [UIFont systemFontOfSize:23.f];
    [viewExp addSubview:btnStop];
    
    
    [btnNext addTarget:self action:@selector(tappedNext) forControlEvents:UIControlEventTouchUpInside];
    [btnStop addTarget:self action:@selector(tappedStop) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tappedNext{
    NSLog(@"%s", __func__);
    [viewExp removeFromSuperview];
    
    [self goNext];
}

-(void)tappedStop{
    NSLog(@"%s", __func__);
    [viewExp removeFromSuperview];
    
    
    //ダイアログを開いてイェスならばチェックマークをつける
    UIAlertController * alertController =
    [UIAlertController
     alertControllerWithTitle:@"途中ですが"
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

-(void)disappearExp:(UIGestureRecognizer *)gesture{
    NSLog(@"%s", __func__);
    //[gesture.view removeFromSuperview];
    [viewExp removeFromSuperview];
    
    [self goNext];
}


//正解不正解の描画
-(void)drawIsCorrect:(BOOL)isCorrect{
    NSLog(@"%s", __func__);
    
    
    UIImageView *imvIsCorrect = imvIsCorrect =
    [[UIImageView alloc]initWithImage:
     [UIImage imageNamed:isCorrect?@"circle":@"cross"]];
    imvIsCorrect.center = self.view.center;
    [self.view addSubview:imvIsCorrect];
    
    [UIView
     animateWithDuration:.9f
     delay:0.5f
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
         imvIsCorrect.alpha = 0;
     }
     completion:^(BOOL isFinished){
         if(isFinished){
             [imvIsCorrect removeFromSuperview];
         }
     }];
}


- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //isDispExplain = false;//defaultでは解説
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    self.strConfigKey = [userdef objectForKey:QUIZ_CONFIG_KEY];
    userdef = nil;
    if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST] ||//test mode(in order)
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST_RANDOM] ||//test mode(random order)
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_NO_EXP]){
        isDispExplain = NO;
    }else{
        isDispExplain = YES;
    }
    
    [self configureView];
    //[self.questionContentLabel sizeToFit];
    
    
    [self setNavigationBar];
}

-(void)setNavigationBar{
    NSLog(@"%s", __func__);
    
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc]
                                 initWithTitle:@"途中終了"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(tappedStop)];
//    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc]
//                                initWithTitle:@"設定"
//                                style:UIBarButtonItemStylePlain
//                                target:self
//                                action:@selector(goConfig)];
    
    // ナビゲーションバーの左側に追加する。
    self.navigationItem.rightBarButtonItem = btnRight;
    //self.navigationItem.leftBarButtonItem = btnLeft;
    
    
}

-(void)goNext{
    //NSDate *object = self.objects[indexPath.row];
    //DetailViewController *controller = [[DetailViewController alloc] init];
    //int nextQuizNo = [self getNextQuestionNo];
    //QuizItem *nextQuizItem = [self getNextQuizItem];
    int nextQuizNo = [self getNextQuizNo];
    //if(nextQuizItem){
    if(nextQuizNo > 0){
        DetailViewController *controller =
        [[self storyboard] instantiateViewControllerWithIdentifier:@"detail"];
        [controller setQuiz:(Quiz *)(self.quiz)];
        //controller.quizNo = nextQuizNo;
        //controller.quizNo = nextQuizItem.intQuestionNo;
        controller.quizNo = nextQuizNo;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        //成績表示
        ResultViewController *controller = [[ResultViewController alloc]init];
        controller.myQuiz = self.quiz;
        controller.isAfterQuiz = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
        //ルートに戻る(仮)
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

-(int)getNextQuizNo{
    NSLog(@"%s, self.quizNo=%d", __func__, self.quizNo);
    if(self.quiz){
        int nextNo = [self.quiz nextQuiz:(int)self.quizNo];
        
        if(nextNo < self.quiz.quizItemsArray.count){
            return nextNo;
        }else{
            return -1;
        }
    }
    
    
    
    return -1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

//- (void)setDetailItem:(NSDate *)newDetailItem {
- (void)setQuiz:(Quiz *)quiz {
    NSLog(@"%s", __func__);
//    if (_detailItem != newDetailItem) {
//        _detailItem = newDetailItem;
//    if(_quiz != quiz){
        NSLog(@"代入");
        _quiz = quiz;
        // Update the view.
        [self configureView];
        
//    }
}


/*
 *self.quizNoが正しい数字か
 */
-(void)updateResult:(BOOL)isCorrect{
    NSLog(@"%s", __func__);
    ResultModel *resultModel = [[ResultModel alloc]initWithSection:self.quiz];
    [resultModel setResult:self.quizNo isCorrect:isCorrect];
    resultModel = nil;
}


//-(NSAttributedString *)getAttriutedStringForSelectBtn:(NSString *)strParam{
//    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    [style setAlignment:NSTextAlignmentCenter];
//    NSAttributedString *str =
//    [[NSAttributedString alloc]
//     initWithString:strParam
//     attributes:@{NSParagraphStyleAttributeName:style}];
//    
//    [str drawInRect:CGRectMake(0, 0, self.answer1Btn.bounds.size.width-10,
//                               self.answer1Btn.bounds.size.height-10)];
//    [str drawAtPoint:CGPointMake(self.answer1Btn.bounds.size.width/2,
//                                 self.answer1Btn.bounds.size.height/2)];
//    
//    return str;
//    
//}

-(UILabel *)getAnswerLabel:(int)questionNo{
    UILabel *lbl = [[UILabel alloc]init];
    lbl.text = ((NSString *)myQuizItem.randomChoicesArray[questionNo]);
    lbl.frame = CGRectMake(0,0,self.answer1Btn.bounds.size.width-20,
                           self.answer1Btn.bounds.size.height-20);
    lbl.center = CGPointMake(self.answer1Btn.bounds.size.width/2,
                             self.answer1Btn.bounds.size.height/2);
    lbl.textColor= [UIColor blackColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.minimumScaleFactor = 0.3;
    lbl.adjustsFontSizeToFitWidth = true;
    lbl.numberOfLines = 0;
    [lbl fontSizeToFit];
    
    
    return lbl;
}

@end
