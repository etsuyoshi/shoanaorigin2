//
//  SiwakeViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/02/25.
//  Copyright © 2017年 com.endo. All rights reserved.
//
@import Social;


#import "SiwakeViewController.h"
#import "ResultViewController.h"
#import "SPTwitterClient.h"
#import "ResultModel.h"

@interface SiwakeViewController ()

@end

@implementation SiwakeViewController

int margin_horizon = 10;//左右それぞれに10ptのマージン
int margin_vertical = 10;//下端に10ptマージン
UIView *viewAllWhenPicker;
SiwakeItem *mySiwakeItem;
NSMutableArray *arrAllBtn;
UIPickerView *pickerView;
NSMutableDictionary *dictAnswerKari;//借方のユーザー回答
NSMutableDictionary *dictAnswerKasi;//貸方のユーザー回答
BOOL isDispExplain;
BOOL isAnswerable;
UIView *viewExp;

//share
SPTwitterClient *twitterClient;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isDispExplain = YES;
    isAnswerable = YES;
    
    [self setNavigationBar];
    
    mySiwakeItem = (SiwakeItem *)self.siwake.siwakeItemsArray[self.quizNo];
    self.title = [NSString stringWithFormat:
                  @"%@:No.%d", mySiwakeItem.category, self.quizNo];
    
    //4*numRow:matrix@button(numRowは仕訳行数の貸方と借方の最大値)
    int numRow = mySiwakeItem.dictCorrectKari.allKeys.count>mySiwakeItem.dictCorrectKasi.allKeys.count?
                 (int)mySiwakeItem.dictCorrectKari.allKeys.count:(int)mySiwakeItem.dictCorrectKasi.allKeys.count;//siwakeの長さによる
    int numCol = 4;//fix
    int widthBtn = (self.view.bounds.size.width - margin_horizon*2)/numCol;
    int heightBtn = 44;
    int heightNav = 64;
    int heightAnswer = 44;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    //問題文
    UILabel *labelQuestion =
    [[UILabel alloc]initWithFrame:
     CGRectMake(margin_horizon, margin_vertical+heightNav,
                self.view.bounds.size.width - 2 * margin_horizon,
                self.view.bounds.size.height - 3 * margin_vertical - numRow * heightBtn - heightAnswer)];
    labelQuestion.text = mySiwakeItem.question;
    labelQuestion.textColor = [UIColor blackColor];
    labelQuestion.numberOfLines = 0;
    labelQuestion.lineBreakMode = NSLineBreakByWordWrapping;
    [labelQuestion sizeToFit];
    [self.view addSubview:labelQuestion];
    
    
    //仕訳表
    arrAllBtn = [NSMutableArray array];
    for(int row = 0;row < numRow;row++){
        
        NSMutableArray *arrHorizonBtn = [NSMutableArray array];
        for(int col = 0;col < numCol;col++){
            @autoreleasepool {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(margin_horizon + col * widthBtn,
                                       self.view.bounds.size.height - 2 * margin_vertical - (numRow - row) * heightBtn - heightAnswer,
                                       widthBtn, heightBtn);
                btn.layer.borderColor = [[UIColor blackColor] CGColor];
                btn.layer.borderWidth = 1;
                //[btn setTitle:[NSString stringWithFormat:@"%d%d", row, col] forState:UIControlStateNormal];
                [btn setTitle:@"-" forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:23.f];
                btn.tag = [[NSString stringWithFormat:@"%d%d", row, col] integerValue];
                [btn addTarget:self action:@selector(tappedSiwake:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btn];
                [arrHorizonBtn addObject:btn];
            }
        }
        
        [arrAllBtn addObject:arrHorizonBtn];
    }
    
    //借方・貸方のラベル付与
    UILabel *labelKari = [[UILabel alloc]initWithFrame:
                      CGRectMake(margin_horizon,
                                 self.view.bounds.size.height - 2 * margin_vertical - (numRow + 1) * heightBtn - heightAnswer,
                                 2 * widthBtn, heightBtn)];
    labelKari.textAlignment = NSTextAlignmentCenter;
    labelKari.layer.borderColor = [[UIColor blackColor] CGColor];
    labelKari.layer.borderWidth = 1;
    [labelKari setText:@"借方"];
    [labelKari setTextColor:[UIColor whiteColor]];
    labelKari.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    [self.view addSubview:labelKari];
    UILabel *labelKasi = [[UILabel alloc]initWithFrame:
                          CGRectMake(margin_horizon + 2 * widthBtn,
                                     self.view.bounds.size.height - 2 * margin_vertical - (numRow + 1) * heightBtn - heightAnswer,
                                     2 * widthBtn, heightBtn)];
    labelKasi.textAlignment = NSTextAlignmentCenter;
    labelKasi.layer.borderColor = [[UIColor blackColor] CGColor];
    labelKasi.layer.borderWidth = 1;
    [labelKasi setText:@"貸方"];
    [labelKasi setTextColor:[UIColor whiteColor]];
    labelKasi.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    [self.view addSubview:labelKasi];
    
    
    //回答ボタン
    UIButton *btnAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAnswer.frame =
    CGRectMake(margin_horizon,
               self.view.bounds.size.height - margin_vertical - heightAnswer,
               4 * widthBtn, heightBtn);
    btnAnswer.tag = 999;
    [btnAnswer setTitle:@"この内容で回答する" forState:UIControlStateNormal];
    [btnAnswer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnAnswer.layer.borderColor = [[UIColor blackColor] CGColor];
    btnAnswer.layer.borderWidth = 1;
    [btnAnswer addTarget:self action:@selector(tappedAnswer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnAnswer];
    
    //問題文にtwitterシェアボタンを配置する場合
//    //twitter shareボタン
//    int sizeShare = 44;
//    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnShare.frame = CGRectMake(0, 0, sizeShare, sizeShare);
//    btnShare.center =
//    CGPointMake(self.view.bounds.size.width - margin_horizon - sizeShare/2,
//                self.view.bounds.size.height - 3 * margin_vertical - (numRow + 1) * heightBtn - heightAnswer - sizeShare/2);
//    UIImage *imgShare = [UIImage imageNamed:@"twitter"];
//    [btnShare setImage:imgShare forState:UIControlStateNormal];
//    btnShare.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [btnShare addTarget:self action:@selector(tappedShare) forControlEvents:UIControlEventTouchUpInside];
//    btnShare.tag = 999;
//    [self.view addSubview:btnShare];
    
}

-(void)tappedShare{
    NSLog(@"tapped share");
    
    //twitter client
    twitterClient = [SPTwitterClient new];
    
    int randomNum = (int)(arc4random() * 100);
    NSString *strKariKasi = @"借方";
    if(randomNum % 2 == 0){
        strKariKasi = @"貸方";
    }
    NSString *strShareInit = @"あなたにはわかるかな？";
    if(randomNum % 3 == 0){
        strShareInit  = @"これがわかったら３級合格！";
    }else if(randomNum % 3 == 1){
        strShareInit = @"今日の不正解全国ランキング上位!";
    }
                    
    //あなたにはわかるかな？「商品100円を売り上げ、他店振り出しの小切手を受け取った」時の仕訳は？
    NSString *strShare =
    [NSString stringWithFormat:
     @"%@「%@」\nその時の仕訳で%@の項目は？",
     strShareInit,
     mySiwakeItem.question,strKariKasi];
    
    NSLog(@"投稿文 = %@", strShare);
    
    
    //投稿プロセス
    [self openComposeViewControllerWithServiceType:SLServiceTypeTwitter
                                            string:strShare];
    
}

-(void)setNavigationBar{
    
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc]
                                 initWithTitle:@"途中終了"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(tappedStop)];
    // ナビゲーションバーの左側に追加する。
    self.navigationItem.rightBarButtonItem = btnRight;
}

