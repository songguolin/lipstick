//
//  LipstickModel.m
//  FaceDetect
//
//  Created by song guolin on 2019/10/16.
//  Copyright © 2019 wkcloveYang. All rights reserved.
//

#import "LipstickModel.h"

@implementation LipstickColorModel
MJExtensionCodingImplementation


@end

@implementation LipstickModel
MJExtensionCodingImplementation
+ (void)load
{
        //数组中需要转换的模型
        [self mj_setupObjectClassInArray:^NSDictionary *{
            return @{@"lipsticks":@"LipstickColorModel"};
        }];
}
@end

@implementation LipstickBrandModel
MJExtensionCodingImplementation
+ (void)load
{
        //数组中需要转换的模型
        [self mj_setupObjectClassInArray:^NSDictionary *{
            return @{@"series":@"LipstickModel"};
        }];
}
@end

@implementation LipstickAllModel
MJExtensionCodingImplementation
+ (void)load
{
        //数组中需要转换的模型
        [self mj_setupObjectClassInArray:^NSDictionary *{
            return @{@"brands":@"LipstickBrandModel"};
        }];
}

@end
