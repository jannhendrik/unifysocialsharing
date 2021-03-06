//
//  SCCameraView.m
//  CocoaBloc
//
//  Created by Mark Glagola on 11/4/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import "SBCameraView.h"
#import "SBProgressBar.h"
#import "SBCaptureView.h"
#import "SBCaptureManager.h"
#import <PureLayout/PureLayout.h>
#import "SBRecordButton.h"
#import "UIFont+CocoaBloc.h"
#import "UIColor+CocoaBloc.h"
#import "SBPageView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "UIDevice+Orientation.h"
#import "SBOptionsChevronButton.h"

@import AVFoundation.AVCaptureVideoPreviewLayer;

@interface SBCameraView ()
@property (nonatomic) NSArray *squareToolbarConstraints;
@property (nonatomic) NSArray *cameraConstraints;
@property (nonatomic) NSArray *topViewsConstraints;
@property (nonatomic) NSArray *nextButtonConstraints;
@property (nonatomic) NSArray *progressBarConstraints;

@property (nonatomic) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic) UITapGestureRecognizer *singleTapGesture;

@property (nonatomic) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation SBCameraView

@synthesize aspectRatio = _aspectRatio;

BOOL isSmallScreen() {
    CGRect rect = [[UIScreen mainScreen] bounds];
    return CGRectGetHeight(rect) <= 480 && CGRectGetWidth(rect) <= 480;
}

- (UIView*) captureViewContainer {
    if (!_captureViewContainer) {
        _captureViewContainer = [[UIView alloc] initWithFrame:self.bounds];
        _captureViewContainer.backgroundColor = [UIColor clearColor];
    }
    return _captureViewContainer;
}

- (SBProgressBar*) progressBar {
    if (!_progressBar)
        _progressBar = [[SBProgressBar alloc] initWithMinValue:0 maxValue:10];
    return _progressBar;
}

- (SBRecordButton*) recordButton {
    if (!_recordButton) {
        _recordButton = [[SBRecordButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        _recordButton.layer.masksToBounds = YES;
    }
    return _recordButton;
}

- (UIToolbar*) stateToolbar {
    if (!_stateToolbar) {
        _stateToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _stateToolbar.translucent = YES;
        _stateToolbar.barStyle = UIBarStyleBlack;
        _stateToolbar.clipsToBounds = YES;
        _stateToolbar.hidden = YES;
    }
    return _stateToolbar;
}

- (UIView*) shutterView {
    if (!_shutterView) {
        _shutterView = [[UIView alloc] initWithFrame:self.bounds];
        _shutterView.backgroundColor = [UIColor blackColor];
        _shutterView.alpha = 0;
    }
    return _shutterView;
}

- (UIView*) focusView {
    if (!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.alpha = 0;
        _focusView.layer.borderColor = [UIColor whiteColor].CGColor;
        _focusView.layer.borderWidth = 2.0f;
        _focusView.layer.cornerRadius = 40;
    }
    return _focusView;
}

#pragma mark - Top HUD views
- (UIView*) topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.0f)];
        
        [_topContainerView autoSetDimension:ALDimensionHeight toSize:40];
    }
    return _topContainerView;
}

- (UIButton*) closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.imageView.contentMode = UIViewContentModeCenter;
        [_closeButton setImage:[UIImage imageNamed:@"sb_camera_close"] forState:UIControlStateNormal];
        _closeButton.layer.masksToBounds = YES;
    }
    return _closeButton;
}

- (UILabel*) timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont fc_fontWithSize:19.0f];
        _timeLabel.text = @"0:00";
        [_timeLabel sizeToFit];
    }
    return _timeLabel;
}

- (SBPageView*) pageView {
    if (!_pageView) {
        _pageView = [[SBPageView alloc] initWithTitles:@[@"Video", @"Photo", @"Square"]];
    }
    return _pageView;
}

- (UIToolbar*) topSquareToolbar {
    if (!_topSquareToolbar) {
        _topSquareToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _topSquareToolbar.barStyle = UIBarStyleBlack;
        _topSquareToolbar.clipsToBounds = YES;
        _topSquareToolbar.translucent = YES;
    }
    return _topSquareToolbar;
}
- (UIToolbar*) bottomSquareToolbar {
    if (!_bottomSquareToolbar) {
        _bottomSquareToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _bottomSquareToolbar.barStyle = UIBarStyleBlack;
        _bottomSquareToolbar.clipsToBounds = YES;
        _bottomSquareToolbar.translucent = YES;
    }
    return _bottomSquareToolbar;
}

