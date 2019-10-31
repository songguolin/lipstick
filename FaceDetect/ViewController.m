//
//  ViewController.m
//  FaceDetect
//
//  Created by wkcloveYang on 2019/10/9.
//  Copyright © 2019 wkcloveYang. All rights reserved.
//

#import "ViewController.h"
#import "WKCFaceDetectManager.h"
#import "WKCFaceDetectDrawImageView.h"
#import "TZImagePickerController.h"

#import "UIColor+Hex.h"
#import "Palette.h"
#import "UIImage+Palette.h"

#import "DemoShowColorSingleView.h"

#import "MJExtension.h"
#import "LipstickModel.h"
@interface ViewController ()<TZImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet WKCFaceDetectDrawImageView *drawView;
@property (weak, nonatomic) IBOutlet UIImageView *lipsImgv;

@property (weak, nonatomic) IBOutlet UICollectionView *colorDisplayView;
//分析出片出来的颜色
@property (nonatomic,copy) NSDictionary *allModeColorDic;


//口红数据
@property (nonatomic,strong)  LipstickAllModel * allLipstickModel;

//匹配结果数据
@property (nonatomic,strong)  NSMutableDictionary * matchLipstickDict;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.matchLipstickDict = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"lipstick" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    self.allLipstickModel = [LipstickAllModel mj_objectWithKeyValues:dic];
    
//    _colorDisplayView.hidden = YES;
    [_colorDisplayView registerClass:[DemoShowColorViewCell class] forCellWithReuseIdentifier:@"colorCell"];
    UIImage * image = [UIImage imageNamed:@"1.jpg"];
    
    [self.view layoutSubviews];

    self.drawView.backgroundColor = [UIColor whiteColor];
    self.drawView.shouldDrawedRemove = YES;
 
    self.drawView.image = image;
    __weak typeof(self) weakSelf= self;
    self.drawView.completionBlock = ^(WKCFaceDetectDrawState state, WKCFaceDetectModel *faceDetectModel) {

        if (state == WKCFaceDetectDrawStateSuccess) {
            WKCFaceDetectFace * face = faceDetectModel.faces.firstObject;
            NSMutableArray * arr = [NSMutableArray array];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips0]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips1]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips2]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips3]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips4]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips5]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips6]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips7]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips8]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips9]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips10]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips11]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips12]];
            [arr addObject:[NSValue valueWithCGPoint:face.outerLips13]];

            [weakSelf getMostColor:[weakSelf cropImage:faceDetectModel.faces.firstObject]];
        }
        else
        {
            [weakSelf getMostColor:weakSelf.drawView.image];
        }
        
       
    };
    
    
    
}


-(UIImage *)cropImage:(WKCFaceDetectFace *)face
{
    UIGraphicsBeginImageContextWithOptions(self.drawView.bounds.size, NO, self.drawView.image.scale);
    //嘴唇
    UIBezierPath * line15 = [UIBezierPath bezierPath];
    [line15 moveToPoint:face.outerLips0];
    for (int i = 1; i < face.outerLipsValues.count; i++) {
        NSValue *valueI = face.outerLipsValues[i];
        CGPoint pointI = [valueI CGPointValue];
         [line15 addLineToPoint:pointI];
    }

    [line15 addClip];
    [self.drawView.image drawInRect:self.drawView.bounds];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    self.lipsImgv.image = image;
    UIGraphicsEndImageContext();
    return image;
   
    
}
-(void)getMostColor:(UIImage *)image
{
    __weak typeof(self) weakSelf= self;
    [image getPaletteImageColorWithMode:ALL_MODE_PALETTE withCallBack:^(PaletteColorModel *recommendColor, NSDictionary *allModeColorDic,NSError *error) {
        
        if (!recommendColor){
            return;
        }

        weakSelf.allModeColorDic = allModeColorDic;
        weakSelf.view.backgroundColor = [UIColor colorWithHexString:recommendColor.imageColorString];
        [weakSelf.colorDisplayView reloadData];
        [weakSelf matchLipstickWithColor:[UIColor colorWithHexString:recommendColor.imageColorString]];
        
    }];
}
//-(BOOL)firstColor:(UIColor*)firstColor secondColor:(UIColor*)secondColor
//{
//    if (CGColorEqualToColor(firstColor.CGColor, secondColor.CGColor))
//    {
//        NSLog(@"颜色相同");
//        return YES;
//    }
//    else
//    {
//        NSLog(@"颜色不同");
//        return NO;
//    }
//}

