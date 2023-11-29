// ignore_for_file: camel_case_types

import 'dart:ffi';

@Packed(1)
class FTR_DATA extends Struct {
  @Int32()
  external int dwSize;
  external Pointer<Int32> pData;
}

@Packed(1)
class FTR_ENROLL_DATA extends Struct {
  @Int32()
  external int dwSize;
  @Int32()
  external int dwQuality;
}

@Packed(1)
class FTR_BITMAP extends Struct {
  @Int32()
  external int dwWidth;
  @Int32()
  external int dwHeight;
  external FTR_DATA bitMap;
}
