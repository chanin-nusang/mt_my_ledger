import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_event.dart';
import 'package:mt_my_ledger/bloc/transaction_state.dart';
import 'package:mt_my_ledger/repositories/transaction_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc(this._transactionRepository) : super(TransactionInitial()) {
    on<LoadTransactions>((event, emit) {
      try {
        emit(TransactionLoading());
        final transactions = _transactionRepository.getAllTransactions();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<AddTransaction>((event, emit) {
      try {
        _transactionRepository.addTransaction(event.transaction);
        add(LoadTransactions());
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<UpdateTransaction>((event, emit) {
      try {
        _transactionRepository.updateTransaction(event.transaction);
        add(LoadTransactions());
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<DeleteTransaction>((event, emit) {
      try {
        _transactionRepository.deleteTransaction(event.id);
        add(LoadTransactions());
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });
  }
}
