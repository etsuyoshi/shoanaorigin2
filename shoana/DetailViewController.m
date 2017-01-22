//
//  DetailViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import "DetailViewController.h"
#import "ResultViewController.h"
#import "ResultModel.h"


@interface DetailViewController (){
    QuizItem *myQuizItem;
    BOOL isDispExplain;
}

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    //if (self.detailItem) {
    NSLog(@"%s, quiz = %@", __func__, _quiz);
    if (_quiz) {
        
        self.title = [NSString stringWithFormat:@"第%d章", self.quiz.section];
        
        //self.detailDescriptionLabel.text = [self.detailItem description];
        myQuizItem = (QuizItem *)self.quiz.quizItemsArray[self.quizNo];
        
        self.detailDescriptionLabel.text =
        [NSString stringWithFormat:@"第%d問【%@】過去回答：%@回, 誤回答数%d回",
         self.quizNo+1, myQuizItem.category,
         myQuizItem.kaitou, [myQuizItem.kaitou intValue] - [myQuizItem.seikai intValue]];
//            [NSString stringWithFormat:@"%@:%@",
//             myQuizItem.questionNo,myQuizItem.question];
        
        
        self.questionContentLabel.text = myQuizItem.question;
        [self.answer1Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[0]) forState:UIControlStateNormal];
        [self.answer2Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[1]) forState:UIControlStateNormal];
        [self.answer3Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[2]) forState:UIControlStateNormal];
        [self.answer4Btn setTitle:((NSString *)myQuizItem.randomChoicesArray[3]) forState:UIControlStateNormal];
        
        
        //改行
        self.answer1Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answer2Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answer3Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answer4Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answer1Btn.titleLabel.numberOfLines = 0;
        self.answer2Btn.titleLabel.numberOfLines = 0;
        self.answer3Btn.titleLabel.numberOfLines = 0;
        self.answer4Btn.titleLabel.numberOfLines = 0;
//
//        [self.answer1Btn sizeToFit];
//        [self.answer2Btn sizeToFit];
//        [self.answer3Btn sizeToFit];
//        [self.answer4Btn sizeToFit];
//        
//        [self.answer1Btn layoutIfNeeded];
//        [self.answer2Btn layoutIfNeeded];
//        [self.answer3Btn layoutIfNeeded];
//        [self.answer4Btn layoutIfNeeded];
        
        
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
    
    
    
    if(isDispExplain){
        [self displayExplanation];
        //正解、不正解の描画(説明文の上に表示)
        [self drawIsCorrect:isCorrect];
        
    }else{//解説を表示しないですぐに次のページに行く場合
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
    
    
    UIView *viewExp = [[UIView alloc]initWithFrame:
                       CGRectMake(0, 0, self.view.bounds.size.width-30,
                                  self.view.bounds.size.height/2)];
    viewExp.center = CGPointMake(self.view.center.x,
                                 self.view.bounds.size.height-10-viewExp.bounds.size.height/2);
    viewExp.layer.borderColor = [[UIColor blackColor] CGColor];
    viewExp.layer.borderWidth = 2.f;
    viewExp.layer.cornerRadius = 10;
    viewExp.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewExp];
    
    
    
    UILabel *lblExp = [[UILabel alloc]init];
    lblExp.frame = CGRectMake(10, 10, viewExp.bounds.size.width-20,
                              viewExp.bounds.size.height-20);
    lblExp.text = myQuizItem.explanation;
    lblExp.numberOfLines = 0;
    [lblExp sizeToFit];
    lblExp.lineBreakMode = NSLineBreakByWordWrapping;
    lblExp.textColor = [UIColor blackColor];
    [viewExp addSubview:lblExp];
    
    
    //全画面のどこかを押すと消えるようにする
    UIView *allView = [[UIView alloc]initWithFrame:self.view.bounds];
    allView.backgroundColor = [UIColor whiteColor];
    allView.alpha = .1f;
    [self.view addSubview:allView];
    allView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(disappearExp:)];
    [allView addGestureRecognizer:gesture];
    
}

-(void)disappearExp:(UIGestureRecognizer *)gesture{
    NSLog(@"%s", __func__);
    [gesture.view removeFromSuperview];
    
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
    
    [self configureView];
    //[self.questionContentLabel sizeToFit];
    
    
    //isDispExplain = false;//defaultでは解説
    isDispExplain = YES;
    
    
    
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


@end