#pragma mark - Bottom HUD views
- (UIView*) bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds), CGRectGetWidth(self.bounds), 0.0f)];
        _bottomContainerView.clipsToBounds = NO;
        
        CGSize size = CGSizeMake(50, 50);
        CGPoint offset = CGPointMake(10, 10);
        
        [_bottomContainerView addSubview:self.chooseExistingButton];
        [self.chooseExistingButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_bottomContainerView withOffset:offset.x];
        [self.chooseExistingButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_bottomContainerView withOffset:-offset.y];
        [self.chooseExistingButton autoSetDimensionsToSize:size];
        
        [_bottomContainerView addSubview:self.optionsMenuButton];
        [self.optionsMenuButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_bottomContainerView withOffset:-offset.x];
        [self.optionsMenuButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_bottomContainerView withOffset:-offset.y];
        [self.optionsMenuButton autoSetDimensionsToSize:size];
        
        size = CGSizeMake(64, 64);
        offset = CGPointMake(20, 20);
        [_bottomContainerView addSubview:self.recordButton];
        [self.recordButton autoSetDimensionsToSize:size];
        [self.recordButton autoAlignVerticalAxisToSuperview];
        [self.recordButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_bottomContainerView withOffset:-offset.y];
    }
    return _bottomContainerView;
}

- (UIButton*) chooseExistingButton {
    if (!_chooseExistingButton) {
        _chooseExistingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chooseExistingButton setImage:[UIImage imageNamed:@"sb_camera_existing"] forState:UIControlStateNormal];
        _chooseExistingButton.layer.masksToBounds = YES;
        _chooseExistingButton.imageView.contentMode = UIViewContentModeCenter;
    }
    return _chooseExistingButton;
}

- (SBOptionsChevronButton*) optionsMenuButton {
    if (!_optionsMenuButton)
        _optionsMenuButton = [[SBOptionsChevronButton alloc] init];
    return _optionsMenuButton;
}

- (UIButton*) nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"sb_camera_arrow_right"] forState:UIControlStateNormal];
        _nextButton.layer.masksToBounds = YES;
        _nextButton.imageView.contentMode = UIViewContentModeCenter;
    }
    return _nextButton;
}

#pragma mark - Options Menu
- (SBBottomViewContrainer*) optionsMenuContianerView {
    if (!_optionsMenuContianerView) {
        _optionsMenuContianerView = [[SBBottomViewContrainer alloc] init];
        _optionsMenuContianerView.dragDirection = SBDraggableViewDirectionUpDown;

        CGSize size = CGSizeMake(64, 40);
        CGPoint offset = CGPointMake(60, 20);
        
        UIToolbar *optionsMenuToolbar = _optionsMenuContianerView.toolbar;
        [optionsMenuToolbar addSubview:self.toggleRatioButton];
        [self.toggleRatioButton autoAlignAxis:ALAxisVertical toSameAxisOfView:optionsMenuToolbar];
        [self.toggleRatioButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y];
        [self.toggleRatioButton autoSetDimensionsToSize:size];
        
        size = CGSizeMake(40, 40);
        [optionsMenuToolbar addSubview:self.toggleCameraButton];
        [self.toggleCameraButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.toggleRatioButton withOffset:offset.x];
        [self.toggleCameraButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y];
        [self.toggleCameraButton autoSetDimensionsToSize:size];
        
        [optionsMenuToolbar addSubview:self.flashModeButton];
        [self.flashModeButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.toggleRatioButton withOffset:-offset.x];
        [self.flashModeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y];
        [self.flashModeButton autoSetDimensionsToSize:size];
    }
    return _optionsMenuContianerView;
}

- (UIButton*) toggleRatioButton {
    if (!_toggleRatioButton) {
        _toggleRatioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _toggleRatioButton.frame = CGRectMake(CGRectGetWidth(_bottomContainerView.bounds)/2 - 15.f, 15.f, 30.0, 30.0);
        [_toggleRatioButton setImage:[UIImage imageNamed:@"sb_camera_ratio_16_9"] forState:UIControlStateNormal];
        _toggleRatioButton.imageView.contentMode = UIViewContentModeCenter;
    }
    return _toggleRatioButton;
}

