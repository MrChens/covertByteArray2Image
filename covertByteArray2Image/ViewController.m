//
//  ViewController.m
//  covertByteArray2Image
//
//  Created by MrChens on 31/8/15.
//  Copyright (c) 2015 MrChens. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getImage1];
}
/**
 *  有bug在上面，原因应该就是32位系统和64位系统的原因（等项目做完了再来查）
 */
- (void) getImage {
    NSString *iOSFilePath = [[NSBundle mainBundle] pathForResource:@"iosPic3" ofType:@"txt"];
    
    Byte *testByte = (Byte *)[[NSData dataWithContentsOfFile:iOSFilePath] bytes];
    //  因为多了2次的转码的过程导致了原始数据有变化则显示出的图片会不正确，直接使用上面的代码转则可以使用
    /*NSString *str = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
     NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
     Byte *testByte = (Byte *)[data bytes];*/
    //    int *colors = malloc(1920/2 * 1080/2);
    int colors[1920 * 1080];
    //  argb
    for (int m = 0; m < 1920 * 1080/4; m++) {
        int r = (testByte[m * 3] & 0xFF);
        int g = (testByte[m * 3 + 1] & 0xFF);
        int b = (testByte[m * 3 + 2] & 0xFF);
        
        colors[m] = 0xFF000000 | (b << 16) | (g << 8) | r;
    }
    //  rgba
    /* for (int m = 0; m < 1920/2 * 1080/2; m++) {
     int a = (testByte[m * 3] & 0xFF);
     
     int r = (testByte[m * 3 + 1] & 0xFF);
     int g = (testByte[m * 3 + 2] & 0xFF);
     int b = 0xFF;
     
     colors[m] = (a << 24) + (r << 16) + (g << 8) + b;
     }*/
    uint8_t *piexData = calloc(1920*1080, sizeof(uint8_t));
    for (int m = 0; m < 1920 * 1080/4; m++) {
        int r = (testByte[m * 3] & 0xFF);
        int g = (testByte[m * 3 + 1] & 0xFF);
        int b = (testByte[m * 3 + 2] & 0xFF);
        
        piexData[m] = 0xFF000000 | (r << 16) | (g << 8) | b;
    }
    //
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 384, 216)];
    
    //    free(colors);
    imageView.image = [self RGB2ImageWithRGBArray:piexData width:1920 height:1080];
    
    [self.view addSubview:imageView];
}
/**
 *  现在项目中正在使用的版本
 */
- (void) getImage1 {
    NSString *iOSFilePath = [[NSBundle mainBundle] pathForResource:@"iosPic1" ofType:@"txt"];
    Byte *testByte = (Byte *)[[NSData dataWithContentsOfFile:iOSFilePath] bytes];
    uint32_t *piexData = calloc(1920*1080, sizeof(uint32_t));
    
    for (int m = 0; m < 1920 * 1080/4; m++) {
        int r = (testByte[m * 3] & 0xFF);
        int g = (testByte[m * 3 + 1] & 0xFF);
        int b = (testByte[m * 3 + 2] & 0xFF);
        
        piexData[m] = 0xFF000000 | (b << 16) | (g << 8) | r;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 384, 216)];
    imageView.image = [self RGB2ImageWithRGBArray:piexData width:1920/2 height:1080/2];
    [self.view addSubview:imageView];
    
}
/**
 *  将颜色矩阵数组转为图片
 *
 *  @param colors 颜色矩阵数组
 *  @param width  转换后的宽
 *  @param height 转换后的高
 *
 *  @return 图片
 */
- (UIImage *) RGB2ImageWithRGBArray:(uint32_t *)colors width:(size_t)width height:(size_t)height {
    //  const size_t area = width * height;
    
    /*uint8_t  pixelData[area * componentsPerPixel];
     //  使用不透明的蓝色填充像素
     for (size_t i = 0; i < area; ++i) {
     const size_t offset = i * componentsPerPixel;
     pixelData[offset] = i;
     pixelData[offset + 1] = i;
     pixelData[offset + 2] = i + i;
     pixelData[offset + 3] = UINT8_MAX;
     }*/
    // 创建位图上下文
    const size_t componentsPerPixel = 4;
    const size_t bitsPerCompont = 8;//图片每个颜色的bits
    const size_t bytesPerRow =  width * componentsPerPixel;//每一行占用的bytes
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef gtx = CGBitmapContextCreate(&colors[0], width, height, bitsPerCompont, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    // 创建图片
    CGImageRef toCGImage = CGBitmapContextCreateImage(gtx);
    UIImage *uiImage = [[UIImage alloc] initWithCGImage:toCGImage];
    // 释放内存
    CGImageRelease(toCGImage);
    CGContextRelease(gtx);
    CGColorSpaceRelease(colorSpace);
    return uiImage;
}

@end
