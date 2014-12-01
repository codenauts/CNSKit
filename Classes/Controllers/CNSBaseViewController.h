#ifndef CNS_APPLICATION_DELEGATE_CLASS
#warning You should define CNS_APPLICATION_DELEGATE_CLASS in your project!
#define CNS_APPLICATION_DELEGATE_CLASS NSObject
#endif

@class CNS_APPLICATION_DELEGATE_CLASS;

@interface CNSBaseViewController : UIViewController {
}

+ (CNS_APPLICATION_DELEGATE_CLASS *)applicationDelegate;

- (void)releaseView;

@end
