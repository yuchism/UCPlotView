//
//  CLFRecordingPlotView.h
//  CloseFriends
//
//  Created by John Y on 16/04/2015.
//  Copyright (c) 2015 CloseFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UCPlotViewModeProgress = 1,
    UCPlotViewModeMetering,
} UCPlotViewMode;

IB_DESIGNABLE
@interface UCPlotView : UIView

- (void) addCurrentPeak:(NSNumber *)number;
- (void) setPeeks:(NSArray *)array;
- (void) reset;

@property(nonatomic,strong) UIColor *plotColor;
@property(nonatomic) UIColor *plotBGColor;
@property(nonatomic,strong) UIColor *progressColor;
@property(nonatomic,readonly) UIView *bgView;

@property(nonatomic) UCPlotViewMode mode;
@property(nonatomic) CGFloat progress;


@property(nonatomic) CGFloat plotWidth;
@property(nonatomic) CGFloat plotMargin;
@end