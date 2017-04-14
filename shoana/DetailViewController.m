//
//  DetailViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//  http://tea-leaves.jp/home/ja/article/1374929836


//誤った時に問題番号を格納する＜ー章ごとに格納方法（モデル？）を定義@resultmodel
//次へ遷移する際に誤問題番号の中から順番に選択
//リセットで消えるようにする->ResultModelで消える
//右上のメニューボタンで、誤回答数設定か途中終了メニューが選択できるようにする
//メニューボタンで誤回答数設定では問題選別できるようにする（ぴっかー）

#import "UILabel+FontSizeToFit.h"
#import "DetailViewController.h"
#import "ResultViewController.h"
#import "ResultModel.h"
@import Firebase;

@interface DetailViewController (){
    QuizItem *myQuizItem;
    BOOL isDispExplain;
    BOOL isAnswerable;
    UIView *viewExp;//解説などを表示するビュー
    
    //表示する誤答数を選択する
    UIPickerView *picker;
    UIView *viewBasePicker;
    NSArray *arrMistakeSelections;
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
//        if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_JAKUTEN]){
//            
//        }else{
            //弱点克服モードじゃなかったら通常通り、指名された番号(self.quizNo)を表示する
            myQuizItem = (QuizItem *)self.quiz.quizItemsArray[self.quizNo];
//        }
        
        
//        self.detailDescriptionLabel.text =
//        [NSString stringWithFormat:@"第%d問【%@】過去回答：%@回, 誤回答数%d回",
        NSString *strDescription =
        [NSString stringWithFormat:@"第%d問【%@】過去回答：%@回, 誤回答数%d回",
         self.quizNo+1, myQuizItem.category,
         myQuizItem.kaitou, [myQuizItem.kaitou intValue] - [myQuizItem.seikai intValue]];
        [self.detailDescriptionLabel setText:strDescription];
        [self.detailDescriptionLabel setTextColor:[UIColor blackColor]];
        self.detailDescriptionLabel.textColor=[UIColor blackColor];
        NSLog(@"label text = %@", self.detailDescriptionLabel.text);
        
        self.questionContentLabel.text = myQuizItem.question;
        
        
        //viewDidLoadで実行するとインスタン変数(self.quizNo)などが初期化されないため、viewWillAppearで実行する→labelが前問が表示されたままになってしまうため削除する必要
        for(UIView *subview in self.answer1Btn.subviews)[subview removeFromSuperview];
        for(UIView *subview in self.answer2Btn.subviews)[subview removeFromSuperview];
        for(UIView *subview in self.answer3Btn.subviews)[subview removeFromSuperview];
        for(UIView *subview in self.answer4Btn.subviews)[subview removeFromSuperview];
        
        [self.answer1Btn addSubview:[self getAnswerLabel:0]];
        [self.answer2Btn addSubview:[self getAnswerLabel:1]];
        [self.answer3Btn addSubview:[self getAnswerLabel:2]];
        [self.answer4Btn addSubview:[self getAnswerLabel:3]];
        
        //[self.view addSubview:[self getAnswerLabel:0]];
        
        
        
        
        
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
    
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    int margin = 10;
    //auto layout でサイズを変える場合にはここでテキスト内容を修正する
    for(UIView *view in self.answer1Btn.subviews){
        if([view isKindOfClass:[UILabel class]]){
            view.frame = CGRectMake(0, 0, self.answer1Btn.bounds.size.width-margin,
                                    self.answer1Btn.bounds.size.height-margin);
            view.center = CGPointMake(self.answer1Btn.bounds.size.width/2,
                                      self.answer1Btn.bounds.size.height/2);
            [(UILabel *)view fontSizeToFit];
            //view.backgroundColor = [UIColor redColor];
            //break;
        }
    }
    
