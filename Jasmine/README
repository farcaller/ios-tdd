## Useful links

https://github.com/pivotal/jasmine/wiki -- official Jasmine wiki

## UI Automation

UI Automation has a few issues, to make it work on simulator you need to launch it as follows:

    TPL=/Developer/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate
    APP=/Users/USERNAME/Library/Developer/Xcode/DerivedData/APP-RANDOMHASH/Build/Products/CONFIG-iphonesimulator/APPNAME.app
    
    instruments -t "$TPL" "$APP" -e UIASCRIPT PATHTOYOUR/suite.js -e UIARESULTSPATH PATHTO/ARTIFACTS

