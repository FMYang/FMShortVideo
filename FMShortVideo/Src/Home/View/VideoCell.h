//
//  VideoCell.h
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VideoModel;

@interface VideoCell : UITableViewCell

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

- (void)configCell:(VideoModel *)model;

@end

NS_ASSUME_NONNULL_END
