//
//  SCZoomImage.m
//  SCScrollerView
//
//  Created by SCMac on 14-8-30.
//  Copyright (c) 2014年 devDM. All rights reserved.
//

#import "SCZoomImage.h"
@interface SCZoomImage ()
@property CGSize imageSize;

@property CGPoint pointToCenterAfterResize;
@property CGFloat scaleToRestoreAfterResize;

@end;
@implementation SCZoomImage



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.bouncesZoom = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.directionalLockEnabled = YES;
        self.delegate = self;
        
        //add tap gesture
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
        [self addGestureRecognizer:tapGesture];
        
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_photoView];
        
        
    }
    return self;
}

- (void)tapGestureAction
{
    [self.photoDelegate displayPhotoViewDidTap];
}

- (void)layoutSubviews  {
    
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    // Center
	if (!CGRectEqualToRect(_photoView.frame, frameToCenter)) {
		_photoView.frame = frameToCenter;
    }
//    _photoView.frame = frameToCenter;
//    photoView.contentMode = UIViewContentModeCenter;
}

- (void)setFrame:(CGRect)frame {
    
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return _photoView;
}

- (void)displayPhotoView: (SCPhoto *)photo;
{
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);
    
//    if (photoView) {
//        [photoView removeFromSuperview];
//    }
    UIImage *photoImage = [UIImage imageWithCGImage:photo.alasset.defaultRepresentation.fullScreenImage];
    [self.photoView setImage:photoImage];
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = photoImage.size;
    _photoView.frame = photoImageViewFrame;
    [self configureForImageSize:photoImage.size];
    
}
#pragma mark - Setup

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoView) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
	
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail if no image
	if (_photoView.image == nil) return;
    
	// Reset position
	_photoView.frame = CGRectMake(0, 0, _photoView.frame.size.width, _photoView.frame.size.height);
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
	CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
	if (xScale >= 1 && yScale >= 1) {
		minScale = 1.0;
	}
	
	// Set min/max zoom
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.scrollEnabled = NO;
    }
    
    // Layout
	[self setNeedsLayout];
    
}
//设置图片大小
- (void)configureForImageSize: (CGSize)imageSize
{
    self.imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    
    self.zoomScale = self.minimumZoomScale;
}
////设置缩放比例
//- (void)setMaxMinZoomScalesForCurrentBounds
//{
//    CGSize boundSize = self.bounds.size;
//    
//    CGFloat xScale = boundSize.width/_imageSize.width;
//    CGFloat yScale = boundSize.height/_imageSize.height;
//    
//    BOOL imagePortrait = _imageSize.height > _imageSize.width;
//    BOOL phonePortrait = boundSize.height > boundSize.width;
//    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
//    
//    CGFloat maxScale = 1.0/[[UIScreen mainScreen] scale];
//    
//    if (minScale > maxScale) {
//        minScale = maxScale;
//    }
//    self.maximumZoomScale = maxScale;
//    self.minimumZoomScale = minScale;
//    
//}
#pragma mark - Methods called during rotation to preserve the zoomScale and the visible protion the image

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_photoView];
    _scaleToRestoreAfterResize = self.zoomScale;
    
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON) {
        _scaleToRestoreAfterResize = 0;
    }
    
}
- (void)recoverFromResizing {
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_photoView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    
    return CGPointZero;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