-(void)tappedAnswer:(id)sender{
    
    if(!isAnswerable){
        return;
    }
    isAnswerable = NO;
    NSLog(@"%s", __func__);
    
    //回答用辞書を初期化
    dictAnswerKari = [NSMutableDictionary dictionary];
    dictAnswerKasi = [NSMutableDictionary dictionary];
    
    
    //回答ボタンのラベルから回答状況を作成する
    for(UIView *subview in self.view.subviews){
        if([subview isKindOfClass:[UIButton class]]){
            NSLog(@"tag = %02ld", subview.tag);
            if(subview.tag < 100){//仕訳表のボタンのタグは全て二桁
                
                long leftNo  = [[[NSString stringWithFormat:@"%02d", (int)subview.tag] substringWithRange:NSMakeRange(0, 1)] integerValue];
                long rightNo = [[[NSString stringWithFormat:@"%02d", (int)subview.tag] substringWithRange:NSMakeRange(1, 1)] integerValue];
                
                
                NSLog(@"right = %ld, left = %ld", rightNo, leftNo);
                //借方
                if(rightNo == 0){//1列目
                    @autoreleasepool {
                        //該当する項目名を格納する
                        //key
                        NSString *strAnswerKey = ((UIButton *)subview).titleLabel.text;
                        NSLog(@"kari key = %@", strAnswerKey);
                        
                        for(UIView *subviewTmp in self.view.subviews){
                            if([subviewTmp isKindOfClass:[UIButton class]]){
                                int searchLeftNo =  (int)[[[NSString stringWithFormat:@"%02ld", subviewTmp.tag] substringWithRange:NSMakeRange(0, 1)] integerValue];
                                int searchRightNo = (int)[[[NSString stringWithFormat:@"%02ld", subviewTmp.tag] substringWithRange:NSMakeRange(1, 1)] integerValue];
                                //該当する行（同じleftNo）をもつ
                                if(searchLeftNo == leftNo && searchRightNo == 1){//借方のバリュー
                                    //該当する値を格納する
                                    //value
                                    NSString *strAnswerValue = ((UIButton *)subviewTmp).titleLabel.text;
                                    NSLog(@"hit [%@ : %@]", strAnswerKey, strAnswerValue);
                                    [dictAnswerKari setObject:strAnswerValue forKey:strAnswerKey];
                                    strAnswerValue = nil;
                                    strAnswerKey = nil;
                                    break;
                                }
                            }
                        }
                    }
                }else if(rightNo == 2){//2列目
                    @autoreleasepool {
                        //該当する項目名を格納する
                        //key
                        NSString *strAnswerKey = ((UIButton *)subview).titleLabel.text;
                        NSLog(@"kasi key = %@", strAnswerKey);
                        for(UIView *subviewTmp in self.view.subviews){
                            if([subviewTmp isKindOfClass:[UIButton class]]){
                                int searchLeftNo =  (int)[[[NSString stringWithFormat:@"%02ld", subviewTmp.tag] substringWithRange:NSMakeRange(0, 1)] integerValue];
                                int searchRightNo = (int)[[[NSString stringWithFormat:@"%02ld", subviewTmp.tag] substringWithRange:NSMakeRange(1, 1)] integerValue];
                                //該当する行（同じleftNo）をもつ
                                if(searchLeftNo == leftNo && searchRightNo == 3){//貸方のバリュー
                                    //該当する値を格納する
                                    //value
                                    NSString *strAnswerValue = ((UIButton *)subviewTmp).titleLabel.text;
                                    NSLog(@"hit [%@ : %@]", strAnswerKey, strAnswerValue);
                                    [dictAnswerKasi setObject:strAnswerValue forKey:strAnswerKey];
                                    strAnswerValue = nil;
                                    strAnswerKey = nil;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //確認:テストコード
    if(TRUE){
        NSLog(@"kari count = %ld", dictAnswerKari.allKeys.count);
        NSLog(@"kasi count = %ld", dictAnswerKasi.allKeys.count);
        
        for(int i = 0;i < dictAnswerKari.allKeys.count;i++){
            NSLog(@"kari : key=%@, value=%@", dictAnswerKari.allKeys[i], dictAnswerKari.allValues[i]);
        }
        
        for(int i = 0;i < dictAnswerKasi.allKeys.count;i++){
            NSLog(@"kasi : key=%@, value=%@", dictAnswerKasi.allKeys[i], dictAnswerKasi.allValues[i]);
        }
    }
    
    
    //正解判定
    BOOL isCorrect = FALSE;
    [self updateResult:isCorrect];
    
    if([dictAnswerKari isEqualToDictionary:mySiwakeItem.dictCorrectKari] &&
       [dictAnswerKasi isEqualToDictionary:mySiwakeItem.dictCorrectKasi]){
        NSLog(@"correct answer!!");
        
        isCorrect = TRUE;
    }else{
        if(![dictAnswerKari isEqualToDictionary:mySiwakeItem.dictCorrectKari] &&
           ![dictAnswerKasi isEqualToDictionary:mySiwakeItem.dictCorrectKasi]){
            NSLog(@"貸方と借方の両方誤回答");
            
            //不正解マークの表示
            
            
        }else if([dictAnswerKari isEqualToDictionary:mySiwakeItem.dictCorrectKari]){
            NSLog(@"貸方の誤回答");
        }else{
            NSLog(@"借方の誤回答");
        }
    }
    
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
    
    
    
    
    //正解表示
    for(int i = 0;i < mySiwakeItem.dictCorrectKari.allKeys.count;i++){
        NSLog(@"正解 : 借方[%@:%@]", mySiwakeItem.dictCorrectKari.allKeys[i],
              mySiwakeItem.dictCorrectKari.allValues[i]);
    }
    for(int i = 0;i < mySiwakeItem.dictCorrectKasi.allKeys.count;i++){
        NSLog(@"正解 : 貸方[%@:%@]", mySiwakeItem.dictCorrectKasi.allKeys[i],
              mySiwakeItem.dictCorrectKasi.allValues[i]);
    }
    
    
    
    
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


-(void)tappedSiwake:(id)sender{
    NSLog(@"%s", __func__);
    
    NSString *strTag = [NSString stringWithFormat:@"%02ld", ((UIView *)sender).tag];
    NSLog(@"strTag = %@", strTag);
    
    
    int rightNo = [[strTag substringWithRange:NSMakeRange(1, 1)] integerValue];
    
    
    switch (rightNo) {
        case 0:{
            NSLog(@"借方ラベル");
            break;
        }
        case 1:{
            NSLog(@"借方バリュー");
            break;
        }
        case 2:{
            NSLog(@"貸方ラベル");
            break;
        }
        case 3:{
            NSLog(@"貸方バリュー");
            break;
        }
        default:
            break;
    }
    
    [self showPickerView:(int)[strTag integerValue]];
}

-(void)showPickerView:(int)tag{
    
    
    int heightToolbar = 44;
    
    viewAllWhenPicker = [[UIView alloc]initWithFrame:
                         CGRectMake(0, 0, self.view.bounds.size.width,
                                    self.view.bounds.size.height)];
    viewAllWhenPicker.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewAllWhenPicker];
    
    
    //白地のピッカー下地
    UIView *viewUnderPicker =
    [[UIView alloc]initWithFrame:
     CGRectMake(0, self.view.bounds.size.height,
                self.view.bounds.size.width,
                self.view.bounds.size.height/2)];
    viewUnderPicker.backgroundColor = [UIColor whiteColor];
    
    
    pickerView =
    [[UIPickerView alloc]initWithFrame:
     CGRectMake(0, heightToolbar, self.view.bounds.size.width,
                viewUnderPicker.bounds.size.height - heightToolbar)];
    pickerView.tag = tag;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [viewUnderPicker addSubview:pickerView];
    
    //閉じるボタン
    int widthBtn = 100;
    int heightBtn = 40;
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.layer.borderWidth = 1;
    btnClose.layer.borderColor = [[UIColor blackColor] CGColor];
    btnClose.layer.cornerRadius = 3.f;
    btnClose.frame = CGRectMake(self.view.bounds.size.width - margin_horizon - widthBtn,
                                (heightToolbar - heightBtn)/2, widthBtn, heightBtn);
    [btnClose setTitle:@"決定" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
    [viewUnderPicker addSubview:btnClose];
    
    //[self.view addSubview:viewUnderPicker];
    [viewAllWhenPicker addSubview:viewUnderPicker];
    
    
    [UIView
     animateWithDuration:.3f
     animations:^{
         viewUnderPicker.center =
         CGPointMake(self.view.center.x,
                     self.view.center.y + viewUnderPicker.bounds.size.height/2);
     }
     completion:^(BOOL finished){
         
     }];
    
}

-(void)closePicker:(id)sender{
    NSLog(@"%s", __func__);
    
    
    //選択されているピッカービューの値を取得する
    NSInteger rowSelected = [pickerView selectedRowInComponent:0];
    
    NSInteger rightNo = [[[NSString stringWithFormat:@"%02ld", pickerView.tag] substringWithRange:NSMakeRange(1, 1)] integerValue];
    //NSInteger leftNo  = [[[NSString stringWithFormat:@"%02ld", pickerView.tag] substringWithRange:NSMakeRange(0, 1)] integerValue];
    NSString *strSelectedValue = nil;
    if(rightNo%2==0){
        strSelectedValue = mySiwakeItem.arrMSelectWords[rowSelected];
    }else{
        strSelectedValue = [NSString stringWithFormat:@"%@", mySiwakeItem.arrMSelectNumbers[rowSelected]];
    }
    for(UIView *subview in self.view.subviews){
        if([subview isKindOfClass:[UIButton class]]){
            if(subview.tag == pickerView.tag){
                NSLog(@"set(tag:%ld) %@", subview.tag, strSelectedValue);
                [((UIButton *)subview) setTitle:strSelectedValue forState:UIControlStateNormal];
                
                //font調整
                ((UIButton *)subview).titleLabel.adjustsFontSizeToFitWidth = YES;
                ((UIButton *)subview).titleLabel.minimumScaleFactor = 0.5f;
                break;
            }
        }
    }
    
    
    
    [UIView
     animateWithDuration:.3f
     animations:^{
         viewAllWhenPicker.center = CGPointMake(self.view.center.x,
                                                self.view.bounds.size.height);
         viewAllWhenPicker.alpha = 0;
     }
     completion:^(BOOL finished){
         [viewAllWhenPicker removeFromSuperview];
         viewAllWhenPicker = nil;
     }];
    
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
    textExp.text = mySiwakeItem.explanation;
    textExp.editable = NO;
    [textExp sizeToFit];//不要？
    textExp.frame = CGRectMake(marginBtn, marginBtn, viewExp.bounds.size.width-2*marginBtn,
                               viewExp.bounds.size.height-marginBtn*3 - heightBtn);
    textExp.textColor = [UIColor blackColor];
    [viewExp addSubview:textExp];
    
    
    
    
    
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
    
    
    
    //twitter shareボタン
    int sizeShare = 44;
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShare.frame = CGRectMake(0, 0, sizeShare, sizeShare);
    btnShare.center =
    CGPointMake(viewExp.bounds.size.width-marginBtn - sizeShare/2,
                viewExp.bounds.size.height-marginBtn*2 - heightBtn - sizeShare/2);
    UIImage *imgShare = [UIImage imageNamed:@"twitter"];
    [btnShare setImage:imgShare forState:UIControlStateNormal];
    btnShare.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btnShare addTarget:self action:@selector(tappedShare) forControlEvents:UIControlEventTouchUpInside];
    btnShare.tag = 999;
    [viewExp addSubview:btnShare];
    
    
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
          //終了ボタンを押した瞬間に回答できないようになっているので、キャンセルしたら再度回答できるようにする
          isAnswerable = YES;
      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
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


#pragma mark - UIPickerView
// 列数を返す
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 1; //列数は1つ
}

// 行数を返す
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSString *strTag = [NSString stringWithFormat:@"%02ld", pickerView.tag];
    
    
    
    if(component == 0){
        //return 10;  // 1列目は10行
        //tagの下一桁が偶数ならkey選択、奇数ならvalue選択
        if([[strTag substringWithRange:NSMakeRange(1, 1)] integerValue]%2==0){
            NSLog(@"%s, tag = %@, return = %ld", __func__, strTag,
                  mySiwakeItem.arrMSelectWords.count);
            return mySiwakeItem.arrMSelectWords.count;
        }else{
            NSLog(@"%s, tag = %@, return = %ld", __func__, strTag,
                  mySiwakeItem.arrMSelectNumbers.count);
            return mySiwakeItem.arrMSelectNumbers.count;
        }
        
    }else{
        return 0;
    }
    
}

// 表示する内容を返す
-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    // 行インデックス番号を返す
    //return [NSString stringWithFormat:@"%ld", row];
    //tagの下一桁が偶数ならkey選択、奇数ならvalue選択
    NSString *strTag = [NSString stringWithFormat:@"%02ld", pickerView.tag];
    if([[strTag substringWithRange:NSMakeRange(1, 1)] integerValue]%2==0){
        return (NSString *)mySiwakeItem.arrMSelectWords[row];
    }else{
        return [NSString stringWithFormat:@"%@", mySiwakeItem.arrMSelectNumbers[row]];
    }
    
    
}




-(void)goNext{
    NSLog(@"%s, nextquizno = %d", __func__, self.quizNo);
    int nextSiwakeNo = [self getNextSiwakeNo];
    NSLog(@"%s, nextquizno = %d", __func__, nextSiwakeNo);
    //if(nextQuizItem){
    if(nextSiwakeNo >= 0){
        SiwakeViewController *controller = [[SiwakeViewController alloc]init];
        controller.siwake = self.siwake;
        controller.quizNo = nextSiwakeNo;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        NSLog(@"next quiz no = %d", controller.quizNo);
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        //成績表示
        ResultViewController *controller = [[ResultViewController alloc]init];
        controller.myQuiz = self.siwake;
        controller.isAfterQuiz = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
        //ルートに戻る(仮)
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
-(int)getNextSiwakeNo{
    NSLog(@"%s, self.quizNo=%d", __func__, self.quizNo);
    if(self.siwake){
        int nextNo = [self.siwake nextQuiz:(int)self.quizNo];
        
        if(nextNo < self.siwake.siwakeItemsArray.count){
            NSLog(@"nextNo = %d", nextNo);
            return nextNo;
        }else{
            return -1;
        }
    }
    
    
    
    return -1;
}




#pragma mark - Private

- (void)openComposeViewControllerWithServiceType:(NSString *)serviceType
                                          string:(NSString *)strShare{
    // アカウントが設定済かをチェックする
    if (![SLComposeViewController isAvailableForServiceType:serviceType]) {
        NSLog(@"%@ is not Available", serviceType);
        return;
    }
    
    // ServiceType を指定して SLComposeViewController を作成
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
    // POSTするテキストの初期設定
    NSString* message = [NSString stringWithFormat:strShare];
    [composeViewController setInitialText:message];
    // URLをPOSTする場合：https://itunes.apple.com/us/app/簿記３級問題集/id1214570483?l=ja&ls=1&mt=8
    [composeViewController addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/簿記３級問題集/id1214570483?l=ja&ls=1&mt=8"]];
    // 画像をPOSTする場合:[building, street, wood, desk]
    NSArray *arrImgPosts = [NSArray arrayWithObjects:@"building", @"street", @"wood", @"desk", nil];
    [composeViewController
     addImage:[UIImage imageNamed:arrImgPosts[self.quizNo % arrImgPosts.count]]];
    
    // 処理完了時に実行される completionHandler を設定
    composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultCancelled) {
            NSLog(@"Cancelled");
        } else {
            NSLog(@"Done");
        }
    };
    
    // テキスト、画像、URL を追加したい場合は、SLComposeViewController を表示する前に設定する
    //    [composeViewController setInitialText:@"これはデフォルトのテキストです。"];
    //    [composeViewController addImage:[UIImage imageNamed:@"image"]];
    //    [composeViewController addURL:[NSURL URLWithString:@"http://dev.classmethod.jp/"]];
    
    // SLComposeViewController を表示
    [self presentViewController:composeViewController animated:YES completion:nil];
}

/*
 *self.quizNoが正しい数字か
 */
-(void)updateResult:(BOOL)isCorrect{
    NSLog(@"%s", __func__);
    ResultModel *resultModel = [[ResultModel alloc]initWithSection:self.siwake];
    [resultModel setResult:self.quizNo isCorrect:isCorrect];
    
    resultModel = nil;
}




@end
