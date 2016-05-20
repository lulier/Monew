#include "common.h"


@protocol MuTextSelectViewDelegate <NSObject>

-(void)didSelectWord:(NSString*)word;

@end


@interface MuTextSelectView : UIView
@property(nonatomic,unsafe_unretained)id<MuTextSelectViewDelegate>delegate;
- (id) initWithWords:(NSArray *)_words pageSize:(CGSize)_pageSize;
- (NSArray *) selectionRects;
- (NSString *) selectedText;
@end