    for(UIView *view in self.answer2Btn.subviews){
        if([view isKindOfClass:[UILabel class]]){
            NSLog(@"hit");
            view.frame = CGRectMake(0, 0, self.answer2Btn.bounds.size.width-margin,
                                    self.answer2Btn.bounds.size.height-margin);
            view.center = CGPointMake(self.answer2Btn.bounds.size.width/2,
                                      self.answer2Btn.bounds.size.height/2);
            [(UILabel *)view fontSizeToFit];
            //view.backgroundColor = [UIColor yellowColor];
            //break;
        }
    }
    
    
    for(UIView *view in self.answer3Btn.subviews){
        if([view isKindOfClass:[UILabel class]]){
            view.frame = CGRectMake(0, 0, self.answer3Btn.bounds.size.width-margin,
                                    self.answer3Btn.bounds.size.height-margin);
            view.center = CGPointMake(self.answer3Btn.bounds.size.width/2,
                                      self.answer3Btn.bounds.size.height/2);
            [(UILabel *)view fontSizeToFit];
            //view.backgroundColor = [UIColor greenColor];
            //break;
        }
    }
    
    
    for(UIView *view in self.answer4Btn.subviews){
        if([view isKindOfClass:[UILabel class]]){
            view.frame = CGRectMake(0, 0, self.answer4Btn.bounds.size.width-margin,
                                    self.answer4Btn.bounds.size.height-margin);
            view.center = CGPointMake(self.answer4Btn.bounds.size.width/2,
                                      self.answer4Btn.bounds.size.height/2);
            [(UILabel *)view fontSizeToFit];
            //view.backgroundColor = [UIColor purpleColor];
            //break;
        }
    }
}

-(void)tappedAnswer:(UIButton *)sender{
    if(!isAnswerable){
        return;
    }
    isAnswerable = NO;
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
    
    [FIRAnalytics
     logEventWithName:@"answer"
     parameters:@{@"no":[NSNumber numberWithInt:_quizNo],
                  @"category":myQuizItem.category,
                  @"sectorName":myQuizItem.sectorName,
                  @"judge":[NSNumber numberWithBool:isCorrect]}];
    
}

-(void)displayExplanation{
    NSLog(@"%s", __func__);
    
    int margin = 30;
    int marginBtn = 10;
    
    
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
    
    int widthBtn = (viewExp.bounds.size.width-marginBtn*3) / 2;
    int heightBtn = 64;
    
    //表示ビューの長さのうち、ボタンのぶんだけ短くする
    UITextView *textExp = [[UITextView alloc]init];
//    textExp.frame = CGRectMake(marginBtn, marginBtn, viewExp.bounds.size.width-2*marginBtn,
//                               viewExp.bounds.size.height-marginBtn*3 - heightBtn);
    textExp.text = myQuizItem.explanation;
    textExp.editable = NO;
    [textExp sizeToFit];//不要？
    textExp.frame = CGRectMake(marginBtn, marginBtn, viewExp.bounds.size.width-2*marginBtn,
                               viewExp.bounds.size.height-marginBtn*3 - heightBtn);
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

-(void)tappedRightNavItem{
    NSLog(@"tapped right nav item");
    
    //ダイアログを開いてイェスならばチェックマークをつける
    UIAlertController * alertController =
    [UIAlertController
     alertControllerWithTitle:@""
     message:@"メニュー"
     preferredStyle:UIAlertControllerStyleActionSheet];
    if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_JAKUTEN]){
        
        [alertController addAction:
         [UIAlertAction
          actionWithTitle:@"問題の誤回答数を選ぶ"
          style:UIAlertActionStyleDefault
          handler:^(UIAlertAction *alert){
              
              //pickerを表示する
              [self setMistakeThreashold];
          }]];
    }
    
    [alertController addAction:
     [UIAlertAction
      actionWithTitle:@"途中で終了する"
      style:UIAlertActionStyleDefault
      handler:^(UIAlertAction *alert){
          [self tappedStop];
      }]];
    
    [alertController addAction:
     [UIAlertAction
      actionWithTitle:@"キャンセル"
      style:UIAlertActionStyleCancel
      handler:^(UIAlertAction *alert){
          
      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)setMistakeThreashold{
    NSLog(@"%s", __func__);
    
    
    
    //実装中
    picker =
    [[UIPickerView alloc]initWithFrame:
     CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/3)];
    picker.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    
    NSLog(@"picker selected no : %d", self.threasholdMistake);
    //行番号なので−１する
    [picker selectRow:self.threasholdMistake-1 inComponent:0 animated:NO];
    
    NSLog(@"picker row = %ld", [picker numberOfRowsInComponent:0]);
    
    
    
    int heightToolbar = 44;
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,heightToolbar)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone =
    [[UIBarButtonItem alloc]
     initWithTitle:@"決定"
     style:UIBarButtonItemStylePlain
     target:self action:@selector(changeDataFromPicker:)];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    toolBar.items = @[flexible, barButtonDone];
    barButtonDone.tintColor=[UIColor whiteColor];
    
    viewBasePicker =
    [[UIView alloc]
     initWithFrame:
     CGRectMake(0, 0, self.view.bounds.size.width,heightToolbar+picker.bounds.size.height)];
    [viewBasePicker addSubview:picker];
    picker.center =
    CGPointMake(self.view.center.x,
                viewBasePicker.bounds.size.height/2);
    viewBasePicker.backgroundColor = [UIColor whiteColor];
    [viewBasePicker addSubview:toolBar];
    viewBasePicker.center = CGPointMake(self.view.center.x,
                                        self.view.bounds.size.height + viewBasePicker.bounds.size.height/2);
    [self.view addSubview:viewBasePicker];
    
    [self pickerMoveIn];

    
}

