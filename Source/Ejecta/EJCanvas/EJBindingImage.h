#import "EJBindingEventedBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"

@interface EJBindingImage : EJBindingEventedBase <EJDrawable> {
	EJTexture * texture;
	NSString * path;
	BOOL loading;
}

@property (strong, nonatomic) EJTexture * texture;

@end
