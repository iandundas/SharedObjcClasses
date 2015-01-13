#import <Foundation/Foundation.h>

/**
*   Class which handles two tasks:
*       - When keyboard appears, adds a bottom contentInset
*       equivalent to the keyboard size (which is the correct way to adjust
*       a tableView when a keyboard is shown)
*       - hides the keyboard if the user pulls down on the tableView (i.e. scrolls up)
*
*   See MSChangePasswordViewController for example usage, but you basically must do the following:
*       - pass the tableView to initWithTableView
*       - set enabled=YES on viewDidAppear, send enabled=NO on viewWillDisappear
*       - pass calls to scrollViewDidScroll:, scrollViewWillBeginDragging:
*       and scrollViewDidEndDragging:willDecelerate from the UIScrollViewDelegate to this class
*
*/

@interface IDTableViewKeyboardController : NSObject
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic) BOOL enabled;
- (instancetype)initWithTableView:(UITableView *)tableView;

// Based on UIScrollViewDelegate:
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end