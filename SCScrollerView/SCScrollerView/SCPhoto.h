//
//  SCPhoto.h
//  SCScrollerView
//
//  Created by SCMac on 14-8-30.
//  Copyright (c) 2014年 devDM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SCPhoto : NSObject
@property (strong, nonatomic) ALAsset *alasset;
@property (strong, nonatomic) NSDate *date;
@end
