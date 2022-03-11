//
//  VideoCell.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import "VideoCell.h"
#import <SDWebImage/SDWebImage.h>
#import "VideoModel.h"

@implementation VideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

- (void)configCell:(VideoModel *)model {
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.author;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail]];
}

- (void)setupUI {
    [self.contentView insertSubview:self.coverImageView atIndex:0];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.subTitleLabel);
        make.right.equalTo(self.subTitleLabel.mas_right);
        make.bottom.equalTo(self.subTitleLabel.mas_top).offset(-10);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-20);
    }];
}

#pragma mark - getter
- (UIImageView *)coverImageView {
    if(!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if(!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textColor = UIColor.whiteColor;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.numberOfLines = 4;
    }
    return _subTitleLabel;
}

@end