- (UIButton*) toggleCameraButton {
    if (!_toggleCameraButton) {
        _toggleCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _toggleCameraButton.frame = CGRectMake(CGRectGetWidth(_bottomContainerView.bounds)/2 - 15.f, 15.f, 30.0, 30.0);
        [_toggleCameraButton setImage:[UIImage imageNamed:@"sb_camera_flip"] forState:UIControlStateNormal];
        _toggleCameraButton.imageView.contentMode = UIViewContentModeCenter;
    }
    return _toggleCameraButton;
}

- (UIButton*) flashModeButton {
    if (!_flashModeButton) {
        _flashModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashModeButton.frame = CGRectMake(CGRectGetMinX(_bottomContainerView.bounds) + 15.f, 15.f, 30.0, 30.0);
        _flashModeButton.layer.masksToBounds = YES;
        _flashModeButton.imageView.contentMode = UIViewContentModeCenter;
        self.flashMode = AVCaptureFlashModeOff; //sets button image
    }
    return _flashModeButton;
}

- (void) initializeViews {
    //toolbar
    [self addSubview:self.stateToolbar];
    [self.stateToolbar autoCenterInSuperview];
    [self.stateToolbar autoMatchDimension:ALDimensionHeight
                              toDimension:ALDimensionHeight
                                   ofView:self.stateToolbar.superview];
    [self.stateToolbar autoMatchDimension:ALDimensionWidth
                              toDimension:ALDimensionWidth
                                   ofView:self.stateToolbar.superview];
    //shutter view
    [self addSubview:self.shutterView];
    [self.shutterView autoCenterInSuperview];
    [self.shutterView autoMatchDimension:ALDimensionHeight
                             toDimension:ALDimensionHeight
                                  ofView:self.shutterView.superview];
    [self.shutterView autoMatchDimension:ALDimensionWidth
                             toDimension:ALDimensionWidth
                                  ofView:self.shutterView.superview];
    
    //add focus view
    [self.captureView addSubview:self.focusView];
    
    [self addSubview:self.topSquareToolbar];
    [self.topSquareToolbar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self addSubview:self.bottomSquareToolbar];
    [self.bottomSquareToolbar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];

    //optinos menu
    [self addSubview:self.optionsMenuContianerView];
    [self.optionsMenuContianerView adjustConstraintsHidden:YES];
    
    //BOTTOM HUD (contains subviews)
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
    [self.bottomContainerView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self];
    [self.bottomContainerView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
    [self.bottomContainerView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.bottomContainerView autoSetDimension:ALDimensionHeight toSize:100];
    self.optionsMenuButton.bottomContainerView = self.optionsMenuContianerView;
    
    //next button
    [self addSubview:self.nextButton];
    [self.nextButton autoSetDimensionsToSize:CGSizeMake(64, 64)];
    [self adjustNextButtonToOrientation:UIInterfaceOrientationPortrait];

    //TOP HUD (contains subviews)
    [self addSubview:self.topContainerView];
    [self.topContainerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
    [self.topContainerView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self];
    [self.topContainerView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
    [self.topContainerView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    
    //pageView
    [self addSubview:self.pageView];
    [self addSubview:self.timeLabel];
    
    //close button
    [self addSubview:self.closeButton];
    [self.closeButton autoSetDimensionsToSize:CGSizeMake(30, 30)];
    [self.closeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_topContainerView withOffset:10];
    
    //progress bar
    [self addSubview:self.progressBar];
}

- (void) initGestures {
    self.panGesture = [[UIPanGestureRecognizer alloc] init];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    
    self.singleTapGesture = [[UITapGestureRecognizer alloc] init];
    self.singleTapGesture.numberOfTapsRequired = 1;
    self.singleTapGesture.delegate = self;
    [self.captureView addGestureRecognizer:self.singleTapGesture];
    
    self.doubleTapGesture = [[UITapGestureRecognizer alloc] init];
    self.doubleTapGesture.numberOfTapsRequired = 2;
    self.doubleTapGesture.delegate = self;
    [self addGestureRecognizer:self.doubleTapGesture];
    
    NSArray *gestures = @[self.singleTapGesture, self.doubleTapGesture, self.panGesture];
    [gestures setValue:@NO forKey:NSStringFromSelector(@selector(delaysTouchesEnded))];

    [self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    
    @weakify(self);
    [self.panGesture.rac_gestureSignal subscribeNext:^(UIPanGestureRecognizer *panGesture) {
        @strongify(self);
        UIView *view = panGesture.view;
        CGPoint translation = [panGesture translationInView:view];
        
        CGFloat xTrans = 0;
        UIInterfaceOrientation orientation = [[UIDevice currentDevice] interfaceOrientation];
        if ((NSInteger)orientation == -1) orientation = UIInterfaceOrientationPortrait;
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                xTrans = translation.x;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                xTrans = -translation.y;
                break;
            case UIInterfaceOrientationLandscapeRight:
                xTrans = translation.y;
                break;
            default:
                xTrans = -translation.x;
                break;
        }
        
        switch (panGesture.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                if (xTrans > 0) {
                    [self swipedLeft:panGesture];
                } else if (xTrans < 0) {
                    [self swipedRight:panGesture];
                }
                [panGesture setTranslation:CGPointMake(0, 0) inView:view];
                break;
                
            default:
                break;
        }
    }];
    [[self.singleTapGesture rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *gesture) {
        @strongify(self);
        [self updateFocusPoint:[gesture locationInView:gesture.view] alpha:1];
        [self animateFocusViewHideWithDuration:0.5 delay:0.5 completion:nil];
    }];
}

- (instancetype) initWithFrame:(CGRect)frame captureManager:(SBCaptureManager*)captureManager {
    if (self = [super initWithFrame:frame]) {
        
        self.squareVideoOffsetBottom = 20;
        
        //capture view container
        [self addSubview:self.captureViewContainer];
        self.captureView = [[SBCaptureView alloc] initWithCaptureSession:captureManager.captureSession];
        [self.captureViewContainer addSubview:self.captureView];

        [self initializeViews];
        [self setVideoCaptureTypeWithAspectRatio:SBCameraAspectRatioNormal];
        
        [self initGestures];
        
        @weakify(self);
        void (^orientationChange) (NSNotification*) = ^(NSNotification *note) {
            @strongify(self);
            UIInterfaceOrientation orientation = [[UIDevice currentDevice] interfaceOrientation];
            if ((NSInteger)orientation == -1 && note != nil)
                return;
            
            [self adjustTopViewsToOrientation:orientation];
            [self adjustNextButtonToOrientation:orientation];
            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0.0 options:0 animations:^{
                [self adjustViewTransformsToOrientation:orientation];
                [self.superview layoutIfNeeded];
            } completion:nil];
            
            
            [self adjustAndAnimateProgressBarWithDuration:.8f delayBetween:.3f fromOrientation:self.orientation toOrientation:orientation];
            self.orientation = orientation;
        };
        orientationChange(nil);
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:orientationChange];

        [[self.recordButton rac_valuesAndChangesForKeyPath:NSStringFromSelector(@selector(holding)) options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld observer:nil] subscribeNext:^(RACTuple *tuple) {
            @strongify(self);
            BOOL isNowHolding = [tuple.first boolValue];
            BOOL wasHolding = [[tuple.second valueForKey:NSKeyValueChangeOldKey] boolValue];
            if (isNowHolding == NO && wasHolding == YES) {
                [self.progressBar addCurrentValueToStopValues];
            }
        }];
        
        [RACObserve(self.stateToolbar, hidden) subscribeNext:^(NSNumber *n) {
            @strongify(self);
            BOOL isHidden = n.boolValue;
            self.captureView.hidden = !isHidden;
        }];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setFlashMode:(SBCaptureFlashMode)flashMode {
    [self willChangeValueForKey:@"flashMode"];
    _flashMode = flashMode;
    [self didChangeValueForKey:@"flashMode"];
    
    switch (flashMode) {
        case SBCaptureFlashModeOn:
            [_flashModeButton setImage:[UIImage imageNamed:@"sb_camera_flash_on"] forState:UIControlStateNormal];
            break;
        case SBCaptureFlashModeAuto:
            [_flashModeButton setImage:[UIImage imageNamed:@"sb_camera_flash_auto"] forState:UIControlStateNormal];
            break;
        default:
            [_flashModeButton setImage:[UIImage imageNamed:@"sb_camera_flash_off"] forState:UIControlStateNormal];
            break;
    }
}

- (void) setAspectRatio:(SBCameraAspectRatio)aspectRatio {
    [self willChangeValueForKey:@"aspectRatio"];
    _aspectRatio = aspectRatio;
    [self didChangeValueForKey:@"aspectRatio"];
    
    if (self.captureType == SBCaptureTypeVideo) {
        switch (aspectRatio) {
            case SBCameraAspectRatioSquare: [_toggleRatioButton setImage:[UIImage imageNamed:@"sb_camera_ratio_1_1"] forState:UIControlStateNormal]; break;
            default: [_toggleRatioButton setImage:[UIImage imageNamed:@"sb_camera_ratio_16_9"] forState:UIControlStateNormal]; break;
        }
    }
    
    [self adjustSquareToolbarConstraintsForAspectRatio:aspectRatio captureType:self.captureType];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        [self layoutSubviews];
    } completion:nil];
}

- (void) setPhotoCaptureTypeWithAspectRatio:(SBCameraAspectRatio)ratio {
    _captureType = SBCaptureTypePhoto;
    self.aspectRatio = ratio;
    
    NSString *videoGravity = ratio == SBCameraAspectRatioSquare ? AVLayerVideoGravityResizeAspectFill : AVLayerVideoGravityResizeAspect;
    if (isSmallScreen()) videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureView.captureLayer.videoGravity = videoGravity;
    
    [self animateView:self.chooseExistingButton toAlpha:1 duration:0.3 completion:nil];
    [self animateView:self.toggleRatioButton toAlpha:0 duration:0.3 completion:nil];
    [self adjustCameraConstraintsForRatio:self.aspectRatio captureType:self.captureType];
    [self layoutSubviews];
}

- (void) setVideoCaptureTypeWithAspectRatio:(SBCameraAspectRatio)ratio {
    _captureType = SBCaptureTypeVideo;
    self.aspectRatio = ratio;
    
    NSString *videoGravity = AVLayerVideoGravityResizeAspect;
    if (isSmallScreen()) videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureView.captureLayer.videoGravity = videoGravity;
    
    [self animateView:self.chooseExistingButton toAlpha:0 duration:0.3 completion:nil];
    [self animateView:self.toggleRatioButton toAlpha:1 duration:0.3 completion:nil];
    [self adjustCameraConstraintsForRatio:self.aspectRatio captureType:self.captureType];
    [self layoutSubviews];
}

- (BOOL) isHudHidden {
    return _bottomContainerView.alpha == 0;
}

#pragma mark - Actions
- (void)swipeToIndex:(NSInteger)toIndex {
    if (toIndex >= 0 && toIndex <= self.pageView.labels.count-1) {
        if (self.shouldAllowPageViewIndexChange) {
            if (self.shouldAllowPageViewIndexChange(self.pageView.index, toIndex)) {
                self.pageView.index = toIndex;
            }
        } else {
            self.pageView.index = toIndex;
        }
    }
}

- (void)swipedLeft:(UIPanGestureRecognizer*)sender {
    if (self.progressBar.value > 0) return;
    [self swipeToIndex:self.pageView.index+1];
}
- (void)swipedRight:(UIPanGestureRecognizer*)sender {
    if (self.progressBar.value > 0) return;
    [self swipeToIndex:self.pageView.index-1];
}

#pragma mark - RAC
- (RACSignal*) focusPointChangeSignal {
    @weakify(self);
    RACSignal *signal = [[RACObserve(self.focusView, frame) skip:1] map:^id(NSValue *value) {
        @strongify(self);
        CGRect frame = [value CGRectValue];
        CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        return [NSValue valueWithCGPoint:[self.captureView.captureLayer captureDevicePointOfInterestForPoint:center]];
    }];
    return signal;
}

- (RACSignal*) doubleTapSignal {
    return [self.doubleTapGesture rac_gestureSignal];
}

- (RACSignal*) swipeLeftSignal {
    return [self rac_signalForSelector:@selector(swipedLeft:)];
}

- (RACSignal*) swipeRightSignal {
    return [self rac_signalForSelector:@selector(swipedRight:)];
}

#pragma mark - Focus Point
- (void) didSingleTap:(CGPoint)location {
    [self updateFocusPoint:location alpha:1];
    [self animateFocusViewHideWithDuration:0.5 delay:0.5 completion:nil];
}

- (void) updateFocusPoint:(CGPoint)position alpha:(CGFloat)alpha {
    if (self.shouldUpdateFocusPosition && !self.shouldUpdateFocusPosition(position))
        return;
    
    CGRect frame = self.focusView.frame;
    frame.origin = CGPointMake(position.x-CGRectGetWidth(frame)/2, position.y-CGRectGetHeight(frame)/2);
    self.focusView.frame = frame;
    self.focusView.alpha = alpha;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return !(CGRectContainsPoint(self.recordButton.bounds, [touch locationInView:self.recordButton])
             || CGRectContainsPoint(self.bottomContainerView.bounds, [touch locationInView:self.bottomContainerView])
             || CGRectContainsPoint(self.topContainerView.bounds, [touch locationInView:self.topContainerView])
             || CGRectContainsPoint(self.nextButton.bounds, [touch locationInView:self.nextButton]));
}

#pragma mark - Animations
- (void) animateHudHidden:(BOOL)hidden completion:(void (^)(BOOL))completion {
    [self animateHudHidden:hidden duration:0.5f completion:completion];
}

-(void)animateHudHidden:(BOOL)hidden duration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion {
    CGFloat toValue = hidden ? 0 : 1.0f;
//    CGFloat bottomHudBGToValue = hidden ? 0 : .35f;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:.5 options:0 animations:^{
        NSArray *bottomViews = [_bottomContainerView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"not SELF in %@", @[_recordButton, _chooseExistingButton]]];
        [bottomViews setValue:@(toValue) forKey:@"alpha"];
        _topContainerView.alpha = toValue;
        if (hidden) {
            _chooseExistingButton.alpha = toValue;
        } else if (self.captureType != SBCaptureTypeVideo) {
            _chooseExistingButton.alpha = toValue;
        }
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}

-(void)animateShutter:(void(^)(BOOL finished))completion {
    [self animateShutterWithDuration:.1 completion:completion];
}
-(void)animateShutterWithDuration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion {
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0 animations:^{
            self.shutterView.alpha = 1;
        }];
        [UIView addKeyframeWithRelativeStartTime:1 relativeDuration:0 animations:^{
            self.shutterView.alpha = 0;
        }];
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}

