//
//  SCPhotoBrowser.m
//  SCScrollerView
//
//  Created by SCMac on 14-8-30.
//  Copyright (c) 2014年 devDM. All rights reserved.
//
#import "SCPhotoBrowser.h"
#import "SCZoomImage.h"
#import "SCPhoto.h"
#define ZOOM_TAG 10000

@interface SCPhotoBrowser ()<SCPhotoTapDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableSet *reusedView;
@property (nonatomic) CGPoint startPoint;

@end

@implementation SCPhotoBrowser

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _horizontal = YES;
        _reusedView = [[NSMutableSet alloc] init];
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    // 禁用 iOS7 返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
}
- (void)dealloc
{
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setDelegate:self];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setTag:1];
    [_scrollView setDirectionalLockEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setBounces:NO];
    
    [self.view addSubview:_scrollView];
    CGSize contentSize = _scrollView.frame.size;
    NSInteger count = _photoArray.count;
    if (_horizontal) {
        contentSize.width  = contentSize.width * count;
    }else{
        contentSize.height  = contentSize.height * count;
    }
    [_scrollView setContentSize:contentSize];
    
    [self displaySCZoomImageView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPhotoArray:(NSArray *)photoArray
{
    if (_photoArray != photoArray) {
        _photoArray = photoArray;
//        [self setScrollVIewContentSize:_photoArray.count];
    }
}

//- (void)setScrollVIewContentSize: (NSInteger)count
//{
//    if (count == 0) {
//        return;
//    }
//}
- (void)displaySCZoomImageView
{
    if (_photoArray.count < 3) {
        for (int i = 0; i<_photoArray.count; i++) {
            CGRect zoomRect = _scrollView.frame;
            if (_horizontal) {
                zoomRect.origin.x = zoomRect.size.width * i;
            }else{
               zoomRect.origin.y = zoomRect.size.height * i;
            }
            SCZoomImage *zoomImage = [[SCZoomImage alloc] initWithFrame:zoomRect];
            SCPhoto *photo = [_photoArray objectAtIndex:i];
            zoomImage.photoDelegate = self;
            [zoomImage displayPhotoView:photo];
            [_scrollView addSubview:zoomImage];
        }
    }else{
            for (int i = 0; i<3; i++) {
            CGRect zoomRect = _scrollView.bounds;
            if (_horizontal) {
                zoomRect.origin.x = zoomRect.size.width * i;
            }else{
                zoomRect.origin.y = zoomRect.size.height * i;
            }
            SCZoomImage *zoomImage = [[SCZoomImage alloc] initWithFrame:zoomRect];
            SCPhoto *photo = [_photoArray objectAtIndex:i];
            [zoomImage setPhotoDelegate:self];
            [zoomImage displayPhotoView:photo];
            [zoomImage setTag:i + ZOOM_TAG];
            [_scrollView addSubview:zoomImage];
        }
    }

}

#pragma mark - scrollView delegate 
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    _startPoint = scrollView.contentOffset;
//    NSLog(@"%@", NSStringFromCGPoint(_startPoint));
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int pageNumber = ceil(scrollView.contentOffset.x / scrollView.frame.size.width - 0.5);
    if (pageNumber == 0) {
        return;
    }
    //判断右翻
    if (pageNumber > scrollView.tag) {
//        NSLog(@"right %d", pageNumber);
        scrollView.tag = pageNumber;
        if (pageNumber >= 2 && pageNumber !=_photoArray.count -1) {
            [self thePageNumberReuser:pageNumber - 2 thePageNumberWillBePlaced:pageNumber +1];
        }else if (pageNumber == _photoArray.count -1)
        {
//            [self thePageNumberReuser:pageNumber - 2 thePageNumberWillBePlaced:pageNumber];
        }
    }else
        if (pageNumber < scrollView.tag ) {
//        NSLog(@"left %d", pageNumber);
        scrollView.tag = pageNumber;
            if (pageNumber <= _photoArray.count - 3){
        [self thePageNumberReuser:pageNumber +2 thePageNumberWillBePlaced:pageNumber - 1];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    int pageNumber = ceil(scrollView.contentOffset.x / scrollView.frame.size.width - 0.5);
}
//reusedNumber 即将重用的 placedNumber 即将产生的
- (void)thePageNumberReuser: (NSInteger)reusedNumber thePageNumberWillBePlaced: (NSInteger)placedNumber
{
//    NSLog(@"reusedNumber: %ld, placedNumber: %ld", (long)reusedNumber, (long)placedNumber);
    SCZoomImage *zoomImage = (SCZoomImage *)[_scrollView viewWithTag:ZOOM_TAG + reusedNumber];
    if (zoomImage) {
        [_reusedView addObject:zoomImage];
    }
    SCZoomImage *reusedView = [_reusedView anyObject];
    if (reusedView == nil) {
        NSLog(@"新的-----");
        reusedView = [[SCZoomImage alloc] init];
        [self.scrollView addSubview:reusedView];
    }else{
        [_reusedView removeObject:reusedView];
    }
//    NSLog(@"_reusedViewCount: %lu", (unsigned long)_reusedView.count);
    [reusedView setTag:(ZOOM_TAG + placedNumber)];
//    NSLog(@"%ld, oldTag: %ld", (long)placedNumber, (long)reusedNumber);
    //计算frame
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = frame.size.width * placedNumber;
    [reusedView setFrame:frame];
    SCPhoto *photo = [_photoArray objectAtIndex:placedNumber];
    [reusedView displayPhotoView:photo];
}

/*

-(void)setCurrentPage:(NSInteger)currentPage
{
    [self setCurrentPage:currentPage animated:NO];
}

-(void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated
{
    //计算x偏移量
    CGFloat offsetX = self.scrollView.bounds.size.width * currentPage;
    //生成offset
    CGPoint offset = CGPointMake(offsetX, 0);
    [self.scrollView setContentOffset:offset animated:animated];
}
 */
#pragma mark -
- (void)displayPhotoViewDidTap
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
//    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
}
@end