-(void)matchLipstickWithColor:(UIColor *)color
{
    [self.matchLipstickDict removeAllObjects];
    __weak typeof(self) weakSelf = self;
    [self.allLipstickModel.brands enumerateObjectsUsingBlock:^(LipstickBrandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.series enumerateObjectsUsingBlock:^(LipstickModel * _Nonnull lipstickModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [lipstickModel.lipsticks enumerateObjectsUsingBlock:^(LipstickColorModel * _Nonnull colorModel, NSUInteger idx, BOOL * _Nonnull stop) {
                float difference = [weakSelf matchImageColor:color lipstickColor:[UIColor colorWithHexString:colorModel.color]];
                if (difference < 0.1) {
                  
                    NSString * lipstick = [NSString stringWithFormat:@"%@-%@-%@",obj.name,lipstickModel.name,colorModel.name];
             
                    [weakSelf.matchLipstickDict setObject:lipstick forKey:[NSString stringWithFormat:@"%f",difference]];
                }
            }];
        }];
    }];
    
    NSArray * arr = [weakSelf.matchLipstickDict.allKeys sortedArrayUsingComparator:
                         ^NSComparisonResult(id obj1, id obj2) {
                             // [obj2 compare:obj1]; //降序
                             //  //升序
    
                             NSComparisonResult result = [obj1 compare:obj2];
                             
                             
                             return result;
                         }];
    NSString * alertStr = @"";
    for (NSString * key in arr) {
        NSLog(@"%@-%@",key,[self.matchLipstickDict objectForKey:key]);
        alertStr = [NSString stringWithFormat:@"%@\n%@",alertStr,[self.matchLipstickDict objectForKey:key]];
    }
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:alertStr message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
//模糊匹配颜色
-(float)matchImageColor:(UIColor *)imageColor lipstickColor:(UIColor*)lipstickColor
{
    const CGFloat* components1 = CGColorGetComponents(imageColor.CGColor);
    CGFloat Red1, Green1, Blue1, Alpha1;
    Alpha1 = components1[3];
    Red1 = components1[0];
    Green1 = components1[1];
    Blue1 = components1[2];
    
    const CGFloat* components2 = CGColorGetComponents(lipstickColor.CGColor);
    CGFloat Red2, Green2, Blue2, Alpha2;
    Alpha2 = components2[3];
    Red2 = components2[0];
    Green2 = components2[1];
    Blue2 = components2[2];
    
    //向量比较
    float difference = pow( pow((Red1 - Red2), 2) + pow((Green1 - Green2), 2) + pow((Blue1 - Blue2), 2), 0.5 );
    
    return difference;

}

- (IBAction)selectImageAction:(UIButton *)sender {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];

       // You can get the photos by block, the same as by delegate.
       // 你可以通过block或者代理，来得到用户选择的照片.
 
    __weak typeof(self) weakSelf= self;
       [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
       
           weakSelf.drawView.image = photos.firstObject;
       }];
       [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}


#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DemoShowColorViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCell" forIndexPath:indexPath];
    
    if (!cell){
        cell = [[DemoShowColorViewCell alloc]init];
    }
    PaletteColorModel *colorModel;
    NSString *modeKey;
    switch (indexPath.row) {
        case 0:
            colorModel = [self.allModeColorDic objectForKey:@"vibrant"];
            modeKey = @"vibrant";
            break;
        case 1:
            colorModel = [self.allModeColorDic objectForKey:@"muted"];
            modeKey = @"muted";
            break;
        case 2:
            colorModel = [self.allModeColorDic objectForKey:@"light_vibrant"];
            modeKey = @"light_vibrant";
            break;
        case 3:
            colorModel = [self.allModeColorDic objectForKey:@"light_muted"];
            modeKey = @"light_muted";
            break;
        case 4:
            colorModel = [self.allModeColorDic objectForKey:@"dark_vibrant"];
            modeKey = @"dark_vibrant";
            break;
        case 5:
            colorModel = [self.allModeColorDic objectForKey:@"dark_muted"];
            modeKey = @"dark_muted";
            break;
            
        default:
            break;
    }
    [cell configureData:colorModel andKey:modeKey];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.bounds.size.width / 2 , self.view.bounds.size.width / 2);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _allModeColorDic.count;
}


@end
