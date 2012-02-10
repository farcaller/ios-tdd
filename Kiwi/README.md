## Useful links

[Kiwi at GitHub](https://github.com/allending/Kiwi)

## Sample spec

```objc
#import "NCCategoryManager.h"
#import "NCCategory.h"

SPEC_BEGIN(NCCategoryManagerSpec)

describe(@"NCCategoryManager", ^{
	registerMatchers(@"NCM");
	
	__block IJLocalContext *localContext = nil;
	__block NCHTTPRequestManagerMock *requestManager = nil;
	__block NCCategoryManager *manager = nil;
	
	__block NSDictionary *json = nil;
	
	beforeAll(^{
		localContext = [[IJLocalContext alloc] init];
		
		// register our tested class
		[localContext registerClass:[NCCategoryManager class] instantiationMode:IJContextInstantiationModeSingleton];
		
		// register other non-mocked stuff
		[localContext registerClass:[NCCategory class] instantiationMode:IJContextInstantiationModeFactory];
		
		// registed the network mock
		requestManager = [[NCHTTPRequestManagerMock alloc] initWithName:@"Mock-of-NCCategoryManager"];
		[localContext registerSingletonInstance:requestManager forClass:[NCHTTPRequestManager class]];
		
		// test data
		json = $mdict(
			@"categories", $array(
				$mdict(@"id", $object(1245),
					 @"name", @"A category",
					 @"description", @"Sample description",
					 @"parent_id", [NSNull null]),
				$mdict(@"id", $object(1352),
					 @"name", @"A subcategry",
					 @"description", @"",
					 @"parent_id", $object(1245)),
				$mdict(@"id", $object(1221),
					 @"name", @"Subcategry 2",
					 @"description", @"",
					 @"parent_id", $object(1245))));
	});
	
	beforeEach(^{
		SPIN_MAIN_LOOP; // clean inter-spec notifications
		manager = [localContext instantiateClass:[NCCategoryManager class] withProperties:nil];
	});
	
	afterEach(^{
		[requestManager clean];
	});
	
    it(@"should be a sigleton", ^{
		NCCategoryManager *otherManager = [localContext instantiateClass:[NCCategoryManager class] withProperties:nil];
		[[manager should] beIdenticalTo:otherManager];
    });
	
	it(@"should fetch /categories when asked to update entities", ^{
		[requestManager mockRequestForMethod:@"GET" endpoint:@"categories" with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			callback(nil, nil, [NSError errorWithDomain:@"" code:0 userInfo:nil]);
		}];
		[manager synchronize];
		
		[[requestManager should] haveProcessedRequestWithMethod:@"GET" endpoint:@"categories"];
	});
	
	it(@"should build a correct category tree for correct JSON", ^{
		[requestManager mockRequestForMethod:@"GET" endpoint:@"categories" with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			callback([NSJSONSerialization dataWithJSONObject:json options:0 error:nil], nil, nil);
		}];
		[manager synchronize];
		
		NCCategory *cat = [manager rootCategoryNamed:@"A category"];
		[cat shouldNotBeNil];
		[[cat.name should] equal:@"A category"];
	});
	
	it(@"should enqueue image fetch requests for all non-root categories in JSON", ^{
		__block int counter = 0;
		
		[requestManager mockRequestForMethod:@"GET" endpoint:@"categories" with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			callback([NSJSONSerialization dataWithJSONObject:json options:0 error:nil], nil, nil);
		}];
		
		[requestManager mockRequestForMethod:@"GET" endpoint:nil with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			if([e hasPrefix:@"categories/"] && [e hasSuffix:@"/image"]) {
				++counter;
			}
			callback(nil, nil, [NSError errorWithDomain:@"" code:0 userInfo:nil]);
		}];
		[manager synchronize];
		
		[[theValue(counter) should] equal:theValue(2)];
	});
	
	it(@"should post a NCCategoryManagerSyncDoneNotification notification, when the sync is done successfully", ^{
		[requestManager mockRequestForMethod:@"GET" endpoint:@"categories" with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			callback([NSJSONSerialization dataWithJSONObject:json options:0 error:nil], nil, nil);
		}];
		
		[requestManager mockRequestForMethod:@"GET" endpoint:nil with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			if([e hasPrefix:@"categories/"] && [e hasSuffix:@"/image"]) {
				callback([NSData data], nil, nil);
			} else {
				abort(); // how did I get there?
			}
		}];
		
		NCNotificationWatcher *watcherOk = [NCNotificationWatcher watcherForNotificationName:NCCategoryManagerSyncDoneNotification object:manager];
		NCNotificationWatcher *watcherFail = [NCNotificationWatcher watcherForNotificationName:NCBasicJSONManagerSyncFailedNotification object:manager];
		[manager synchronize];
		
		[watcherOk.notification shouldNotBeNil];
		[watcherFail.notification shouldBeNil];
	});
	
	it(@"should post a NCBasicJSONManagerSyncFailedNotification notification, if images failed to fetch", ^{
		[requestManager mockRequestForMethod:@"GET" endpoint:@"categories" with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			callback([NSJSONSerialization dataWithJSONObject:json options:0 error:nil], nil, nil);
		}];
		
		[requestManager mockRequestForMethod:@"GET" endpoint:nil with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			if([e hasPrefix:@"categories/"] && [e hasSuffix:@"/image"]) {
				callback(nil, nil, [NSError errorWithDomain:@"" code:0 userInfo:nil]);
			} else {
				abort(); // how did I get there?
			}
		}];
		
		NCNotificationWatcher *watcherOk = [NCNotificationWatcher watcherForNotificationName:NCCategoryManagerSyncDoneNotification object:manager];
		NCNotificationWatcher *watcherFail = [NCNotificationWatcher watcherForNotificationName:NCBasicJSONManagerSyncFailedNotification object:manager];
		[manager synchronize];
		
		[watcherOk.notification shouldBeNil];
		[watcherFail.notification shouldNotBeNil];
	});
	
	it(@"should post a NCCategoryManagerSyncDoneNotification notification even if there are no images to fetch", ^{
		[requestManager mockRequestForMethod:@"GET" endpoint:@"categories" with:^(NSString *m, NSString *e, NCHTTPResponseBlock callback) {
			NSDictionary *json = $mdict(@"categories", $array($mdict(@"id", $object(1245),
																	 @"name", @"A category",
																	 @"description", @"Sample description",
																	 @"parent_id", [NSNull null])));
			callback([NSJSONSerialization dataWithJSONObject:json options:0 error:nil], nil, nil);
		}];
		
		NCNotificationWatcher *watcherOk = [NCNotificationWatcher watcherForNotificationName:NCCategoryManagerSyncDoneNotification object:manager];
		NCNotificationWatcher *watcherFail = [NCNotificationWatcher watcherForNotificationName:NCBasicJSONManagerSyncFailedNotification object:manager];
		[manager synchronize];
		
		[watcherOk.notification shouldNotBeNil];
		[watcherFail.notification shouldBeNil];
	});
	
	afterAll(^{
		localContext = nil;
		requestManager = nil;
		manager = nil;
	});
});

SPEC_END
```