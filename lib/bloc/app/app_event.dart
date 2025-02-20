import 'package:equatable/equatable.dart';

class AppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppInitialize extends AppEvent {
  AppInitialize();

  @override
  List<Object?> get props => [];
}

class AppUpdate extends AppEvent {
  final bool updateBalance;

  AppUpdate({this.updateBalance = false});

  @override
  List<Object?> get props => [updateBalance];
}

class AppSignOut extends AppEvent {}
