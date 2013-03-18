
#import "EJBindingKeyInput.h"
#import "EJJavaScriptView.h"

NSString * const EJBindingKeyInputDidBecomeFirstResponder = @"EJBindingKeyInputDidBecomeFirstResponder";
NSString * const EJBindingKeyInputDidResignFirstResponder = @"EJBindingKeyInputDidResignFirstResponder";

@implementation EJKeyInputResponder
@synthesize inputView = ej_inputView;
@synthesize inputAccessoryView = ej_inputAccessoryView;

- (void)dealloc{
    [ej_inputView release];
    [ej_inputAccessoryView release];
    [super dealloc];
}

- (UIView *)inputView{
    if (ej_inputView) {
        return ej_inputView;
    }
    return [super inputView];
}

- (UIView *)inputAccessoryView{
    if (ej_inputAccessoryView) {
        return ej_inputAccessoryView;
    }
    return [super inputAccessoryView];
}

- (UIResponder*)nextResponder{
    return [self.delegate nextResponderForKeyInput:self];
}

- (BOOL)becomeFirstResponder{
    BOOL isCurrent = [self isFirstResponder];
    BOOL become = [super becomeFirstResponder];
    if (become && !isCurrent && [self.delegate respondsToSelector:@selector(keyInputDidBecomeFirstResponder:)]) {
        [self.delegate keyInputDidBecomeFirstResponder:self];
    }
    return become;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)resignFirstResponder{
    BOOL isCurrent = [self isFirstResponder];
    BOOL resign = [super resignFirstResponder];
    if (resign && isCurrent && [self.delegate respondsToSelector:@selector(keyInputDidResignFirstResponderStatus:)]) {
        [self.delegate keyInputDidResignFirstResponderStatus:self];
    }
    return resign;
}

- (void)deleteBackward{
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyInputDidDeleteBackwards:)]) {
        [self.delegate keyInputDidDeleteBackwards:self];
    }
}

- (void)insertText:(NSString *)text{
    if ([self.delegate respondsToSelector:@selector(keyInput:insertText:)]) {
        [self.delegate keyInput:self insertText:text];
    }
}

- (BOOL)hasText{
    return YES;
}

@end

@interface EJBindingKeyInput ()
@property (nonatomic, retain) NSMutableString *value;
@property (nonatomic, retain, readwrite) EJKeyInputResponder *inputResponder;
@end

@implementation EJBindingKeyInput

static EJBindingKeyInput *_activeKeyInput;

+ (EJBindingKeyInput *)activeKeyInput
{
    return _activeKeyInput;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
    self.inputResponder = [[[EJKeyInputResponder alloc] init] autorelease];
    self.inputResponder.delegate = self;
    self.value = [NSMutableString string];
    
    if (!_activeKeyInput) {
        _activeKeyInput = self;
    }
}

- (void)dealloc
{
    self.inputResponder.delegate = nil;
    self.inputResponder = nil;
    [super dealloc];
}

EJ_BIND_FUNCTION(focus, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputResponder becomeFirstResponder]);
}

EJ_BIND_FUNCTION(blur, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputResponder resignFirstResponder]);
}

EJ_BIND_FUNCTION(isOpen, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputResponder isFirstResponder]);
}

EJ_BIND_GET(value, ctx){
    return NSStringToJSValue(ctx, self.value);
}

EJ_BIND_SET(value, ctx, value){
    [self.value setString:JSValueToNSString(ctx, value)];
}

EJ_BIND_EVENT(focus);
EJ_BIND_EVENT(blur);
EJ_BIND_EVENT(delete);
EJ_BIND_EVENT(change);

#pragma mark -
#pragma mark EJKeyInput delegate

- (UIResponder*)nextResponderForKeyInput:(EJKeyInputResponder *)keyInput{
    return scriptView;
}

- (void)keyInput:(EJKeyInputResponder *)keyInput insertText:(NSString *)text
{
    [self.value appendString:text];

    JSValueRef params[] = { NSStringToJSValue(scriptView.jsGlobalContext, text) };
    [self triggerEvent:@"keypress" argc:1 argv:params];
    
    [self triggerEvent:@"change" argc:0 argv:NULL];
}

- (void)keyInputDidDeleteBackwards:(EJKeyInputResponder *)keyInput{
    [self triggerEvent:@"delete" argc:0 argv:NULL];
}

- (void)keyInputDidResignFirstResponderStatus:(EJKeyInputResponder *)keyInput{
    [self triggerEvent:@"blur" argc:0 argv:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:EJBindingKeyInputDidResignFirstResponder object:self userInfo:nil];
}

- (void)keyInputDidBecomeFirstResponder:(EJKeyInputResponder *)keyInput{
    [self triggerEvent:@"focus" argc:0 argv:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:EJBindingKeyInputDidBecomeFirstResponder object:self userInfo:nil];

}

@end
