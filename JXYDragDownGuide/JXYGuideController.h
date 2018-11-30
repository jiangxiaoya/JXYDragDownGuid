//
//  JXYGuideController.h
//  JXYDragDownGuide
//
//  Created by 蒋小丫 on 2018/11/28.
//  Copyright © 2018年 蒋小丫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^JXYInterfaceCloseDoneBlock)(void);

@interface JXYGuideController : UIViewController

@property (nonatomic, copy) JXYInterfaceCloseDoneBlock closeDone;

@end

NS_ASSUME_NONNULL_END