- (void) animateFocusViewHideWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:1 initialSpringVelocity:.5 options:0 animations:^{
        self.focusView.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}

- (void) animateViews:(NSArray*)views toAlpha:(CGFloat)toAlpha duration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion {
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [self animateView:view toAlpha:toAlpha duration:duration completion:completion];
    }];
}

- (void) animateView:(UIView*)view toAlpha:(CGFloat)toAlpha duration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:.5 options:0 animations:^{
        [view setValue:@(toAlpha) forKey:NSStringFromSelector(@selector(alpha))];
    } completion:completion];
}

#pragma mark - View layout adjusting
- (void) updateConstraints {
    [super updateConstraints];
    [self adjustSquareToolbarConstraintsForAspectRatio:self.aspectRatio captureType:self.captureType];
}

- (void) adjustViewTransformsToOrientation:(UIInterfaceOrientation)orientation {
    CGAffineTransform toVal = self.flashModeButton.transform;
    switch (orientation) {
        case UIInterfaceOrientationPortrait: toVal = CGAffineTransformMakeRotation(0); break;
        case UIInterfaceOrientationLandscapeLeft : toVal = CGAffineTransformMakeRotation(M_PI_2); break;
        case UIInterfaceOrientationLandscapeRight: toVal = CGAffineTransformMakeRotation(M_PI + M_PI_2); break;
        case UIInterfaceOrientationPortraitUpsideDown: toVal = CGAffineTransformMakeRotation(M_PI); break;
        default: break;
    }
    NSArray *toTransform = @[self.flashModeButton, self.toggleCameraButton, self.pageView, self.toggleRatioButton, self.timeLabel, self.nextButton];
    [toTransform setValue:[NSValue valueWithCGAffineTransform:toVal] forKey:NSStringFromSelector(@selector(transform))];
}

