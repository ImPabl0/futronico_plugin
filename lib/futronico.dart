// ignore_for_file: camel_case_types

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'enum/ftr_param.dart';
import 'futronic_enroll_result.dart';
import 'futronic_functions_typedefs.dart';
import 'futronic_status.dart';
import 'futronic_utils.dart';
import 'futronico_types.dart';
import 'structs.dart';

typedef showMessageBoxFunc = Int32 Function(
    Pointer<Utf16> message, Pointer<Utf16> topic);
typedef showMessageBox = int Function(
    Pointer<Utf16> message, Pointer<Utf16> topic);

class Futronico {
  static final dll = DynamicLibrary.open("FTRAPI.dll");
  static bool _isInitialized = false;

  static StreamController<FutronicStatus> futronicStatusController =
      StreamController<FutronicStatus>.broadcast();

  Isolate? _currentIsolate;

  //Definindo buffers
  int _imageSize = 0;
  static final Pointer<FTR_DATA> _ftrDataBuffer = calloc<FTR_DATA>();
  static final Pointer<FTR_ENROLL_DATA> _ftrEnrollDataBuffer =
      calloc<FTR_ENROLL_DATA>();

  // Definindo funções
  Initialize get _initialize =>
      dll.lookup<NativeFunction<initializeFunc>>("FTRInitialize").asFunction();

  Terminate get _terminate =>
      dll.lookup<NativeFunction<TerminateFunc>>("FTRTerminate").asFunction();

  EnrollX get _enrollX =>
      dll.lookup<NativeFunction<EnrollXFunc>>("FTREnrollX").asFunction();

  Verify get _verify =>
      dll.lookup<NativeFunction<VerifyFunc>>("FTRVerify").asFunction();

  FTRSetParam get _setParam =>
      dll.lookup<NativeFunction<FTRSetParamFunc>>("FTRSetParam").asFunction();

  FTRSetCallback get _setCallbackFunc => dll
      .lookup<NativeFunction<FTRSetCallbackFunc>>("FTRSetParam")
      .asFunction();

  FTRGetParam get _getParam =>
      dll.lookup<NativeFunction<FTRGetParamFunc>>("FTRGetParam").asFunction();

  FTRCaptureFrame get _captureFrame => dll
      .lookup<NativeFunction<FTRCaptureFrameFunc>>("FTRCaptureFrame")
      .asFunction();

  // Definindo métodos públicos
  static SendPort? sendPort;
  void initialize({SendPort? sendPort}) {
    Futronico.sendPort = sendPort;
    if (_isInitialized) return;
    int initializeResult = _initialize();
    if (initializeResult != 0) {
      if (initializeResult == 4) return;
      throw FutronicError(FutronicUtils.getErrorMessage(initializeResult));
    }
    _isInitialized = true;
    configureFutronic();
  }

  void terminate() {
    try {
      int terminateResult = _terminate();
      if (terminateResult != 0) {
        throw FutronicError(FutronicUtils.getErrorMessage(terminateResult));
      }
    } catch (e) {
      // throw Exception("Erro ao tentar finalizar o futronic");
    }
  }

