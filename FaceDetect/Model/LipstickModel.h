//
//  LipstickModel.h
//  FaceDetect
//
//  Created by song guolin on 2019/10/16.
//  Copyright © 2019 wkcloveYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

/// 第三级: 某种口红的颜色
@interface LipstickColorModel : NSObject
//"color":"#DC4B41","id":"14","name":"一见倾心"
@property (nonatomic,copy) NSString * color;
@property (nonatomic,copy) NSString * name;
@end


/// 第二级: 某种口红
@interface LipstickModel : NSObject
//"name":"莹亮纯魅唇膏","lipsticks"
@property (nonatomic,copy) NSString * name;

@property (nonatomic,copy) NSArray <LipstickColorModel *>* lipsticks;
@end


/// 第一级:品牌
@interface LipstickBrandModel : NSObject

//"name":"圣罗兰","series"
@property (nonatomic,copy) NSArray<LipstickModel *> * series;

@property (nonatomic,copy) NSString * name;

@end


/// 品牌
@interface LipstickAllModel : NSObject

@property (nonatomic,copy) NSArray<LipstickBrandModel *> * brands;

@end

NS_ASSUME_NONNULL_END
