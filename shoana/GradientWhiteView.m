//
//  GradientWhiteView.m
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/29.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#import "GradientWhiteView.h"

@implementation GradientWhiteView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)init{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors =
    [NSArray arrayWithObjects:
     (id)[[UIColor colorWithWhite:1.f alpha:0.1f]CGColor],
     (id)[[UIColor whiteColor]CGColor], nil];
    [self.layer addSublayer:gradient];
    return self;
}

@end