- (void) adjustTopViewsToOrientation:(UIInterfaceOrientation)orientation {
    [self.topViewsConstraints autoRemoveConstraints];
    NSMutableArray *constraints = [NSMutableArray array];
    
    //page view & time label & progress bar
    CGSize size = CGSizeMake(255, 40);
    CGPoint offset = CGPointMake(size.width/2-size.height/2, 5);
    [constraints addObjectsFromArray:[self.pageView autoSetDimensionsToSize:size]];
    
    [self.timeLabel sizeToFit];
    CGSize labelSize = CGSizeMake(CGRectGetWidth(self.timeLabel.frame)+15, 40);
    CGPoint labelOffset = CGPointMake(0, 7);
    [constraints addObjectsFromArray:[self.timeLabel autoSetDimensionsToSize:labelSize]];
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeRight:
            [constraints addObject:[self.pageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:-offset.x]];
            [constraints addObject:[self.pageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self]];
            
            //time label
            [constraints addObject:[self.timeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:-labelOffset.x]];
            [constraints addObject:[self.timeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self]];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [constraints addObject:[self.pageView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:offset.x]];
            [constraints addObject:[self.pageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self]];
            
            //time label
            [constraints addObject:[self.timeLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:labelOffset.x]];
            [constraints addObject:[self.timeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self]];
            break;
        default:
            [constraints addObject:[self.pageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.topContainerView withOffset:offset.y]];
            [constraints addObject:[self.pageView autoAlignAxis:ALAxisVertical toSameAxisOfView:self]];
            
            //time label
            [constraints addObject:[self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.topContainerView withOffset:labelOffset.y]];
            [constraints addObject:[self.timeLabel autoAlignAxisToSuperviewAxis:ALAxisVertical]];
            break;
    }
    
    //close button
    offset = CGPointMake(10, 10);
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [constraints addObject:[self.closeButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_topContainerView withOffset:-offset.x]];
    } else {
        [constraints addObject:[self.closeButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_topContainerView withOffset:offset.x]];
    }
    
    self.topViewsConstraints = [constraints copy];
}

