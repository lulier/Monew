#include "common.h"
#import "MuTextSelectView.h"
#import "MuWord.h"
#import "ShowTextViewController.h"
#import "DictionaryDatabase.h"
#import "CommonMethod.h"

@implementation MuTextSelectView
{
    NSArray *words;
    CGSize pageSize;
    UIColor *color;
    CGPoint start;
    CGPoint end;
}

- (id) initWithWords:(NSArray *)_words pageSize:(CGSize)_pageSize
{
    self = [super initWithFrame:CGRectMake(0,0,100,100)];
    if (self)
    {
        [self setOpaque:NO];
        words = [_words retain];
        pageSize = _pageSize;
        color = [[UIColor colorWithRed:0x25/255.0 green:0x72/255.0 blue:0xAC/255.0 alpha:0.5] retain];
        //		UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
        //		[self addGestureRecognizer:rec];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        gestureRecognizer.numberOfTapsRequired=1;
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];
        //		[rec release];
    }
    return self;
}

-(void) dealloc
{
    [words release];
    [color release];
    [super dealloc];
}

- (NSArray *) selectionRects
{
    NSMutableArray *arr = [NSMutableArray array];
    __block CGRect r;
    
    [MuWord selectFrom:start to:end fromWords:words
           onStartLine:^{
               r = CGRectNull;
           } onWord:^(MuWord *w) {
               r = CGRectUnion(r, w.rect);
           } onEndLine:^{
               if (!CGRectIsNull(r))
                   [arr addObject:[NSValue valueWithCGRect:r]];
           }];
    
    return arr;
}

- (NSString *) selectedText
{
    __block NSMutableString *text = [NSMutableString string];
    __block NSMutableString *line;
    
    [MuWord selectFrom:start to:end fromWords:words
           onStartLine:^{
               line = [NSMutableString string];
           } onWord:^(MuWord *w) {
               if (line.length > 0)
                   [line appendString:@" "];
               [line appendString:w.string];
           } onEndLine:^{
               if (text.length > 0)
                   [text appendString:@"\n"];
               [text appendString:line];
           }];
    
    return text;
}

-(void)viewTapped:(id)sender
{
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGPoint pos = [sender locationInView:self];
    pos.x /= scale.width;
    pos.y /= scale.height;
    start=pos;
    end=pos;
    
    [self setNeedsDisplay];
}

-(void) onDrag:(UIPanGestureRecognizer *)rec
{
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGPoint p = [rec locationInView:self];
    p.x /= scale.width;
    p.y /= scale.height;
    
    if (rec.state == UIGestureRecognizerStateBegan)
        start = p;
    
    end = p;
    
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGContextRef cref = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(cref, scale.width, scale.height);
    __block CGRect r;
    
    [color set];
    
    [MuWord selectFrom:start to:end fromWords:words
           onStartLine:^{
               r = CGRectNull;
           } onWord:^(MuWord *w) {
               r = CGRectUnion(r, w.rect);
               [self checkWord:w.string];
           } onEndLine:^{
               if (!CGRectIsNull(r))
                   NSLog(@"hdkfhd");
                   UIRectFill(r);
           }];
}
-(BOOL)isCharacter:(char)letter
{
    if ((letter-'a'>=0&&letter-'a'<26)||(letter-'A'>=0&&letter-'A'<26)||letter=='\'')
    {
        return YES;
    }
    return NO;
}
-(void)checkWord:(NSString*)word
{
    NSInteger first=0;
    NSInteger last=0;
    NSInteger len=[word length];
    NSString *extractWord = nil;
    while (first<len&&last<len)
    {
        while (first<len&&(![self isCharacter:[word characterAtIndex:first]]))
        {
            first++;
        }
        last=first+1;
        while (last<len&&[self isCharacter:[word characterAtIndex:last]])
        {
            last++;
        }
        if (last<=len) {
            extractWord=[word substringWithRange:NSMakeRange(first, last-first)];
            break;
        }
    }
    DictionaryDatabase *dictionary=[DictionaryDatabase sharedInstance];
    NSDictionary *where=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",extractWord],@"WORD",nil];
    [dictionary queryTable:@"DICTIONARY" withSelect:@[@"*"] andWhere:where completion:^(NSMutableArray *resultsArray) {
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            NSDictionary *dic=[resultsArray firstObject];
            NSMutableString *content=[NSMutableString stringWithString:[dic objectForKey:@"WORD"]];
            [content appendString:[dic objectForKey:@"CHINESEEXPLAIN"]];
            [content appendString:[dic objectForKey:@"ENGLISHEXPLAIN"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self cancelSelect];
            });
            [self cancelSelect];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ShowTextViewController *showView=[storyboard instantiateViewControllerWithIdentifier:@"ShowTextViewController"];
                showView.word=[dic objectForKey:@"WORD"];
                showView.chineseExplanation=[dic objectForKey:@"CHINESEEXPLAIN"];
                showView.englishExplanation=[dic objectForKey:@"ENGLISHEXPLAIN"];
                UIViewController *currentVC=[CommonMethod getCurrentVC];
                [currentVC presentViewController:showView animated:YES completion:nil];
            });
            
        }
    }];
}
-(void)cancelSelect
{
    start=CGPointMake(0, 0);
    end=start;
    [self setNeedsDisplay];
}
@end
