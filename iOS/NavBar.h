#import "GLView.h"

@protocol NavBarDelegate <NSObject>
@required
-(void) pageTurnBack:(NSInteger)page;
-(void) pageTurnForward:(NSInteger)page;
@end


@interface NavBar : GLView

@property id <NavBarDelegate> delegate;

@property UILabel *titleLabel;
@property UIButton *forwardButton;
@property UIButton *backButton;

@property (nonatomic) NSArray *titles;
@property NSInteger page;
@property (nonatomic) NSInteger numPages;

-(void) forwardButtonPressed;
-(void) backButtonPressed;

+(instancetype) navBarTop;
+(instancetype) navBarBottom;

@end