- (void)adjustNextButtonToOrientation:(UIInterfaceOrientation)orientation {
    [self.nextButtonConstraints autoRemoveConstraints];
    NSMutableArray *constraints = [NSMutableArray array];
    
    CGPoint offset = CGPointMake(10, 20);
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            [constraints addObject:[self.nextButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.recordButton withOffset:-offset.x]];
            [constraints addObject:[self.nextButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.bottomContainerView withOffset:-offset.y]];
            break;
        case UIInterfaceOrientationPortrait:
            [constraints addObject:[self.nextButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.recordButton withOffset:offset.x]];
            [constraints addObject:[self.nextButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.bottomContainerView withOffset:-offset.y]];
            break;
        default:
            [constraints addObject:[self.nextButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.recordButton withOffset:-5]];
            [constraints addObject:[self.nextButton autoAlignAxisToSuperviewAxis:ALAxisVertical]];
            break;
    }

    self.nextButtonConstraints = [constraints copy];
}

- (void) adjustProgressBarToOrientation:(UIInterfaceOrientation)orientation withPinOffset:(CGFloat)offset{
    [self.progressBarConstraints autoRemoveConstraints];
    NSMutableArray *constraints = [NSMutableArray array];
    switch (orientation) {
        case UIInterfaceOrientationLandscapeRight:
            [constraints addObject:[self.progressBar autoSetDimension:ALDimensionWidth toSize:5.0f]];
            [constraints addObject:[self.progressBar autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self]];
            [constraints addObject:[self.progressBar autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self]];
            [constraints addObject:[self.progressBar autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:offset]];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [constraints addObject:[self.progressBar autoSetDimension:ALDimensionWidth toSize:5.0f]];
            [constraints addObject:[self.progressBar autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self]];
            [constraints addObject:[self.progressBar autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self]];
            [constraints addObject:[self.progressBar autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-offset]];
            break;
        default:
            [constraints addObject:[self.progressBar autoSetDimension:ALDimensionHeight toSize:5.0f]];
            [constraints addObject:[self.progressBar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self]];
            [constraints addObject:[self.progressBar autoAlignAxis:ALAxisVertical toSameAxisOfView:self]];
            [constraints addObject:[self.progressBar autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:offset]];
            break;
    }
    
    self.progressBar.options = SBProgressBarOptionsFromOrientation(orientation);
    [self.progressBar setNeedsDisplay];
    
    self.progressBarConstraints = [constraints copy];
}

