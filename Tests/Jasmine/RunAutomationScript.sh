
TPL=/Developer/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate
APP=/Users/USERNAME/Library/Developer/Xcode/DerivedData/APP-RANDOMHASH/Build/Products/CONFIG-iphonesimulator/APPNAME.app
    
instruments -t "$TPL" "$APP" -e UIASCRIPT PATHTOYOUR/suite.js -e UIARESULTSPATH PATHTO/ARTIFACTS
