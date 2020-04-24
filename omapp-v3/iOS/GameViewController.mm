#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>

#include "application/platform.hpp"
#include "base/memory.hpp"
#import "iAd/ADBannerView.h"

#include "Stats.hpp"

#include "appdefinition.hpp"
#include "AdManager.hpp"
#include "TrackingManager.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_TEXTURE0,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD0,
    NUM_ATTRIBUTES
};

@interface GameViewController () < ADBannerViewDelegate > {
}

@property GKLocalPlayer *localPlayer;

- (void)showAuthenticationDialogWhenReasonable:(UIViewController*)viewController;


@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL isAdViewVisible;
@property (nonatomic) BOOL isAppDone;

@property (nonatomic) UITextField*    statusTextField;
@property (nonatomic) UITextField*    inputTextField;

- (void)setupGL;
- (void)tearDownGL;
- (void)updateSize;

@end

@implementation GameViewController

@synthesize adBannerView = _adBannerView;
@synthesize isAdViewVisible;
@synthesize isAppDone;

@synthesize statusTextField;
@synthesize inputTextField;

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

	if( self.context ) {
		OM::g_app.setGLESVersion( 3 );
	} else {
        NSLog(@"Failed to create ES 3.0 context");
		self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if( self.context ){
			OM::g_app.setGLESVersion( 2 );
		}
	}

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
	[self updateSize];

    OM::g_app.initialize( 0, nullptr );
	self.isAppDone = false;
	self.preferredFramesPerSecond = 60;
//	self.preferredFramesPerSecond = 30;
	
	self.isAdViewVisible = false;
//	[self createAdBannerView];
	
	
//	[self authenticateLocalPlayer];

    [self createUiTestControls];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString* text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"INPUT text entered: >%@<", text);
    
    const char* pInput = [text UTF8String];
    OM::g_platform.queueInput( pInput );
    
    textField.text = @"";
    [textField endEditing:YES];
    return YES;
}

- (void)dealloc
{
	if( OM::g_pAdManager != nullptr )
	{
		OM::g_pAdManager->shutdown();
		delete OM::g_pAdManager;
		OM::g_pAdManager = nullptr;
	}
	if( OM::g_pTrackingManager != nullptr )
	{
		OM::g_pTrackingManager->shutdown();
		delete OM::g_pTrackingManager;
		OM::g_pTrackingManager = nullptr;
	}
    OM::g_app.shutdown();
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    float scale = self.view.layer.contentsScale;
    UITouch *touch = [ touches anyObject ];
    CGPoint location = [ touch locationInView:self.view ];
	
	float w2 = self.view.bounds.size.width * 0.5f;
	float h = self.view.bounds.size.height;
	float h2 = h * 0.5f;

//    NSLog( @"Touch %f, %f  * %f", location.x, location.y, scale );
    OM::g_app.setTouched( true, ( location.x - w2 )*scale, ( ( h-location.y ) - h2 )*scale );
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    float scale = self.view.layer.contentsScale;
    UITouch *touch = [ touches anyObject ];
    CGPoint location = [ touch locationInView:self.view ];

	float w2 = self.view.bounds.size.width * 0.5f;
	float h2 = self.view.bounds.size.height * 0.5f;
	
//    NSLog( @"End Touch %f, %f  * %f", location.x, location.y, scale );
    OM::g_app.setTouched( false, location.x*scale - w2, location.y*scale - h2 );
}

#pragma mark - GLKView and GLKViewController delegate methods
- (void)updateSize
{
//	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	//    NSLog( @"%lf x %lf", self.view.bounds.size.width, self.view.bounds.size.height );
	
	float scale = self.view.layer.contentsScale;
	
	float w2 = self.view.bounds.size.width * 0.5f;
	float h2 = self.view.bounds.size.height * 0.5f;
//	/*
	 w2 *= scale;
	 h2 *= scale;
//	 */
	OM::g_app.setSize( w2*2, h2*2, scale );

}
- (void)update
{
	[self updateSize];
	
	if( OM::g_pStats != nullptr )
	{
		OM::g_pStats->set( "prefered FPS", self.preferredFramesPerSecond );
		OM::g_pStats->set( "agreed FPS", self.framesPerSecond );
	}
	if( OM::g_pAdManager != nullptr )
	{
		OM::g_pAdManager->update( self.timeSinceLastUpdate );
		if( OM::g_pAdManager->shouldShowBanner() && !OM::g_pAdManager->isBannerVisible() )
		{
			[self createAdBannerView];
			OM::g_pAdManager->setBannerVisible( true ); // cheating, it's not yet visible, but we are wroking on it
		}
	}
	if( !isAppDone )
	{
		self.isAppDone = OM::g_app.update( self.timeSinceLastUpdate );
	
        if( OM::g_app.isUiTestRunning() )
        {
            const char* pStatus = OM::g_app.getAppStatus();
            NSString* status = [NSString stringWithFormat:@"%s", pStatus];
            [self.statusTextField setText:status];
        }
        else
        {
            [self destroyUiTestControls];
        }
		if( isAppDone )
		{
			OM::g_app.shutdown();
			OM::g_defaultMemory.dumpInfo();
		}
	}
}
- (void)createUiTestControls
{
    const float yPos = 0.0f;
    {
        self.statusTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, yPos, 300, 50)];
        [self.statusTextField setAccessibilityIdentifier:@"STATUS"];
        //        [textField setHidden:true];
        [self.statusTextField setText:@"initializing"];
        [self.view addSubview:self.statusTextField];
    }
    {
        self.inputTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, yPos+20, 300, 50)];
        [self.inputTextField setAccessibilityIdentifier:@"INPUT"];
        //        [textField setHidden:true];
        [self.inputTextField setText:@""];
        //        [textField setStringValue:@"My Label"];
        //        [textField setBezeled:NO];
        //        [textField setDrawsBackground:NO];
        //        [textField setEditable:NO];
        //        [textField setSelectable:NO];
        [self.inputTextField setDelegate:self];
        [self.view addSubview:self.inputTextField];
    }
