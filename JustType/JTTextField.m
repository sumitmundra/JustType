//
//  JTTextField.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>
#import "JTTextField.h"
#import "NSString+JTExtension.h"

UIKIT_STATIC_INLINE void mySelectionDidChange(id self, SEL _cmd, id<UITextInput> textInput);

@interface JTTextField ()

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *pressGesture;

@end


@implementation JTTextField
@synthesize textController = _textController;
@synthesize tapGesture = _tapGesture;
@synthesize pressGesture = _pressGesture;

#pragma mark - Object lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        
        _textController = [[JTTextController alloc] init];
        _textController.delegate = self;
        
        [self addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(didSingleTap:)];
        tapGesture.cancelsTouchesInView = YES;
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        self.tapGesture = tapGesture;
        
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] init];
        [pressGesture addTarget:self action:@selector(didSingleTap:)];
        pressGesture.cancelsTouchesInView = YES;
        pressGesture.delegate = self;
        [self addGestureRecognizer:pressGesture];
        self.pressGesture = pressGesture;

    }
    return self;
}

- (void)dealloc {
    [self.tapGesture.view removeGestureRecognizer:self.tapGesture];
    [self.pressGesture.view removeGestureRecognizer:self.pressGesture];
    
    [self removeTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    _textController.delegate = nil;
    _textController = nil;
}

#pragma mark - text controller delegate actions
- (NSString *)textContent {
    return self.text;
}

- (void)replaceHighlightingWithRange:(NSRange)newRange {
#ifdef __IPHONE_6_0
    // these checks are for compatibility reasons with older iOS versions
    if ([self respondsToSelector:@selector(setAttributedText:)]) {
        UITextRange *selectedTextRange = self.selectedTextRange;
        
        NSMutableAttributedString *highlightedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [highlightedString removeAttribute:NSForegroundColorAttributeName range:self.text.range];
        [highlightedString addAttribute: NSForegroundColorAttributeName value:[UIColor grayColor] range:newRange];
        [self setAttributedText:highlightedString];
        
        self.selectedTextRange = selectedTextRange;
    }
#endif
}

#pragma mark - editing actions
- (void)didChangeText:(id)sender {
    [self.textController didChangeText];
}

#pragma mark - Gesture recognizer actions
- (void)didSingleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textController didChangeSelection];
        });
    }
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