-(void)pickerMoveIn{
    NSLog(@"%s", __func__);
    
    [UIView
     animateWithDuration:0.15f
     delay:0
     options:UIViewAnimationOptionCurveLinear
     animations:^{
         //         picker.center =
         //         CGPointMake(self.view.center.x,
         //                     self.view.bounds.size.height - picker.bounds.size.height/2);
         viewBasePicker.center =
         CGPointMake(self.view.center.x,
                     self.view.bounds.size.height-viewBasePicker.bounds.size.height/2);
     }
     completion:^(BOOL isFinished){
         NSLog(@"animation finished");
     }];
    
}



-(void)changeDataFromPicker:(id)sender{
    NSLog(@"%s", __func__);
    
    //設定されたオプションをステータスに反映する（まだやってないだけd）
    //[self setConfig:(int)[picker selectedRowInComponent:0]];
    
    
    //viewをcloseする
    [UIView
     animateWithDuration:0.15f
     delay:0
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
         //         picker.center =
         //         CGPointMake(self.view.center.x,
         //                     self.view.bounds.size.height + picker.bounds.size.height/2);
         viewBasePicker.center =
         CGPointMake(self.view.center.x,
                     self.view.bounds.size.height + viewBasePicker.bounds.size.height/2);
     }
     completion:^(BOOL isFinished){
         if(isFinished){
             NSLog(@"animation finished");
             //[picker removeFromSuperview];
             [viewBasePicker removeFromSuperview];
         }
     }];
}



-(void)tappedStop{
    NSLog(@"%s", __func__);
    [viewExp removeFromSuperview];
    
    
    //ダイアログを開いてイェスならばチェックマークをつける
    UIAlertController * alertController =
    [UIAlertController
     alertControllerWithTitle:@"途中ですが"
     message:@"全て終了しますか？"
     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:
     [UIAlertAction
      actionWithTitle:@"終了する"
      style:UIAlertActionStyleDefault
      handler:^(UIAlertAction *alert){
          
          [FIRAnalytics
           logEventWithName:@"close:quiz:detail"
           parameters:@{@"no":[NSNumber numberWithInt:_quizNo],
                        @"category":myQuizItem.category,
                        @"sectorName":myQuizItem.sectorName}];
          
          
          [self.navigationController popToRootViewControllerAnimated:YES];
      }]];
    
    [alertController addAction:
     [UIAlertAction
      actionWithTitle:@"キャンセル"
      style:UIAlertActionStyleCancel
      handler:^(UIAlertAction *alert){
          //終了ボタンを押した瞬間に回答できないようになっているので、キャンセルしたら再度回答できるようにする
          isAnswerable = YES;
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
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%s, height = %f", __func__, self.view.bounds.size.height);
    
    [FIRAnalytics
     logEventWithName:@"open:quiz:detail"
     parameters:@{@"no":[NSNumber numberWithInt:_quizNo],
                  @"category":myQuizItem.category,
                  @"sectorName":myQuizItem.sectorName}];
    
    
    isAnswerable = TRUE;
    self.view.backgroundColor = [UIColor whiteColor];
    self.questionContentLabel.editable=NO;
    
    //isDispExplain = false;//defaultでは解説
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    self.strConfigKey = [userdef objectForKey:QUIZ_CONFIG_KEY];
    userdef = nil;
    if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST] ||//test mode(in order)
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_TEST_RANDOM] ||//test mode(random order)
       [self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_NO_EXP]){
        isDispExplain = NO;
    }else{//standard ＆ jakutenモードでは解説を表示する
        isDispExplain = YES;
    }
    
    //誤答数で閾値を設定して
    if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_JAKUTEN]){
        arrMistakeSelections =
        [NSArray arrayWithObjects:@1,@2,@3,@4,@5, nil];
        
        //誤答問題の表示基準の設定（ゼロの場合は最低基準の１とする）
        if(self.threasholdMistake == 0){
            self.threasholdMistake = 1;
        }
        
    }
    
    [self setNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"%s, %d", __func__, self.quizNo);
    
    [self configureView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    NSLog(@"%s, %d", __func__, self.quizNo);
}

