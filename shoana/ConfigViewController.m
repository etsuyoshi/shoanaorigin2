//
//  ConfigViewController.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/23.
//  Copyright © 2017年 com.endo. All rights reserved.
// モード設定
// 通常モード：問題を解いて解説を表示するモード
// テストモード：ひたすら問題を解くだけ（正解、不正解は表示せず解説も非表示）
// 解説表示なしモード：ひたすら問題を解くだけ（正解、不正解だけ表示しない）

#import "ConfigViewController.h"
#import "ResultModel.h"
#import "QuizSector.h"


@interface ConfigViewController (){
    UITableView *myTableView;
    NSArray *arrPicker;
    NSDictionary *dictConfigKey;
    UIPickerView *picker;//
    
    UIView *viewBasePicker;//view under picker
}

@end

@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //問題モードの設定(順番設定、ランダムモード、解説非表示(テストモード)、弱点克服など）on picker
    //履歴削除
    myTableView = [[UITableView alloc]
                   initWithFrame:self.view.bounds
                   style:UITableViewStyleGrouped];
//                   style:UITableViewStylePlain];
    myTableView.backgroundColor = [UIColor whiteColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
    arrPicker =
    [NSArray
     arrayWithObjects:
     @"通常モード",
     @"テストモード(順番)",
     @"テストモード(ランダム)",
     @"解説表示なしモード",
     //@"弱点克服モード",//未実装
     nil];
    
    
    dictConfigKey =
    [NSDictionary dictionaryWithObjectsAndKeys:
     arrPicker[0], QUIZ_CONFIG_KEY_STANDARD,
     arrPicker[1], QUIZ_CONFIG_KEY_TEST,
     arrPicker[2], QUIZ_CONFIG_KEY_TEST_RANDOM,
     arrPicker[3], QUIZ_CONFIG_KEY_NO_EXP,
     //必要があれば追加して行く必要がある
     nil];

    
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

-(void)setConfig:(int)selectedConfigNo{
    NSLog(@"%s, %d", __func__, selectedConfigNo);//選ばれたピッカー番号
    
    NSString *strSelectedLabelInPicker = arrPicker[selectedConfigNo];//選択されたピッカーのラベルを取得
    //選択されたラベルと等しいdictConfigKeyのキー（該当するキー全部の配列）
    NSArray *arrKeysEqualToSelectedObject = [dictConfigKey allKeysForObject:strSelectedLabelInPicker];
    NSString *strKeySelected = arrKeysEqualToSelectedObject[0];//該当キーを抽出（最初の一個）
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:strKeySelected forKey:QUIZ_CONFIG_KEY];
    [userDef synchronize];
    
    userDef = nil;
}


#pragma mark - Table View
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s : %@", __func__, indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    
    
    if(indexPath.row == 0){
        NSLog(@"picker launch");
        
        [self setUpPicker];
        
    }else if(indexPath.row == 1){
        //データクリア
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
            //すでに削除済み
            UIAlertController *alertController =
            [UIAlertController
             alertControllerWithTitle:@"既に削除済みです"
             message:@""
             preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:
            [UIAlertAction
             actionWithTitle:@"キャンセル"
             style:UIAlertActionStyleDefault
             handler:^(UIAlertAction *alert){
                 NSLog(@"何もしない");
             }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            
            //ダイアログを開いてyesならばチェックマークをつける
            UIAlertController * alertController =
            [UIAlertController
             alertControllerWithTitle:@"成績表の削除"
             message:@"削除しますか？"
             preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:
            [UIAlertAction
             actionWithTitle:@"削除する"
             style:UIAlertActionStyleDefault
             handler:^(UIAlertAction *alert){
                 
                 cell.accessoryType = UITableViewCellAccessoryCheckmark;
                 [self removeResult];//削除する
             }]];
            
            [alertController addAction:
            [UIAlertAction
             actionWithTitle:@"キャンセル"
             style:UIAlertActionStyleCancel
             handler:^(UIAlertAction *alert){
                 UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                 cell.accessoryType = UITableViewCellAccessoryNone;
             }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

-(void)removeResult{
    
    NSLog(@"%s", __func__);
    
    QuizSector *quizSector = [[QuizSector alloc]init];
    [quizSector readAll];//全csvデータ読み込み
    
    for(int i = 0;i < quizSector.quizSectsArray.count;i++){
        @autoreleasepool {
            Quiz *tmpQuiz = (Quiz *)quizSector.quizSectsArray[i];
            
    
            ResultModel *resultModel = [[ResultModel alloc] initWithSection:tmpQuiz];
            [resultModel resetAllData];
            
            tmpQuiz = nil;
            resultModel = nil;
        }
    }
    quizSector = nil;
}

-(void)setUpPicker{
    NSLog(@"%s", __func__);
    
    //実装中
    picker =
    [[UIPickerView alloc]initWithFrame:
     CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/3)];
    picker.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *strConfValue = [userDef objectForKey:QUIZ_CONFIG_KEY];
    
    //現状のモードを取得する:strConfValue
    if([strConfValue isEqual:[NSNull null]] || strConfValue == NULL){
        [userDef setObject:QUIZ_CONFIG_KEY_STANDARD forKey:QUIZ_CONFIG_KEY];
        strConfValue = QUIZ_CONFIG_KEY_STANDARD;
    }
    userDef = nil;
    
    //dictConfigKeyでarrPickerの番号を取得して、pickerにその番号をセットする
    int selectedRow = 0;
    for(NSString *strKey in dictConfigKey.allKeys){
        @autoreleasepool {
            NSLog(@"str key = %@, strconfValue = %@", strKey, strConfValue);
            if([strKey isEqualToString:strConfValue]){
                NSString *strValue = [dictConfigKey objectForKey:strKey];
                selectedRow = (int)[arrPicker indexOfObject:strValue];
                strValue = nil;
                break;
            }
        }
        
    }
    NSLog(@"picker selected no : %d", selectedRow);
    [picker selectRow:selectedRow inComponent:0 animated:NO];
    
    
    
    
    
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
    
    [self setConfig:(int)[picker selectedRowInComponent:0]];
    
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell =
//    (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    static NSString* CellIdentifier = @"cell";
    UITableViewCell* cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row==0){
        cell.textLabel.text = @"モード選択";
        //cell.detailTextLabel.text = @"テストモード";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.textLabel.text = @"成績表リセット";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


#pragma mark - Table View
//表示列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

//表示個数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [arrPicker count];
}

//表示内容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    
    return arrPicker[row];
}

//選択時
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"%s %d, %d", __func__, (int)row, (int)component);
    
}



@end
