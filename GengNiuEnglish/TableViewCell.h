//
//  TableViewCell.h
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/21.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataForCell.h"

@interface TableViewCell : UITableViewCell
@property(strong,nonatomic)DataForCell *book;
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;
@end
