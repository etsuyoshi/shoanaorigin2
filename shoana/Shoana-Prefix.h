//
//  Shoana-Prefix.h
//  shoana
//
//  Created by EndoTsuyoshi on 2017/01/19.
//  Copyright © 2017年 com.endo. All rights reserved.
//

#ifndef Shoana_Prefix_h
#define Shoana_Prefix_h


#endif /* Shoana_Prefix_h */



//QUIZ_FLAGを宣言するいないで判定する
#define QUIZ_FLAG

#ifndef QUIZ_FLAG
#define SIWAKE_FLAG
#endif


// userdefaults
#define USER_DEFAULTS_ANSWER                   @"answer"
#define USER_DEFAULTS_CORRECT                  @"correct"
#define USER_DEFAULTS_MISTAKE_THREASHOLD       @"threashold_mistake"

#define QUIZ_CONFIG_KEY @"quizKey"
#define QUIZ_CONFIG_KEY_STANDARD @"quizStandard"
#define QUIZ_CONFIG_KEY_TEST @"quizTest"
#define QUIZ_CONFIG_KEY_TEST_RANDOM @"quizTestRandom"
#define QUIZ_CONFIG_KEY_NO_EXP @"quizNoExp"
#define QUIZ_CONFIG_KEY_JAKUTEN @"quizJakuten"



//release版でnslogを出力しない
#if !defined(NS_BLOCK_ASSERTIONS)
#if !defined(NSLog)
#define NSLog( args... ) NSLog( args, 0 )
#endif

#else

#if !defined(NSLog)
#define NSLog( args... )
#endif

#endif
