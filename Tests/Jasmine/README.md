## Useful links

[Official Jasmine wiki](https://github.com/pivotal/jasmine/wiki)

[Apple docs on UIAutomation instrument](https://developer.apple.com/library/prerelease/ios/#documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Built-InInstruments/Built-InInstruments.html)

[Apple docs on UIAutomation JS classes](https://developer.apple.com/library/prerelease/ios/#documentation/DeveloperTools/Reference/UIAutomationRef/_index.html#//apple_ref/doc/uid/TP40009771)

## UI Automation

UI Automation has a few issues, to make it work on simulator you need to launch it as follows:

```shell

XCODE_PATH=`xcode-select -print-path`
TPL=$XCODE_PATH/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate
APP=/Users/USERNAME/Library/Developer/Xcode/DerivedData/APP-RANDOMHASH/Build/Products/CONFIG-iphonesimulator/APPNAME.app
    
instruments -t "$TPL" "$APP" -e UIASCRIPT PATHTOYOUR/suite.js -e UIARESULTSPATH PATHTO/ARTIFACTS
```

## Sample spec

```javascript
describe("PocketCasts", function() {
    var target = UIATarget.localTarget();
    
    function dumpTree() {
        UIATarget.localTarget().frontMostApp().logElementTree();
    }
    
    function pickVideoWithIndex(i) {
        target.frontMostApp().mainWindow().tableViews()[0].visibleCells()[i].tap();
    }
    
    function firstTableGroup() {
        return target.frontMostApp().mainWindow().tableViews()[0].groups()[0];
    }
    
    function goBack() {
        target.frontMostApp().navigationBar().leftButton().tap();
    }
    
    afterEach(function(){
        goBack();
    });
    
    it("should show download button for video, that is not downloaded", function(){
        pickVideoWithIndex(0);
        expect(firstTableGroup().name()).toEqual("Tap to download video");
    });
    
    it("should show play button for video that is downloaded", function(){
        pickVideoWithIndex(1);
        expect(firstTableGroup().name()).toEqual("Tap to play video");
    });
    
    it("should show subscribe button for pro video when there's no subscription", function(){
        pickVideoWithIndex(2);
        expect(firstTableGroup().name()).toEqual("Tap to subscribe at railscasts.com");
    });
});
```

## Sample output

```shell
% instruments -t "$TPL" "$APP" -e UIASCRIPT AutomationTests/suite.js
2012-02-10 10:07:12 +0000 Start: PocketCasts should show download button for video, that is not downloaded.
2012-02-10 10:07:12 +0000 Debug: target.frontMostApp().mainWindow().tableViews()[0].visibleCells()[0].tap()
2012-02-10 10:07:14 +0000 Debug: target.frontMostApp().navigationBar().leftButton().tap()
2012-02-10 10:07:14 +0000 Pass: Passed
2012-02-10 10:07:14 +0000 Start: PocketCasts should show play button for video that is downloaded.
2012-02-10 10:07:14 +0000 Debug: target.frontMostApp().mainWindow().tableViews()[0].visibleCells()[1].tap()
2012-02-10 10:07:17 +0000 Debug: target.frontMostApp().navigationBar().leftButton().tap()
2012-02-10 10:07:17 +0000 Fail: Expected 'Tap to download video' to equal 'Tap to play video'.

2012-02-10 10:07:17 +0000 Start: PocketCasts should show subscribe button for pro video when there's no subscription.
2012-02-10 10:07:17 +0000 Debug: target.frontMostApp().mainWindow().tableViews()[0].visibleCells()[2].tap()
2012-02-10 10:07:19 +0000 Debug: target.frontMostApp().navigationBar().leftButton().tap()
2012-02-10 10:07:19 +0000 Fail: Expected 'Tap to download video' to equal 'Tap to subscribe at railscasts.com'.

Instruments Trace Complete (Duration : 8.940802s; Output : /Users/farcaller/Developer/Active/pocketcasts/PocketCasts/instrumentscli4.trace)
```