- (void) adjustAndAnimateProgressBarWithDuration:(NSTimeInterval)duration delayBetween:(NSTimeInterval)delay fromOrientation:(UIInterfaceOrientation)fromOrientation toOrientation:(UIInterfaceOrientation)toOrientation {
    if (fromOrientation == toOrientation || toOrientation == UIDeviceOrientationUnknown)
        return;
    
    if (fromOrientation == UIDeviceOrientationUnknown) {
        [self adjustProgressBarToOrientation:toOrientation withPinOffset:0];
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.8 initialSpringVelocity:0 options:0 animations:^{
            [self layoutSubviews];
        } completion:nil];
        return;
    }
    
    duration /= 2;
    CGFloat min = MIN(CGRectGetWidth(self.progressBar.frame), CGRectGetHeight(self.progressBar.frame));
    [self adjustProgressBarToOrientation:fromOrientation withPinOffset:-min];
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        self.progressBar.hidden = YES;
        [self adjustProgressBarToOrientation:toOrientation withPinOffset:-min];
        [self layoutSubviews];
        
        [self adjustProgressBarToOrientation:toOrientation withPinOffset:0];
        self.progressBar.hidden = NO;
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:.8 initialSpringVelocity:0 options:0 animations:^{
            [self layoutSubviews];
        } completion:nil];
    }];
}

