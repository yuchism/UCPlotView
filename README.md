# UCPlotView
Draw progress or metering when using AVAudioPlayer / AVAudioRecorder for iOS

![alt tag](https://raw.githubusercontent.com/yuchism/UCPlotView/master/UCPlotView/screenshot.png)




## mode
### ProgressMode

```objectivec
    self.progressView.mode = UCPlotViewModeProgress;
    self.progressView.progressColor = [UIColor redColor];
    self.progressView.plotColor = [UIColor blueColor];
	[self.progressView setPeaks:@[@0.1,@0.2,@0.5,@1.0]];
	
	self.progressView.progress = .5;
```

![alt tag](https://raw.githubusercontent.com/yuchism/UCPlotView/master/UCPlotView/progressmodeScreenShot.png)

### incrementMode

```objectivec
	self.incrementView.mode = UIPlotViewModeIncrement;
	[self.incrementView addCurrentPeak:@0.5];
```

![alt tag](https://raw.githubusercontent.com/yuchism/UCPlotView/master/UCPlotView/progressmodeScreenShot.png)