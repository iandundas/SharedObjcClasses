#import "IDTableViewKeyboardController.h"

@interface IDTableViewKeyboardController ()
@property (nonatomic, weak, readwrite) UITableView *tableView;
@end


@implementation IDTableViewKeyboardController  {
    CGPoint _previousOffset;
    BOOL _didCallEndEditingFlag; // prevents [self.view endEditing:YES]; being spammed
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithTableView:(UITableView*)tableView{
    if (self = [super init]) {
        _tableView= tableView;

        _previousOffset= CGPointZero;
        _didCallEndEditingFlag= NO;
    }
    return self;
}


- (void)setEnabled:(BOOL)enable {
    if (_enabled != enable){
        if (enable){
            // setup observations
            [[NSNotificationCenter defaultCenter]
                addObserver:self selector:@selector(keyboardWillShow:)
                name:UIKeyboardWillShowNotification object:nil];

            [[NSNotificationCenter defaultCenter]
                addObserver:self selector:@selector(keyboardWillBeHidden:)
                name:UIKeyboardWillHideNotification object:nil];
        }
        else {
            // disable observations
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
    _enabled= enable;
}


#pragma mark - Keyboard animations:
// based on http://spin.atomicobject.com/2014/01/08/animate-around-ios-keyboard/

- (void)keyboardWillShow:(NSNotification*)notification {
    [self animateKeyboardWithUserInfo:[notification userInfo] directionUp:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    [self animateKeyboardWithUserInfo:[notification userInfo] directionUp:NO];
}

-(void)animateKeyboardWithUserInfo:(NSDictionary*)userInfo directionUp:(BOOL)up{

    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];

    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardFrame = [self.tableView.superview convertRect:keyboardFrame fromView:nil];

    [UIView
        animateWithDuration:duration delay:0 options:animationCurve << 16
                 animations:^{
                     [self.tableView setContentInset:UIEdgeInsetsMake (0, 0, up?keyboardFrame.size.height:0, 0)];
                 } completion:nil
    ];
}

#pragma mark - UIScrollViewDelegate proxies
#pragma mark - Track for scrolls downwards, dismisses keyboard
/*  Classes using IDTableViewKeyboardController should
    implement UIScrollViewDelegate, and pass calls to the the
    following three methods to IDTableViewKeyboardController  */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _previousOffset= scrollView.contentOffset;
}

// When scrollView is scrolled downwards, dismiss keyboard if it's shown:
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < _previousOffset.y){
        @synchronized (self) {
            if (!_didCallEndEditingFlag) { // prevents [self.view endEditing:YES]; being called repeatedly
                _didCallEndEditingFlag = YES;
                [scrollView.superview endEditing:YES];
            }
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _didCallEndEditingFlag= NO;
}
@end