- (void) adjustSquareToolbarConstraintsForAspectRatio:(SBCameraAspectRatio)ratio captureType:(SBCaptureType)captureType {
    [self.squareToolbarConstraints autoRemoveConstraints];
    NSMutableArray *constraints = [NSMutableArray array];
    
    CGFloat padding = 5;
    CGFloat height = (CGRectGetHeight(self.frame) - CGRectGetWidth(self.frame)) / 2;
    CGFloat heightBottom = height + self.squareVideoOffsetBottom;
    CGFloat heightTop = height - self.squareVideoOffsetBottom;
    [constraints addObject:[self.topSquareToolbar autoSetDimension:ALDimensionHeight toSize:heightTop+padding]];
    [constraints addObject:[self.bottomSquareToolbar autoSetDimension:ALDimensionHeight toSize:heightBottom+padding]];
    
    if (captureType == SBCaptureTypeVideo) {
        if (ratio == SBCameraAspectRatioSquare) {
            [constraints addObject:[self.topSquareToolbar autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:-padding]];
            [constraints addObject:[self.bottomSquareToolbar autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:padding]];
        } else {
            [constraints addObject:[self.topSquareToolbar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self withOffset:-1]];
            [constraints addObject:[self.bottomSquareToolbar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self withOffset:1]];
        }
    }
    
    else {
        [constraints addObject:[self.topSquareToolbar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self withOffset:-1]];
        [constraints addObject:[self.bottomSquareToolbar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self withOffset:1]];
    }
    
    self.squareToolbarConstraints = [constraints copy];
}

- (void) adjustCameraConstraintsForRatio:(SBCameraAspectRatio)ratio captureType:(SBCaptureType)captureType{
    [self.cameraConstraints autoRemoveConstraints];
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:[self.captureView autoCenterInSuperview]];
    [constraints addObject:[self.captureView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.captureViewContainer]];
    
    if (captureType == SBCaptureTypeVideo) {
        [constraints addObjectsFromArray:[self.captureViewContainer autoCenterInSuperview]];
        [constraints addObject:[self.captureViewContainer autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self]];
        [constraints addObject:[self.captureViewContainer autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self]];
        
        [constraints addObject:[self.captureView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.captureViewContainer]];
    } else {
        
        if (isSmallScreen() && ratio == SBCameraAspectRatioNormal) {
            [constraints addObjectsFromArray:[self.captureViewContainer autoCenterInSuperview]];
            [constraints addObject:[self.captureViewContainer autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self]];
            [constraints addObject:[self.captureViewContainer autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self]];
            
            [constraints addObject:[self.captureView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.captureViewContainer]];
        } else {
            [constraints addObject:[self.captureViewContainer autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.topContainerView]];
            [constraints addObject:[self.captureViewContainer autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeTop ofView:self.bottomContainerView]];
            [constraints addObject:[self.captureViewContainer autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self]];
            
            if (ratio == SBCameraAspectRatioNormal) {
                [constraints addObject:[self.captureView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.captureViewContainer]];
            } else {
                [constraints addObject:[self.captureView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.captureViewContainer]];
            }
            
        }
    }
    self.cameraConstraints = [constraints copy];
}

@end
