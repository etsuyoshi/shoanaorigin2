//
//  UILabel+FontSizeToFit.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/02/08.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FontSizeToFit)

- (void)fontSizeToFit;
- (void)fontSizeToFitWithMinimumFontScale:(CGFloat)minimumFontScale diminishRate:(CGFloat)diminishRate;

@end
