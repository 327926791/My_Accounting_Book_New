//
//  OpenCVWrapper.m
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/12/29.
//  Copyright © 2018年 Team_927. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <opencv2/imgcodecs/ios.h>

@implementation OpenCVWrapper

+ (UIImage *)imageProcessing:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat matGrayscale;
    cv::cvtColor(mat, matGrayscale, CV_BGR2GRAY);
    cv::Mat tmp;
    matGrayscale.convertTo(tmp, CV_8U);
    cv::Mat dest;
    cv::adaptiveThreshold(tmp, dest, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, 11, 10);
    return MatToUIImage(dest);
}

@end
