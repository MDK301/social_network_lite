import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/search/domain/search_repo.dart';
import 'package:social_network_lite/featured/search/presentation/cubits/search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;

  SearchCubit({required this.searchRepo}) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());
      final users = await searchRepo.searchUsers(query);
      emit(SearchLoaded(users));

    } catch (e) {
      print(e);
      emit(SearchError("Error fetching search results"));
    }
  }
}