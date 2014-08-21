#import "Curtain.h"

@protocol NavBarDelegate <NSObject>
@optional
-(void) pageTurnBack:(NSInteger)page;
-(void) pageTurnForward:(NSInteger)page;
@end


@interface NavBar : Curtain

@property id <NavBarDelegate> delegate;

@property UILabel *titleLabel;
@property UIButton *forwardButton;
@property UIButton *backButton;

@property (nonatomic) NSArray *titles;
@property (nonatomic) NSInteger numPages;

+(instancetype) navBar;

@end