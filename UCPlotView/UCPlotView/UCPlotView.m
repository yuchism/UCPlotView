//
//  CLFRecordingPlotView.m
//  CloseFriends
//
//  Created by John Y on 16/04/2015.
//  Copyright (c) 2015 CloseFriends. All rights reserved.
//

#import "UCPlotView.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

typedef enum {
    UCPlotDirectionLeftToRight=1,
    UCPlotDirectionRightToLeft,
} UCPlotDirection;


@implementation NSArray(Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
@end

@implementation NSMutableArray (Queue)

- (void)enqueue:(id)object {
    if (object) {
        [self addObject:object];
    }
}

- (id)dequeue {
    id result = nil;
    if (self.count > 0) {
        result = [self firstObject];
        [self removeObjectAtIndex:0];
    }
    return result;
}

- (id)top {
    id top = nil;
    if (self.count > 0) {
        top = [self firstObject];
    }
    return top;
}

@end


#define kLineOffset 1.0f
#define kLineWidth 2.0f
#define kLineLengthPerUnit (kLineWidth + kLineOffset)
#define kMinimumHeight .5f

@interface UCPlotView()
{
    NSMutableArray *_queue;
    UIColor *_plotColor;
    UIColor *_progressColor;
    CGFloat _progress;
    CAShapeLayer *_progressLayer;


    UCPlotDirection _direction;
    UCPlotViewMode _mode;
}
@property(nonatomic,strong) CAShapeLayer *progressLayer;
@property(nonatomic) UCPlotDirection direction;
@end


@implementation UCPlotView
@synthesize plotColor = _plotColor;
@synthesize progressColor = _progressColor;
@synthesize direction = _direction;
@synthesize progress = _progress;
@synthesize mode = _mode;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _plotColor = UIColorFromRGB(0x00AAE7);
    _progressColor = UIColorFromRGB(0x00AAE7);
    _queue = [[NSMutableArray alloc] init];
    _progressLayer = nil;
    self.mode = UCPlotViewModeProgress;
}

- (void)setMode:(UCPlotViewMode)mode
{
    _mode = mode;
    if(mode == UCPlotViewModeProgress)
    {
        _direction = UCPlotDirectionLeftToRight;
    }
    else
    {
        _direction = UCPlotDirectionRightToLeft;
    }
    
}

- (void)reset
{
    [_queue removeAllObjects];
    self.progress = 0.0f;
    [self setNeedsDisplay];
}

// range of number is between 0 and 1.0
- (void) addCurrentPeak:(NSNumber *)number
{
    [_queue enqueue:number];
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void) setPeeks:(NSArray *) array;
{
    [_queue setArray:array];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    
    if(self.progressLayer)
    {
        [self.progressLayer removeFromSuperlayer];
        self.progressLayer = nil;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);

    CGFloat middle = CGRectGetHeight(self.frame) / 2;
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    
    NSInteger needPoint = viewWidth / (kLineLengthPerUnit);
    NSArray * displayArray = nil;

    CGFloat plotViewWidth = (kLineLengthPerUnit * ([_queue count] * 1.0));
    CGFloat progressPoint = plotViewWidth * _progress;
    
    
    if(_mode == UCPlotViewModeProgress)
    {
        if([_queue count] < needPoint)
        {
            displayArray = _queue;

        } else
        {
            // graph total width
            // needPoint 10 : 0 - 9;
            NSRange range = NSMakeRange(0, 0);
            NSInteger currentIdx = [_queue count] * _progress;
            NSInteger halfOfNeedPoint = (needPoint / 2);
    
            if(currentIdx < halfOfNeedPoint)
            {
                range = NSMakeRange(0, needPoint);
            } else if(currentIdx >= halfOfNeedPoint && (currentIdx + halfOfNeedPoint) < [_queue count])
            {
                range = NSMakeRange(currentIdx - (halfOfNeedPoint), needPoint);
                
            } else if((currentIdx + halfOfNeedPoint) >= [_queue count])
            {
                range = NSMakeRange([_queue count] - needPoint, needPoint);
            }
            
            
            CGFloat currentPoint = plotViewWidth * _progress;
            CGFloat halfOfView = (viewWidth / 2.0);
            
            if(currentPoint > halfOfView && (currentPoint + halfOfView) < plotViewWidth)
            {
                progressPoint = halfOfView;
                
            } else if((currentPoint + halfOfView) >= plotViewWidth)
            {
                progressPoint = viewWidth - (plotViewWidth - currentPoint);
            }
            
            displayArray = [_queue subarrayWithRange:range];
        }
    }
    else
    {
        if([_queue count] < needPoint)
        {
            displayArray = _queue;
        } else
        {
            NSRange range = {([_queue count] - needPoint) , needPoint};
            displayArray = [_queue subarrayWithRange:range];
        }
    }
    
    CGFloat startX = 0.0f;
    
    
    if(_direction == UCPlotDirectionRightToLeft)
    {
        startX = viewWidth;
        displayArray = [displayArray reversedArray];
    }
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef maskPath = CGPathCreateMutable();
    for (NSNumber *number in displayArray)
    {
        
        CGFloat height = (CGRectGetHeight(self.frame)/2) * [number floatValue];
        
        height =  (height < kMinimumHeight) ? kMinimumHeight : height;
        CGPathMoveToPoint(maskPath, nil, startX, middle - height);
        CGPathAddLineToPoint(maskPath, nil, startX, middle + height);
        maskLayer.lineWidth = kLineWidth;
        
        startX = (_direction == UCPlotDirectionLeftToRight) ? startX + kLineLengthPerUnit : startX - kLineLengthPerUnit;

    }
    
    if(_mode == UCPlotViewModeProgress)
    {
        while (startX < CGRectGetWidth(self.bounds)) {
            
            CGPathMoveToPoint(maskPath, nil ,startX, middle - kMinimumHeight);
            CGPathAddLineToPoint(maskPath, nil ,startX, middle + kMinimumHeight);
            
            startX = startX + kLineLengthPerUnit;
        }
    }
    
    [maskLayer setStrokeColor:self.plotColor.CGColor];
    [maskLayer setFillColor:[UIColor clearColor].CGColor];
    [maskLayer setPath:maskPath];
    
    [self.layer addSublayer:maskLayer];
    CGPathRelease(maskPath);
    
    
    CAShapeLayer *headLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef headPath = CGPathCreateMutable();
    CGPathAddRect(headPath, nil, CGRectMake(0, 0, progressPoint, CGRectGetHeight(self.frame)));
    [headLayer setPath:headPath];
    [headLayer setFillColor:self.progressColor.CGColor];
    [headLayer setStrokeColor:self.progressColor.CGColor];

    CGPathRelease(headPath);
    
    
    CAShapeLayer *tailLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef tailPath = CGPathCreateMutable();
    CGPathAddRect(tailPath, nil, CGRectMake(progressPoint, 0, CGRectGetWidth(self.frame) - progressPoint, CGRectGetHeight(self.frame)));
    [tailLayer setPath:tailPath];
    [tailLayer setFillColor:self.plotColor.CGColor];
    [tailLayer setStrokeColor:self.plotColor.CGColor];
    CGPathRelease(tailPath);
    
    
    self.progressLayer = [[CAShapeLayer alloc] init];
    [self.progressLayer addSublayer:headLayer];
    [self.progressLayer addSublayer:tailLayer];
    self.progressLayer.mask = maskLayer;
    
    [self.layer addSublayer:self.progressLayer];
    
    CGContextSaveGState(ctx);

}


@end
