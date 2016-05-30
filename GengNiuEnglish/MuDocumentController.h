#import <UIKit/UIKit.h>

#undef ABS
#undef MIN
#undef MAX

#include "mupdf/fitz.h"

#import "MuOutlineController.h"
#import "MuDocRef.h"
#import "MuDialogCreator.h"
#import "MuUpdater.h"
#import "MuPageViewReflow.h"
#import "MuPageViewNormal.h"
#import "GNDownloadDatabase.h"
#import "CommonMethod.h"
#import "STKAudioPlayer.h"
#import "SampleQueueId.h"
#import <AVFoundation/AVFoundation.h>

enum
{
    BARMODE_MAIN,
    BARMODE_SEARCH,
    BARMODE_MORE,
    BARMODE_ANNOTATION,
    BARMODE_HIGHLIGHT,
    BARMODE_UNDERLINE,
    BARMODE_STRIKE,
    BARMODE_INK,
    BARMODE_DELETE
};
@protocol MuDocumentControllerDelegate <NSObject>

-(void)muPDFGoBack;

@end

@interface MuDocumentController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, MuDialogCreator, MuUpdater,MuPageViewNormalDelegate,STKAudioPlayerDelegate>

@property(nonatomic,unsafe_unretained)id<MuDocumentControllerDelegate>delegate;
@property(nonatomic,retain)NSString* textName;
@property(nonatomic,retain)NSString* textID;
@property(nonatomic)BOOL autoPlay;
- (id) initWithFilename: (NSString*)nsfilename path:(char *)cstr document:(MuDocRef *)aDoc;
- (void) createPageView: (int)number;
- (void) gotoPage: (int)number animated: (BOOL)animated;
- (void) onShowOutline: (id)sender;
- (void) onShowSearch: (id)sender;
- (void) onCancel: (id)sender;
- (void) resetSearch;
- (void) showSearchResults: (int)count forPage: (int)number;
- (void) onSlide: (id)sender;
- (void) onTap: (UITapGestureRecognizer*)sender;
- (void) showNavigationBar;
- (void) hideNavigationBar;

@end
