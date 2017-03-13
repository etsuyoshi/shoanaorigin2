//
//  SiwakeViewController.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/02/25.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Siwake.h"

@interface SiwakeViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Siwake *siwake;
@property int quizNo;

@end
