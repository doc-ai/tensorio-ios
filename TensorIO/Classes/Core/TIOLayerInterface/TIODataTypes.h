//
//  TIODataTypes.h
//  TensorIO
//
//  Created by Phil Dow on 4/18/19.
//

#ifndef TIODataTypes_h
#define TIODataTypes_h

/**
 * The data types used by at least one of the supported backends
 */

typedef enum : NSUInteger {
    TIODataTypeUnknown,
    TIODataTypeUInt8,       // "uint8"
    TIODataTypeFloat32,     // "float32"
    TIODataTypeInt32,       // "int32"
    TIODataTypeInt64        // "int64"
} TIODataType;

#endif /* TIODataTypes_h */
