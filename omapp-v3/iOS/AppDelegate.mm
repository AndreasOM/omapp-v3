
#import "AppDelegate.h"

#include "appdefinition.hpp"

// :TODO: wrap

//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
//#import <Fabric/Fabric.h>
//#import <Answers/Answers.h>

// :TODO: extract into platform callbacks
#include "ads/AdManager.hpp"
//#include "ios/ads/AdModuleChartboostIos.h"
#include "TrackingManager.h"
//#include "TrackingModuleFlurryIos.h"

#include "backend/BackendModule.hpp"
#ifdef OM_TRACKING_PLAYFAB
#	include "ios/backend/BackendModulePlayFabIos.hpp"
#endif
#include "ios/tracking/trackingmoduleawspinpoint_ios.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // :TODO: remove
    
//    [Fabric with:@[[Crashlytics class]]];
//    [Fabric with:@[[Answers class]]];

//    self.window.frame = [UIScreen mainScreen].bounds;

	OM::g_pAdManager = new OM::AdManager;
	OM::g_pAdManager->initialize();
//	OM::AdModuleChartboostIos* pChartboost = new OM::AdModuleChartboostIos;
//	pChartboost->initialize();
//	OM::g_pAdManager->registerAdModule( pChartboost );	// :TODO: :RELEASE: reenable ads

	OM::g_pTrackingManager = new OM::TrackingManager;
	OM::g_pTrackingManager->initialize();
//	OM::TrackingModuleFlurryIos* pFlurry = new OM::TrackingModuleFlurryIos;
//	pFlurry->initialize();
//	OM::g_pTrackingManager->registerTrackingModule( pFlurry );

	/* :TODO:
	OM::TrackingModuleAwsPinpoint_ios* pPinpoint = new OM::TrackingModuleAwsPinpoint_ios();
	pPinpoint->initialize();
	pPinpoint->applicationDidFinishLaunchingWithOptions( application, launchOptions );
	OM::g_pTrackingManager->registerTrackingModule( pPinpoint );
	*/

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		OM::g_pTrackingManager->logEvent( "start" );
	});

#ifdef OM_TRACKING_PLAYFAB
	OM::BackendModulePlayFabIos* pPlayFab = new OM::BackendModulePlayFabIos();
	pPlayFab->initialize();
	pPlayFab->login();		// :TODO: move
	
	OM::g_pTrackingManager->registerTrackingModule( pPlayFab );
	
	OM::g_pDefaultBackendModule = pPlayFab;
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (bool)isFullyInitialized {
    return OM::g_app.isFullyInitialized();
}

@end
