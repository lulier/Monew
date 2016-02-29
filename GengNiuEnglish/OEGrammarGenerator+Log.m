//
//  OEGrammarGenerator+Log.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/2/29.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "OEGrammarGenerator+Log.h"

@implementation OEGrammarGenerator (Log)

- (NSMutableString *) deriveRuleString:(NSString *)workingString withRuleType:(NSString *)ruleType addingWordsToMutableArray:(NSMutableArray *)phoneticDictionaryArray
{
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    for(int i = 0; i < 3; i++) {
        workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"</string><string>" withString:@"###SEPARATORTOKEN###"];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<key>%@</key><array><string>",ruleType] withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<key>PublicRule%@</key><array><string>",ruleType] withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"</string></array>" withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"</dict>" withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"<dict>" withString:@""];
    if([workingString rangeOfString:@"<key>Weight</key><real>"].location != NSNotFound) {
        workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"<key>Weight</key><real>" withString:@"###OVERALLRULEWEIGHTSTARTTOKEN###"];
        workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"</real>" withString:@"###OVERALLRULEWEIGHTENDTOKEN###"];
    }
    
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<key>%@</key><array>",ruleType] withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<key>PublicRule%@</key><array>",ruleType] withString:@""];
    workingString = (NSMutableString *)[workingString stringByReplacingOccurrencesOfString:@"</array>" withString:@""];
    
    NSArray *tempArray = [[[[workingString stringByReplacingOccurrencesOfString:@"###SEPARATORTOKEN###" withString:@" "]stringByReplacingOccurrencesOfString:@"###RULENAMEEND###" withString:@"> "]stringByReplacingOccurrencesOfString:@"###RULENAMEBEGIN###" withString:@"<"] componentsSeparatedByString:@" "];
    
    for(NSString *word in tempArray) {
        
        NSError *error = nil; // regex to check if this is a rule
        NSUInteger matchCount = NSNotFound;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<rule_[0-9]+>" options:0 error:&error];
        if (regex && !error){
            matchCount = [regex numberOfMatchesInString:word options:0 range:NSMakeRange(0, word.length)];
        }
        if(matchCount == 0 && ([word length] > 0) && ![word isEqualToString:@" "]) { //  we only add it if it isn't a rule and has something useful in it.
            [phoneticDictionaryArray addObject:word];
            NSLog(@"log for word:%@",word);
        }
    }
    
    return (NSMutableString *)workingString;
}

@end