//
//  StrategyLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 23/10/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ShadeLayer.h"
#import "FlickLayer.h"


@interface StrategyLayer : ShadeLayer {

    FlickLayer                  *_guide;
}

@end