-(void)setNavigationBar{
    NSLog(@"%s", __func__);
    
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc]
                                 initWithTitle:@"メニュー"
                                 //initWithTitle:@"途中終了"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(tappedRightNavItem)];
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
    NSLog(@"%s, nextquizno = %d", __func__, self.quizNo);
    int nextQuizNo = [self getNextQuizNo];
    NSLog(@"%s, nextquizno = %d", __func__, nextQuizNo);
    
    //戻ってきたときに再度回答できるようにする
    isAnswerable = YES;
    if(nextQuizNo >= 0){
        DetailViewController *controller =
        [[self storyboard] instantiateViewControllerWithIdentifier:@"detail"];
        [controller setQuiz:(Quiz *)(self.quiz)];
        //controller.quizNo = nextQuizNo;
        //controller.quizNo = nextQuizItem.intQuestionNo;
        controller.threasholdMistake = self.threasholdMistake;
        controller.quizNo = nextQuizNo;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        NSLog(@"next quiz no = %d", controller.quizNo);
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
        if([self.strConfigKey isEqualToString:QUIZ_CONFIG_KEY_JAKUTEN]){
            ResultModel *resultModel = [[ResultModel alloc] initWithSection:self.quiz];
            
            //メニューボタンで選択した（できる）誤回答数の選定もできるようにする
            return (int)[resultModel
                         getInCorrectWithoutNo:self.quizNo
                         withThreashold:(self.threasholdMistake==0?1:self.threasholdMistake)];//現在の番号以外で、過去に誤った問題番号を返す
        }else{
            int nextNo = [self.quiz nextQuiz:(int)self.quizNo];
            
            if(nextNo < self.quiz.quizItemsArray.count){
                NSLog(@"nextNo = %d", nextNo);
                return nextNo;
            }else{
                return -1;
            }
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
    
    
    
    //誤回答状況の格納->jakuten-modeでなくとも保存だけは実施->ResultModelで巻き取れる？
//    if(!isCorrect){
//        NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
//        NSString *strKeyArrMistake =
//        [NSString stringWithFormat:@"array_mistake_%d",self.quiz.section];
//        NSMutableArray *arrMistake = [[userdef arrayForKey:strKeyArrMistake] mutableCopy];
//        if(!arrMistake){
//            for(int i = 0;i < self.quiz.quizItemsArray.count;i++){
//                [arrMistake addObject:[NSNumber numberWithInteger:0]];
//            }
//        }
//        arrMistake[self.quizNo] = [NSNumber numberWithInteger:[arrMistake[self.quizNo] integerValue] + 1];
//        [userdef setObject:arrMistake forKey:strKeyArrMistake];
//        userdef = nil;
//    }
    
    
    
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

//回答ボタンに載せるラベルを生成する
-(UILabel *)getAnswerLabel:(int)questionNo{
    
    int margin = 32;
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectZero];
    lbl.text = ((NSString *)myQuizItem.randomChoicesArray[questionNo]);
    lbl.frame = CGRectMake(0,0,self.view.bounds.size.width-margin,
                           self.view.bounds.size.height-margin);
    lbl.textColor= [UIColor blackColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.minimumScaleFactor = 0.3;
    lbl.adjustsFontSizeToFitWidth = true;
    lbl.numberOfLines = 0;
    lbl.frame = CGRectMake(0,0,self.view.bounds.size.width-margin,
                           self.view.bounds.size.height-margin);
    lbl.center = CGPointMake((self.view.bounds.size.width-margin)/2,
                             (self.view.bounds.size.height-margin)/2);
    return lbl;
}


#pragma mark - Picker View
//表示列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

//表示個数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [arrMistakeSelections count];
}

//表示内容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    
    return [NSString stringWithFormat:@"%d", (int)[arrMistakeSelections[row] integerValue]];
}

//選択時
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.threasholdMistake = (int)[arrMistakeSelections[row] integerValue];
    NSLog(@"%s %d, %d", __func__, (int)row, (int)component);
    
    //選択したステータス(誤答回数基準)
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setInteger:self.threasholdMistake forKey:USER_DEFAULTS_MISTAKE_THREASHOLD];
    userDef = nil;
    
}



@end


