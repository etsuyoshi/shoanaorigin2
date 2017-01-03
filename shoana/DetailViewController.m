//
//  DetailViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/02.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import "DetailViewController.h"


@interface DetailViewController (){
    QuizItem *myQuizItem;
}

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    //if (self.detailItem) {
    NSLog(@"%s", __func__);
    if (self.quiz) {
        //self.detailDescriptionLabel.text = [self.detailItem description];
        myQuizItem = (QuizItem *)self.quiz.quizItemsArray[self.quizNo];
        
        self.detailDescriptionLabel.text =
            [NSString stringWithFormat:@"%@:%@",
             myQuizItem.questionNo,myQuizItem.question];
        
        
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
    }
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //auto layout でサイズを変える場合にはここでテキスト内容を修正する
     
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
//
    //改行
//    self.answer1Btn.titleLabel.numberOfLines = 0;
//    self.answer2Btn.titleLabel.numberOfLines = 0;
//    self.answer3Btn.titleLabel.numberOfLines = 0;
//    self.answer4Btn.titleLabel.numberOfLines = 0;
//    self.answer1Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    self.answer2Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    self.answer3Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    self.answer4Btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    
//    [self.answer1Btn sizeToFit];
//    [self.answer2Btn sizeToFit];
//    [self.answer3Btn sizeToFit];
//    [self.answer4Btn sizeToFit];
//    
//    [self.answer1Btn layoutIfNeeded];
//    [self.answer2Btn layoutIfNeeded];
//    [self.answer3Btn layoutIfNeeded];
//    [self.answer4Btn layoutIfNeeded];
}

-(void)tappedAnswer:(UIButton *)sender{
    NSLog(@"%s answer = %ld", __func__, sender.tag);
    
    
    [self goNext];
}


- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureView];
    //[self.questionContentLabel sizeToFit];
    
    
    
    
    
}

-(void)goNext{
    //NSDate *object = self.objects[indexPath.row];
    //DetailViewController *controller = [[DetailViewController alloc] init];
    int nextQuizNo = [self getNextQuestionNo];
    if(nextQuizNo > 0){
        DetailViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"detail"];
        [controller setQuiz:(Quiz *)(self.quiz)];
        controller.quizNo = nextQuizNo;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        //成績表示
    }
    
}

-(int)getNextQuestionNo{
    
    if(self.quizNo+1 < self.quiz.quizItemsArray.count){
        return self.quizNo+1;
    }else{
        return -1;
    }
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
    if(_quiz != quiz){
        NSLog(@"代入");
        _quiz = quiz;
        // Update the view.
        [self configureView];
        
    }
}


@end