#if defined(OM_DEBUG)
#else
    // hidden breaks the tests :(
//    self.statusTextField.hidden = true;
//    self.inputTextField.hidden = true;
    // making it (almost!) invisible works, but doesn't hide it
//    self.statusTextField.alpha = 0.1;
//    self.inputTextField.alpha = 0.1;
    // making the text invisble hides it, and works
    UIColor *color = [UIColor colorWithWhite:1.0f alpha:0.0f];
    self.statusTextField.textColor = color;
    self.inputTextField.textColor = color;
#endif
}
- (void)destroyUiTestControls
{
    if( self.statusTextField != nil )
    {
        [self.statusTextField removeFromSuperview];
        self.statusTextField = nil;
    }
    if( self.inputTextField != nil )
    {
        [self.inputTextField removeFromSuperview];
        self.inputTextField = nil;
    }
}
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
// 197e8e
// 25 126 142
//    glClearColor(0.15f, 0.15f, 0.65f, 1.0f);
	glClearColor( 25.0f/255.0f, 126.0f/255.0f, 142.0f/255.0f, 1.0f);
	glClearDepthf( 1.0f );
	glDepthFunc( GL_LESS );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	if( ! isAppDone )
	{
		OM::g_app.render();
	}
}

# pragma mark - GameKit

- (void)showAuthenticationDialogWhenReasonable:(UIViewController*)viewController
{
	// :TODO: might want to delay this ;)
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)authenticatedPlayer:(GKLocalPlayer*)localPlayer
{
	NSLog( @"authenticatedPlayer %@", localPlayer.displayName );
}

- (void)disableGameCenter
{
	NSLog( @"disableGameCenter" );
	self.localPlayer = nil;
}

- (void) authenticateLocalPlayer
{
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	self.localPlayer = localPlayer;
	
	localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
		
		if (viewController != nil)
		{
			//showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
			[self showAuthenticationDialogWhenReasonable: viewController];
		}
		else if (self.localPlayer.isAuthenticated)
		{
			//authenticatedPlayer: is an example method name. Create your own method that is called after the loacal player is authenticated.
			[self authenticatedPlayer: self.localPlayer];
		}
		else
		{
			[self disableGameCenter];
		}
	};
}

# pragma mark - iADs

- (void)createAdBannerView
{
	Class classAdBannerView = NSClassFromString( @"ADBannerView" );
	if( classAdBannerView != nil )
	{
		isAdViewVisible = true;
		self.adBannerView = [[classAdBannerView alloc] initWithFrame:CGRectZero];
	
		ADBannerView* abv = self.adBannerView;
	
		CGRect screen = self.view.bounds;
		CGRect banner = [_adBannerView frame];
	
		CGRect frame = CGRectOffset([_adBannerView frame], 0.5f*screen.size.width - 0.5f*banner.size.width, screen.size.height-banner.size.height);
		CGRect offFrame = frame;
		offFrame.origin.y += 100;
	
		if( screen.size.width < screen.size.height )
		{
			frame.origin.x = 0.5f*( screen.size.height - banner.size.width);
			frame.origin.y = screen.size.width - banner.size.height;
		
			offFrame.origin =frame.origin;
			offFrame.origin.y += 100;
		}
		[_adBannerView setFrame:offFrame];
	
		[UIView animateWithDuration:1.5
			 animations:^{
                [self->_adBannerView setFrame:frame];
			 }
			 completion:^(BOOL finished){
				 NSLog( @"addFadeInAnimationDidStop %@", finished?@"finished":@"unfinished" );
//				 [self destroyAdBannerView];
		 }];
	
		[abv setDelegate:self];
 
		[self.view addSubview:_adBannerView];
	
		if( OM::g_pAdManager != nullptr )
		{
			OM::g_pAdManager->setBannerVisible( true );
		}
	}
	else
	{
		if( OM::g_pAdManager != nullptr )
		{
			OM::g_pAdManager->bannerFailed();
		}

	}
}

- (void)destroyAdBannerView
{
	if( self.adBannerView != nil && isAdViewVisible )
	{
		isAdViewVisible = false;
		ADBannerView* abv = self.adBannerView;
		abv = self.adBannerView;
		CGRect frame = [abv frame];
	
		frame.origin.y = 1500.0f;

		[UIView animateWithDuration:1.5
			 animations:^{
				 [_adBannerView setFrame:frame];
			 }
			 completion:^(BOOL finished){
				 NSLog( @"adFadeOutAnimationDidStop %@", finished?@"finished":@"unfinished" );
				 [_adBannerView removeFromSuperview];
				 self.adBannerView = nil;
				 if( OM::g_pAdManager != nullptr )
				 {
					 OM::g_pAdManager->setBannerVisible( false );
				 }
		 }];
	}
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if( isAdViewVisible )
	{
		if( OM::g_pAdManager != nullptr )
		{
			OM::g_pAdManager->setBannerVisible( false );
			OM::g_pAdManager->bannerFailed();
		}
		[self destroyAdBannerView];
	}
}
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	NSLog( @"bannerViewActionShouldBegin %@", willLeave?@"leaving":@"staying" );
	OM::g_app.setAdActive( true );
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	NSLog( @"bannerViewActionDidFinish" );
	OM::g_app.setAdActive( false );
}

@end
