//
//  ViewController.m
//  TJFaceDetector
//
//  Created by TanJian on 2017/9/1.
//  Copyright © 2017年 Joshpell. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UILabel *faceCountLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *imagePickBtn;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *changeImageBtn;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSArray *demoImageArr;
@property (nonatomic, assign) NSInteger index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _index = 0;
    
    [self configerUI];
 
    [self firstDetector];
}

-(void)firstDetector{
    
    UIImage *image = self.demoImageArr[0];
    
    self.imageView.image = image;
    
    [self faceDetectWithImage:image];
}

-(void)configerUI{
    
    _faceCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width-90, 20)];
    _faceCountLabel.textColor = [UIColor grayColor];
    [self.view addSubview:_faceCountLabel];
    
    _changeImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_faceCountLabel.frame),25,60,30)];
    _changeImageBtn.tag = 0;
    _changeImageBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_changeImageBtn setTitle:@"更换图片" forState:UIControlStateNormal];
    [_changeImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _changeImageBtn.backgroundColor = [UIColor blueColor];
    [_changeImageBtn addTarget:self action:@selector(changeImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_changeImageBtn];
    
    _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 55,[UIScreen mainScreen].bounds.size.width-40, 20)];
    _tipsLabel.textColor = [UIColor blueColor];
    [self.view addSubview:_tipsLabel];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-80-50)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _imagePickBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height-40, 80, 35)];
    [_imagePickBtn setTitle:@"相片" forState:UIControlStateNormal];
    [_imagePickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _imagePickBtn.backgroundColor = [UIColor blueColor];
    [_imagePickBtn addTarget:self action:@selector(pickPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imagePickBtn];
    
    _cameraBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-100, [UIScreen mainScreen].bounds.size.height-40, 80, 35)];
    [_cameraBtn setTitle:@"相机" forState:UIControlStateNormal];
    [_cameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cameraBtn.backgroundColor = [UIColor blueColor];
    [_cameraBtn addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraBtn];
    
}



-(void)changeImage:(UIButton *)sender{
    
    
    if (_index == 3) {
        
        _index = 0;
    }else{
        
        _index++;
    }
    
    UIImage *image = self.demoImageArr[_index];
    
    self.imageView.image = image;
    
    [self faceDetectWithImage:image];
}

-(void)pickPhoto{
    
    self.imagePicker.allowsEditing = false;
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imagePicker animated:YES completion:nil];
    
}

-(void)openCamera{
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要真机运行，才能打开相机哦" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    self.imagePicker.allowsEditing = false;
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:_imagePicker animated:YES completion:nil];
    
}

#pragma mark - 识别人脸
- (void)faceDetectWithImage:(UIImage *)image {
    
    for (UIView *view in _imageView.subviews) {
        [view removeFromSuperview];
    }
    
    // 图像识别能力：可以在CIDetectorAccuracyHigh(较强的处理能力)与CIDetectorAccuracyLow(较弱的处理能力)中选择，因为想让准确度高一些在这里选择CIDetectorAccuracyHigh
    NSDictionary *opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    // 将图像转换为CIImage
    CIImage *faceImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    // 识别出人脸特征信息数组
    NSArray *features = [faceDetector featuresInImage:faceImage];
    // 得到图片的尺寸
    //注意这里是原始图片尺寸，跟屏幕显示大小不一样，需要处理
    CGSize inputImageSize = [faceImage extent].size;
    //将image沿y轴对称
//    CGAffineTransformMakeScale(-1.0, 1.0);//水平翻转
//    CGAffineTransformMakeScale(1.0,-1.0);//垂直翻转
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    //将图片上移
    transform = CGAffineTransformTranslate(transform, 0, -inputImageSize.height);
    
    // 取出所有人脸
    //注意：coreimage的坐标系与UIView的坐标系不一样，需要处理,前者零点在左下角，x、y分别向右向上增大；后者零点在左上角，x、y分别向右向上、下增大
    for (CIFaceFeature *faceFeature in features){
        //获取人脸的frame,仿射变换后的值
        CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        CGSize viewSize = _imageView.bounds.size;
        
        //由于imageview使用的是UIViewContentModeScaleAspectFit长边铺满，比例自适应图片，所以取较小比例
        CGFloat scale = MIN(viewSize.width / inputImageSize.width,
                            viewSize.height / inputImageSize.height);
        CGFloat offsetX = (viewSize.width - inputImageSize.width * scale) * 0.5;
        CGFloat offsetY = (viewSize.height - inputImageSize.height * scale) * 0.5;
        // 缩放
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        // 修正
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        //描绘人脸区域
        UIView* faceView = [[UIView alloc] initWithFrame:faceViewBounds];
        faceView.layer.borderWidth = 2;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [_imageView addSubview:faceView];
        
        // 判断是否有左眼位置
        if(faceFeature.hasLeftEyePosition){
            
            CGPoint leftEyePoint = CGPointApplyAffineTransform(faceFeature.leftEyePosition, transform);
            leftEyePoint = CGPointApplyAffineTransform(leftEyePoint, scaleTransform);

            UIView *leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(leftEyePoint.x-5+offsetX, leftEyePoint.y-5+offsetY, 10, 10)];
            leftEyeView.layer.borderWidth = 1;
            leftEyeView.layer.borderColor = [[UIColor blueColor] CGColor];
            [_imageView addSubview:leftEyeView];
            
        }
        // 判断是否有右眼位置
        if(faceFeature.hasRightEyePosition){
            
            CGPoint rightEyePoint = CGPointApplyAffineTransform(faceFeature.rightEyePosition, transform);
            rightEyePoint = CGPointApplyAffineTransform(rightEyePoint, scaleTransform);
            
            UIView *rightEyeView = [[UIView alloc] initWithFrame:CGRectMake(rightEyePoint.x-5+offsetX, rightEyePoint.y-5+offsetY, 10, 10)];
            rightEyeView.layer.borderWidth = 1;
            rightEyeView.layer.borderColor = [[UIColor blueColor] CGColor];
            [_imageView addSubview:rightEyeView];
            
        }
        // 判断是否有嘴位置
        if(faceFeature.hasMouthPosition){
            
            CGPoint mouthPoint = CGPointApplyAffineTransform(faceFeature.mouthPosition, transform);
            mouthPoint = CGPointApplyAffineTransform(mouthPoint, scaleTransform);
            
            UIView *mouthView = [[UIView alloc] initWithFrame:CGRectMake(mouthPoint.x-8+offsetX, mouthPoint.y-5+offsetY, 16, 10)];
            mouthView.layer.borderWidth = 1;
            mouthView.layer.borderColor = [[UIColor yellowColor] CGColor];
            [_imageView addSubview:mouthView];
        }
    }
    self.faceCountLabel.text = [NSString stringWithFormat:@"识别出了%ld张脸", features.count];
}

#pragma mark pikerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self faceDetectWithImage:image];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIImagePickerController *)imagePicker {
    
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(NSArray *)demoImageArr{
    
    if (!_demoImageArr) {
        _demoImageArr = @[[UIImage imageNamed:@"image1"],[UIImage imageNamed:@"image2"],[UIImage imageNamed:@"image3"],[UIImage imageNamed:@"image4"]];
    }
    return _demoImageArr;
}

@end
