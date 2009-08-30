/*
 * This file is part of Deblock.
 *
 *  Deblock is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Deblock is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Deblock in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  BombBlockLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 26/08/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "BlockLayer.h"


@interface SpecialBlockLayer : BlockLayer {
}
@end

@interface BombBlockLayer : SpecialBlockLayer {
}
@end

@interface MorphBlockLayer : SpecialBlockLayer {
}
@end

@interface ZapBlockLayer : SpecialBlockLayer {
}
@end

@interface FreezeBlockLayer : SpecialBlockLayer {
}
@end
