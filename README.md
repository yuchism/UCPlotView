# UCPlotView
Draw progress or metering when using AVAudioPlayer / AVAudioRecorder for iOS

![alt tag](https://raw.githubusercontent.com/yuchism/UCPlotView/master/ScreenShot/screenshot.png)


# How to use
### ProgressMode

```objectivec
self.progressView.mode = UCPlotViewModeProgress;
self.progressView.progressColor = [UIColor redColor];
self.progressView.plotColor = [UIColor blueColor];
[self.progressView setPeaks:@[@0.1,@0.2,@0.5,@1.0]];

self.progressView.progress = .5;
```

### MeteringMode

```objectivec
self.incrementView.mode = UCPlotViewModeMetering;
[self.incrementView addCurrentPeak:@0.5];
```

