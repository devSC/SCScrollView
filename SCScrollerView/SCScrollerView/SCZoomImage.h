//
//  SCZoomImage.h
//  SCScrollerView
//
//  Created by SCMac on 14-8-30.
//  Copyright (c) 2014年 devDM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPhoto.h"
@protocol SCPhotoTapDelegate <NSObject>
- (void)displayPhotoViewDidTap;
@end

@interface SCZoomImage : UIScrollView<UIScrollViewDelegate>
@property (strong, nonatomic) UIImageView *photoView;
@property (assign, nonatomic) id<SCPhotoTapDelegate>photoDelegate;
- (void)displayPhotoView: (SCPhoto *)photo;


@end
