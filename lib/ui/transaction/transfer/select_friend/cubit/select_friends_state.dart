part of 'select_friends_cubit.dart';

class SelectFriendsState extends Equatable {
  final ScreenStatus status;
  final CustomException exception;

  final List<Planet> planets;

  final String searchText;

  const SelectFriendsState({
    this.status = ScreenStatus.initial,
    this.exception = CustomException.empty,
    this.planets = const [],
    this.searchText = "",
  });

  List<Planet> get filtered {
    if (searchText.isEmpty) {
      return planets;
    }
    return planets.where((e) {
      var search = searchText.replaceAll(" ", "");
      return e.address.contains(search) || e.name.contains(search);
    }).toList();
  }

  SelectFriendsState copyWith({
    ScreenStatus? status,
    CustomException? exception,
    List<Planet>? planets,
    String? searchText,
  }) {
    return SelectFriendsState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      planets: planets ?? this.planets,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exception,
        planets,
        searchText,
      ];
}
