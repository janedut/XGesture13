#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)
int applicationDidFinishLaunching;




// Adds a bottom inset to the camera app.

%hook CAMBottomBar
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y -40));
}
%end

%hook CAMZoomControl
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y -30));
}
%end

// Hide the homebar on the springboard (everywhere except lockscreen)
%hook SBHomeGrabberView
- (void)setHidden:(BOOL)arg1 forReason:(id)arg2 withAnimationSettings:(id)arg3 {
  %orig(YES, arg2, arg3);
}
%end

/* Hide 'Press home to open' label in lockscreen */
%hook CSFixedFooterView
-(void)setCallToActionLabel:(id)arg1 {}
%end

// disableGesturesWhenKeyboard
BOOL disableGestures = NO;
%hook SBFluidSwitcherGestureManager
-(void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3  {
    if (!disableGestures)
        %orig;
}
%end




// Reduce reachability sensitivity.
%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double) systemWideSwipeDownHeight {
    %orig(100);
}
%end


// No gesture when landscape
%hook SBFluidSwitcherGestureExclusionTrapezoid

-(BOOL)shouldBeginGestureAtStartingPoint:(CGPoint)arg1 velocity:(CGPoint)arg2 bounds:(CGRect)arg3 {
    return NO;
}

-(BOOL)allowHorizontalSwipesOutsideTrapezoid {
    return NO;
}

%end



// LS Quick-Toggles
@interface CSQuickActionsView : UIView
- (UIEdgeInsets)_buttonOutsets;
@property (nonatomic, retain) UIControl *flashlightButton;
@property (nonatomic, retain) UIControl *cameraButton;
@end

%hook CSQuickActionsView
- (BOOL)_prototypingAllowsButtons {
	return NO;
}
%end

// Default Keyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
        orig.bottom = 0;
    return orig;
}
%end




// Enable Home Gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
		return 2;
}
%end

// Restore Button To Invoke Siri
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
	return %orig(1, arg2);
}
%end
%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
	return %orig(1);
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    applicationDidFinishLaunching = 2;
    %orig;
}
%end

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray * lockHome = @[@104, @101];
    NSArray * lockVol = @[@104, @102, @103];
    if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
        %orig(lockHome);
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
    if (applicationDidFinishLaunching == 1) {
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1,1);
}
%end

 //hide statusbar in cc
%hook CCUIModularControlCenterOverlayViewController
- (void)setOverlayStatusBarHidden:(BOOL)arg1 {
    return;
}
%end
// No Home Bar
%hook MTLumaDodgePillSettings
- (void)setHeight:(double)arg1 {
	arg1 = 0;
	%orig;
}
%end
%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
    return;
}
%end

%ctor {
    @autoreleasepool {
        if (1) {
            [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                       disableGestures = true;
                    }];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                        disableGestures = false;
                    }];

          //  %init(disableGesturesWhenKeyboard);
        }

    }
}
