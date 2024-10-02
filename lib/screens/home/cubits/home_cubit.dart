import 'package:bloc/bloc.dart';
import 'package:projeto_incasa_app/screens/home/cubits/home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  final List<String> _todos = [];
  List<String> get todos => _todos;

  HomeCubit() : super(InitialHomeState());
}
