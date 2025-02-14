---
title: "Core Animation 笔记（一）"
author: "Kevin Wu"
date: "2018/06/13"
category: ["ios"]
---


## CALayerDelegate

CALayer 有一个可选的 delegate 属性，代理需要实现 CALayerDelegate 协议。当需要被重绘时，CALayer 会调用代理的 `displayLayer:` 方法，方法内需要给 layer 设置一个寄宿图。如果代理不实现 `displayLayer:` 方法，CALayer 就会转而尝试调用 `drawLayer:inContext:` 方法。

除非创建一个新的图层，否则几乎没有机会用到 CALayerDelegate 协议。因为当 UIView 创建它的图层时，会把图层的 delegate 设置为自己，并提供一个 `displayLayer:` 的实现。

当使用 Core Graphics 直接绘制寄宿图时，不必实现 `displayLayer:` 和 `drawLayer:inContext:` 方法。通常做法是实现 UIView 的 `drawRect:` 方法，UIView 会做完剩下的工作，包括在需要重绘的时候调用 `display` 方法。

~~~
- (void)viewDidLoad
{
  [super viewDidLoad];

  CALayer *layer = [CALayer layer];
  layer.frame = CGRectMake(10.0, 10.0, 100.0, 100.0);
  layer.backgroundColor = [UIColor blueColor].CGColor;
  [_displayView.layer addSublayer:layer];

  layer.delegate = self;

  [layer display];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
  CGContextSetLineWidth(ctx, 10.0f);
  CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
  CGContextStrokeEllipseInRect(ctx, layer.bounds);
}
~~~

使用视图的时候，可以充分利用视图的 UIViewAutoresizing 或 NSLayoutConstraint 来布局，但 CALayer 的布局需要手工操作。最简单的方法是使用 CALayerDelegate 的 `layoutSublayersOfLayer:` 方法。当图层的 bounds 改变或图层的 `setNeedsLayout` 方法被调用时，这个函数将会被执行，在函数中可以手动地重新摆放图层，但不能像视图的 autoresizingMask 和 constraints 属性做到自适应屏幕旋转。

## 寄宿图

~~~
UIImage *image = [UIImage imageNamed:@"mickey"];
_displayView.layer.contents = (__bridge id)[image CGImage];

// 类似于 UIView 的 clipsToBounds 属性
_displayView.layer.masksToBounds = YES;

// 类似于 UIView 的 contentMode 属性
_displayView.layer.contentsGravity = kCAGravityCenter;

// 定义了寄宿图的像素尺寸和视图大小的比例，默认情况下它是一个值为 1.0 的浮点数，它其实属于
// 支持高分辨率屏幕机制的一部分。如果设置为 1.0，将会以每个点 1 个像素绘制图片；如果设置
// 为 2.0，则会以每个点 2 个像素绘制图片，这就是我们熟知的 Retina 屏幕。
// 如果 contentsGravity 有拉伸效果，会发现这个属性对展示没有任何影响，因为图片已经被拉伸
// 以适应图层的边界。
// 当用代码的方式来处理寄宿图的时候，一定要手动的设置此属性，否则，图片在 Retina 设备上就不
// 能正确显示。
_displayView.layer.contentsScale = image.scale;

// 此属性允许我们在图层边框里显示寄宿图的一个子域。多张图片可以拼合成一张大图并一次性载入，相
// 比多次载入不同的图片，这样做能够带来很多方面的好处：内存使用、载入时间、渲染性能等。
_displayView.layer.contentsRect = CGRectMake(0, 0, 0.3, 0.3);

// 定义了图层中的可拉伸区域和一个固定的边框
_displayView.layer.contentsCenter = CGRectMake(0.25, 0.25, 0.5, 0.5);
~~~

## 圆角

cornerRadius 只影响背景颜色而不影响背景图片或子图层。不过，如果把 masksToBounds 设置成 YES 的话，图层里面的所有东西都会被截取。

~~~
UIView *redView = [[UIView alloc] init];
redView.backgroundColor = [UIColor redColor];
redView.frame = CGRectMake(0, 0, 50, 50);
[_displayView addSubview:redView];

_displayView.layer.cornerRadius = 10.0;
//_displayView.layer.masksToBounds = YES;
~~~

单独控制每个角的圆角曲率是不可能的，如果想创建既有圆角又有直角的图层或视图时，就需要一些不同的方法，比如使用图层蒙板或 CAShapeLayer。

## 边框

边框是绘制在图层边界里面的，而且在所有子内容之前，也在子图层之前。边框是跟随图层的边界变化的，而不是图层里面的内容。

~~~
_displayView.layer.borderColor = [[UIColor redColor] CGColor];
_displayView.layer.borderWidth = 10.0;
~~~

## 阴影

  * shadowOpacity 控制阴影的透明度，值可以是 0.0（不可见）和 1.0（完全不透明）之间的浮点数；
  * shadowColor 设置阴影的颜色；
  * shadowOffset 控制阴影的方向和距离，宽度控制阴影横向位移，高度控制纵向位移；
  * shadowRadius 控制阴影的模糊度，值为 0 的时候，阴影和视图一样有一个非常确定的边界线，值越来越大的时候，边界线看上去就会越来越模糊和自然；
  * shadowPath 可以用来提高阴影性能，CGPathRef 是一个 Core Graphics 对象，可以通过这个属性指定独立于图层形状的阴影形状。

~~~
// 给图层添加阴影，图层的内容形状会影响阴影的形状
// 这里将视图背景设为透明，寄宿图有一部分透明，有一部分不透明，这时的阴影会沿着寄宿的不透明部分
_displayView.backgroundColor = [UIColor clearColor];

UIImage *image = [UIImage imageNamed:@"mickey"];
_displayView.layer.contents = (__bridge id)[image CGImage];

_displayView.layer.shadowColor = [[UIColor redColor] CGColor];
_displayView.layer.shadowOpacity = 1.0;
_displayView.layer.shadowOffset = CGSizeMake(-2.0, 10.0);
_displayView.layer.shadowRadius = 10.0;
~~~

## 蒙板

蒙板图层的颜色属性是无关紧要的，真正重要的是图层的轮廓。

~~~
CALayer *maskLayer = [CALayer layer];
maskLayer.frame = _displayView.bounds;
UIImage *maskImage = [UIImage imageNamed:@"mask.png"];
maskLayer.contents = (__bridge id)maskImage.CGImage;
_displayView.layer.mask = maskLayer;
~~~

蒙板图层真正厉害之处是蒙板图不局限于静态图，任何有图层构成的都可以，这意味着蒙板可以通过代码甚至是动画实时生成。










## Z 坐标轴

zPosition 属性在大多数情况下其实并不常用。后面将介绍如何使用 CATransform3D 在三维空间移动和旋转图层，除此之外，zPosition 最实用的功能就是改变图层的显示顺序，一般情况下，后加的视图会挡住先加的视图，修改图层的 zPosition 可以用先加的视图挡住后加的视图，但这并不会改变 UIView 的顺序。

当调用图层的 `hitTest:` 方法时，测算的顺序严格依赖于图层树当中的图层顺序（和 UIView 处理事件类似）。zPosition 属性可以明显改变屏幕上图层的顺序，但不能改变触摸事件被处理的顺序。