  void configureFutronic({int? maxTemplates}) {
    int configureFrameSource = _ftrSetParam(FtrParam.cbFrameSource, 1);
    int configureMaxTemplates =
        _ftrSetParam(FtrParam.maxModels, maxTemplates ?? 5);
    if (configureFrameSource != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(configureFrameSource));
    }
    if (configureMaxTemplates != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(configureMaxTemplates));
    }
    Pointer<Int64> frameWidthPTR = calloc<Int64>();
    Pointer<Int64> frameHeightPTR = calloc<Int64>();
    Pointer<Int64> frameSizePTR = calloc<Int64>();
    Pointer<Int64> maxTemplateSize = calloc<Int64>();

    int getWidth = _getParam(FtrParam.imageWidth.value, frameWidthPTR);
    int getHeight = _getParam(FtrParam.imageHeight.value, frameHeightPTR);
    int getSize = _getParam(FtrParam.imageSize.value, frameSizePTR);

    _imageSize = frameSizePTR.value;

    if (getWidth != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(getWidth));
    }
    if (getHeight != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(getHeight));
    }
    if (getSize != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(getSize));
    }

    int setMaxModels = _ftrSetParam(FtrParam.maxModels, 5);

    if (setMaxModels != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(setMaxModels));
    }

    _getParam(FtrParam.maxTemplateSize.value, maxTemplateSize);

    _ftrDataBuffer.ref.pData =
        calloc<Uint8>(sizeOf<Int64>() * maxTemplateSize.value);

    _setCallbackFunc(FtrParam.cbControl.value, Pointer.fromFunction(callback));
  }

  static void callback(FTR_USER_CTX context, int stateMask,
      Pointer<FTR_RESPONSE> response, int signal, Pointer<FTR_BITMAP> pBitmap) {
    FutronicStatus actualStatus =
        FutronicStatus(currentStatus: signal, response: response);
    sendPort?.send(actualStatus);
  }

  void captureFrame() {
    FTR_USER_CTX ftrUserCtx = calloc<Int32>();
    FTR_FRAME_BUFFER ftrFrameBuffer = calloc(sizeOf<Int32>() * _imageSize);
    int captureFrameResult = _captureFrame(ftrUserCtx, ftrFrameBuffer);
    if (captureFrameResult != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(captureFrameResult));
    }
  }

  List<int> enrollX() {
    int enrollDataSize = sizeOf<FTR_ENROLL_DATA>();
    _ftrEnrollDataBuffer.ref.dwSize = enrollDataSize;
    int enrollResult =
        _enrollX(nullptr, 3, _ftrDataBuffer, _ftrEnrollDataBuffer);

    if (enrollResult != 0) {
      String errorMessage = FutronicUtils.getErrorMessage(enrollResult);

      throw FutronicError(errorMessage);
    }
    List<int> template = _ftrDataBuffer.ref.pData
        .asTypedList(_ftrDataBuffer.ref.dwSize)
        .toList();
    sendPort
        ?.send(FutronicStatus.fromQuality(_ftrEnrollDataBuffer.ref.dwQuality));
    sendPort?.send(template);
    return template;
  }

  Future<FutronicEnrollResult> enrollTemplate() async {
    ReceivePort receivePort = ReceivePort();
    FutronicEnrollResult futronicEnrollResult = FutronicEnrollResult();
    Completer<FutronicEnrollResult> completer =
        Completer<FutronicEnrollResult>();

    _currentIsolate = await Isolate.spawn((message) async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(
          message[0] as RootIsolateToken);
      DartPluginRegistrant.ensureInitialized();
      terminate();
      initialize(sendPort: message[1] as SendPort);
      enrollX();
    }, [RootIsolateToken.instance!, receivePort.sendPort], onError: sendPort);
    _currentIsolate?.addErrorListener(receivePort.sendPort);
    receivePort.listen((message) {
      if (message is FutronicStatus) {
        futronicStatusController.add(message);
      }
      if (message is FutronicStatus && message.quality != null) {
        futronicEnrollResult.quality = message.quality!;
      }
      if (message is List<int>) {
        futronicEnrollResult.enrollTemplate = message;
        completer.complete(futronicEnrollResult);
      }
      if (message is List<dynamic>) {
        throw FutronicError(message[0]);
      }
    });
    await completer.future;
    receivePort.close();
    return await completer.future;
  }

  bool cancelOperation() {
    try {
      terminate();
      _currentIsolate?.kill(priority: Isolate.immediate);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verify(List<int> template) async {
    ReceivePort receivePort = ReceivePort();
    Completer<bool> completer = Completer<bool>();
    _currentIsolate = await Isolate.spawn((message) {
      terminate();
      initialize();
      Pointer<FTR_DATA> templateToCompare = calloc<FTR_DATA>();
      templateToCompare.ref.dwSize = template.length;
      templateToCompare.ref.pData = calloc<Uint8>(template.length);
      templateToCompare.ref.pData
          .asTypedList(template.length)
          .setAll(0, template);
      Pointer<Bool> bResult = calloc<Bool>();
      int verifyResult = _verify(nullptr, templateToCompare, bResult, 0);
      if (verifyResult != 0) {
        throw FutronicError(FutronicUtils.getErrorMessage(verifyResult));
      }
      message.send(bResult.value);
    }, receivePort.sendPort);

    _currentIsolate?.addErrorListener(receivePort.sendPort);
    receivePort.listen((message) {
      if (message is bool) {
        completer.complete(message);
      }
      if (message is List<dynamic>) {
        throw FutronicError(message[0]);
      }
    });
    await completer.future;
    receivePort.close();
    return await completer.future;
  }

  int _ftrSetParam(FtrParam param, int paramValue) {
    int setParamResult = _setParam(param.value, paramValue);
    if (setParamResult != 0) {
      throw FutronicError(FutronicUtils.getErrorMessage(setParamResult));
    }
    return setParamResult;
  }
}
