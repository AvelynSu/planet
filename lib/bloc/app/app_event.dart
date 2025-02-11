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
  AppUpdate();

  @override
  List<Object?> get props => [];
}

class AppSignOut extends AppEvent {}
