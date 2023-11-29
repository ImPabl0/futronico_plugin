// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';
import 'dart:ui';

class FutronicUtils {
  int FTR_RETCODE_ERROR_BASE = 1;
  int FTR_RETCODE_DEVICE_BASE = 200;

  int get FTR_RETCODE_INTERNAL_ERROR => FTR_RETCODE_ERROR_BASE + 5;

  static const int _FTR_RETCODE_NO_MEMORY = 2;
  static const int _FTR_RETCODE_INVALID_ARG = 3;
  static const int _FTR_RETCODE_ALREADY_IN_USE = 4;
  static const int _FTR_RETCODE_INVALID_PURPOSE = 5;
  static const int _FTR_RETCODE_UNABLE_TO_CAPTURE = 6;
  static const int _FTR_RETCODE_CANCELED_BY_USER = 7;
  static const int _FTR_RETCODE_NO_MORE_RETRIES = 8;
  static const int _FTR_RETCODE_INCONSISTENT_SAMPLING = 10;
  static const int _FTR_RETCODE_TRIAL_EXPIRED = 11;

  static const int _FTR_RETCODE_FRAME_SOURCE_NOT_SET = 201;
  static const int _FTR_RETCODE_DEVICE_NOT_CONNECTED = 202;
  static const int _FTR_RETCODE_DEVICE_FAILURE = 203;
  static const int _FTR_RETCODE_EMPTY_FRAME = 204;
  static const int _FTR_RETCODE_FAKE_SOURCE = 205;
  static const int _FTR_RETCODE_INCOMPATIBLE_HARDWARE = 206;
  static const int _FTR_RETCODE_INCOMPATIBLE_FIRMWARE = 207;
  static const int _FTR_RETCODE_FRAME_SOURCE_CHANGED = 208;
  static const int _FTR_RETCODE_INCOMPATIBLE_SOFTWARE = 209;

  // transforme todos os codigos acima para um Map<int, String> com uma mensagem legível para o usuário
  static final Map<int, String> _mapErrorCodes = {
    _FTR_RETCODE_NO_MEMORY:
        "Não há memória suficiente para executar a operação.",
    _FTR_RETCODE_INVALID_ARG:
        "Um dos argumentos passados para a função é inválido.",
    _FTR_RETCODE_ALREADY_IN_USE: "O dispositivo já está em uso.",
    _FTR_RETCODE_INVALID_PURPOSE:
        "O propósito da chamada da função é inválido.",
    _FTR_RETCODE_UNABLE_TO_CAPTURE: "Não foi possível capturar a imagem.",
    _FTR_RETCODE_CANCELED_BY_USER: "A operação foi cancelada pelo usuário.",
    _FTR_RETCODE_NO_MORE_RETRIES: "Não há mais tentativas disponíveis.",
    _FTR_RETCODE_INCONSISTENT_SAMPLING: "A amostragem é inconsistente.",
    _FTR_RETCODE_TRIAL_EXPIRED: "O período de teste expirou.",
    _FTR_RETCODE_FRAME_SOURCE_NOT_SET: "A fonte de quadros não está definida.",
    _FTR_RETCODE_DEVICE_NOT_CONNECTED: "O dispositivo não está conectado.",
    _FTR_RETCODE_DEVICE_FAILURE: "O dispositivo falhou.",
    _FTR_RETCODE_EMPTY_FRAME: "O quadro está vazio.",
    _FTR_RETCODE_FAKE_SOURCE: "A fonte é falsa.",
    _FTR_RETCODE_INCOMPATIBLE_HARDWARE: "O hardware é incompatível.",
    _FTR_RETCODE_INCOMPATIBLE_FIRMWARE: "O firmware é incompatível.",
    _FTR_RETCODE_FRAME_SOURCE_CHANGED: "A fonte do quadro foi alterada.",
    _FTR_RETCODE_INCOMPATIBLE_SOFTWARE: "O software é incompatível.",
  };

  static String getErrorMessage(int errorCode) {
    throw FutronicError(_mapErrorCodes[errorCode]!);
  }

  static Future<Image> bytesToImage(Uint8List imgBytes) async {
    Codec codec = await instantiateImageCodec(imgBytes);
    FrameInfo frame;
    try {
      frame = await codec.getNextFrame();
    } finally {
      codec.dispose();
    }
    return frame.image;
  }
}

class FutronicError implements Exception {
  final String message;

  FutronicError(this.message);
}
