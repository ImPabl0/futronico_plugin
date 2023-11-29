enum FtrParam {
  imageWidth,
  imageHeight,
  imageSize,
  cbFrameSource,
  cbControl,
  maxModels,
  maxTemplateSize,
  maxFarRequested,
  maxFarnRequested,
  sysErrorCode,
  fakeDetect,
  ffdControl,
  miotControl,
  version,
  checkTrial,
  fastMode,
  scanApiAndroidContext,
}

extension FtrParamValue on FtrParam {
  int get value {
    switch (this) {
      case FtrParam.imageWidth:
        return 1;
      case FtrParam.imageHeight:
        return 2;
      case FtrParam.imageSize:
        return 3;
      case FtrParam.cbFrameSource:
        return 4;
      case FtrParam.cbControl:
        return 5;
      case FtrParam.maxModels:
        return 10;
      case FtrParam.maxTemplateSize:
        return 6;
      case FtrParam.maxFarRequested:
        return 7;
      case FtrParam.maxFarnRequested:
        return 13;
      case FtrParam.sysErrorCode:
        return 8;
      case FtrParam.fakeDetect:
        return 9;
      case FtrParam.ffdControl:
        return 11;
      case FtrParam.miotControl:
        return 12;
      case FtrParam.version:
        return 14;
      case FtrParam.checkTrial:
        return 15;
      case FtrParam.fastMode:
        return 16;
      case FtrParam.scanApiAndroidContext:
        return 100;
      default:
        throw Exception('Invalid FtrParam');
    }
  }
}
