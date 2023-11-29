// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ffi';

import 'enum/ftr_signal_status.dart';
import 'futronico_types.dart';

class FutronicStatus {
  ///Retorna o status atual do leitor para indicar ao usuário quando deve tirar e colocar o dedo
  late FTR_SIGNAL_STATUS currentStatus;

  ///Retorna apenas dois valores, 1 = Leitura cancelada e 2 = Leitura em andamento
  late int response;
  final int? quality;

  FutronicStatus(
      {required int currentStatus,
      Pointer<FTR_RESPONSE>? response,
      this.quality}) {
    this.response = response?.value ?? 0;
    this.currentStatus = FTR_SIGNAL_STATUS.fromInt(currentStatus)!;
  }

  factory FutronicStatus.fromQuality(int quality) {
    return FutronicStatus(currentStatus: 0, quality: quality);
  }
}
