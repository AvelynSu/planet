import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ExceptionType {
  unknown,

  invalidMnemonicPhrase,

  failTransferInitailize,
}

class CustomException extends Equatable {
  final ExceptionType? errType;
  final FirebaseException? fbErr;
  final String? errMsg;

  const CustomException({
    this.errType,
    this.fbErr,
    this.errMsg,
  });

  static const empty = CustomException();

  @override
  List<Object?> get props => [errType, fbErr, errMsg, errMsg];
}
