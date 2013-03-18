
#import "EJBindingEventedBase.h"

#pragma mark - EJKeyInputDelegate

@class EJKeyInputResponder;
@protocol EJKeyInputDelegate <NSObject>
- (UIResponder*)nextResponderForKeyInput:(EJKeyInputResponder*)keyInput;
@optional
- (void)keyInput:(EJKeyInputResponder*)keyInput insertText:(NSString*)text;
- (void)keyInputDidDeleteBackwards:(EJKeyInputResponder*)keyInput;
- (void)keyInputDidResignFirstResponderStatus:(EJKeyInputResponder*)keyInput;
- (void)keyInputDidBecomeFirstResponder:(EJKeyInputResponder*)keyInput;
@end

extern NSString * const EJBindingKeyInputDidBecomeFirstResponder;
extern NSString * const EJBindingKeyInputDidResignFirstResponder;

@interface EJKeyInputResponder : UIResponder <UIKeyInput>{
    
@private
    UIView *ej_inputView;
    UIView *ej_inputAccessoryView;
}
@property (nonatomic, unsafe_unretained) NSObject <EJKeyInputDelegate>*delegate;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UIView *inputAccessoryView;
@end

#pragma mark -
#pragma mark EJBindingKeyInput

@interface EJBindingKeyInput : EJBindingEventedBase <EJKeyInputDelegate>

@property (nonatomic, retain, readonly) EJKeyInputResponder *inputResponder;

@end