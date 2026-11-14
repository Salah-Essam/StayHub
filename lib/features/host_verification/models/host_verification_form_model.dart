import 'dart:io';

class HostVerificationFormModel {
  String fullName;
  String phoneNumber;
  File? idFront;
  File? idBack;
  File? selfiePhoto;

  HostVerificationFormModel({
    this.fullName = '',
    this.phoneNumber = '',
    this.idFront,
    this.idBack,
    this.selfiePhoto,
  });

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty &&
      idFront != null &&
      idBack != null &&
      selfiePhoto != null;
}
