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
