//
//  SCPhotoBrowser.h
//  SCScrollerView
//
//  Created by SCMac on 14-8-30.
//  Copyright (c) 2014年 devDM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCPhotoBrowser : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *photoArray;
@property (assign, nonatomic) BOOL horizontal;



@end
