//
//  ViewController.m
//  Graph
//
//  Created by John Y on 16/04/2015.
//  Copyright (c) 2015 John Y. All rights reserved.
//

#import "ViewController.h"
#import "UCPlotView.h"

@interface ViewController ()
{
    NSTimer *timer; 
}
@property (weak, nonatomic) IBOutlet UCPlotView *progressView;
@property (weak, nonatomic) IBOutlet UCPlotView *incrementalView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressView.mode = UCPlotViewModeProgress;
    self.incrementalView.mode = UCPlotViewModeIncrement;
    
    
    self.progressSlider.value = 0.0f;
    self.progressSlider.maximumValue = 1.0f;
    self.progressSlider.minimumValue = 0.0f;
    
    self.progressView.progressColor = [UIColor redColor];
    self.progressView.plotColor = [UIColor blueColor];
    
    
    //generate values
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 200; i ++)
    {
        CGFloat num = arc4random_uniform(100) / 100.0f;
        [array addObject:[NSNumber numberWithFloat:num]];
    }
    [self.progressView setPeeks:array];
    [self.progressSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self startTimer];
}


#pragma mark -- For progressView Mode
- (void) valueChanged:(UISlider *)sender
{
    self.progressView.progress = sender.value;
}


#pragma mark -- For incrementalView Mode
- (void) startTimer
{
    [self stopTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void)tick:(NSTimer *)timer
{
    CGFloat num = arc4random_uniform(100) / 100.0f;
    [self.incrementalView addCurrentPeak:[NSNumber numberWithFloat:num]];
}

- (void) stopTimer
{
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

- (IBAction)actionTap:(id)sender
{
    [self.incrementalView reset];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.progressView setNeedsDisplay];
    [self.incrementalView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end