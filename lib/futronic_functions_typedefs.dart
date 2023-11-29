import 'dart:ffi';

import 'futronico_types.dart';
import 'structs.dart';

typedef initializeFunc = FTRAPIRESULT Function();
typedef Initialize = int Function();

typedef TerminateFunc = FTRAPIRESULT Function();
typedef Terminate = int Function();

typedef EnrollFunc = FTRAPIRESULT Function(
    Pointer ftrUserCtx, Int32 userPurpose, Pointer<FTR_DATA> pTemplate);
typedef Enroll = int Function(
    Pointer ftrUserCtx, int userPurpose, Pointer<FTR_DATA> pTemplate);
typedef EnrollXFunc = FTRAPIRESULT Function(
    Pointer ftrUserCtx,
    Int32 userPurpose,
    Pointer<FTR_DATA> pTemplate,
    Pointer<FTR_ENROLL_DATA> pEnrollData);
typedef EnrollX = int Function(Pointer ftrUserCtx, int userPurpose,
    Pointer<FTR_DATA> pTemplate, Pointer<FTR_ENROLL_DATA> pEnrollData);

typedef VerifyFunc = FTRAPIRESULT Function(Pointer ftrUserCtx,
    Pointer<FTR_DATA> pTemplateToCompare, Pointer<Bool> bResult, Uint32 nFar);

typedef Verify = int Function(Pointer ftrUserCtx,
    Pointer<FTR_DATA> pTemplateToCompare, Pointer<Bool> bResult, int nFar);

typedef FTRSetParamFunc = Int32 Function(Int32 param, Int32 paramValue);
typedef FTRSetParam = int Function(int param, int paramValue);

typedef FTRSetCallbackFunc = Int32 Function(
    Int32 param, Pointer<NativeFunction<FTRCbStateControlFunc>> paramValue);
typedef FTRSetCallback = int Function(
    int param, Pointer<NativeFunction<FTRCbStateControlFunc>> paramValue);

typedef FTRGetParamFunc = Int32 Function(
    Int32 param, Pointer<Int64> paramValue);
typedef FTRGetParam = int Function(int param, Pointer<Int64> paramValue);

typedef FTRCaptureFrameFunc = Int32 Function(
    FTR_USER_CTX context, FTR_FRAME_BUFFER pFrameBuffer);
typedef FTRCaptureFrame = int Function(
    FTR_USER_CTX context, FTR_FRAME_BUFFER pFrameBuffer);

typedef FTRCbStateControlFunc = Void Function(
    FTR_USER_CTX context,
    FTR_STATE stateMask,
    Pointer<FTR_RESPONSE> response,
    FTR_SIGNAL signal,
    Pointer<FTR_BITMAP> pBitmap);
