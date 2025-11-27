import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rfq.dart';
import '../services/rfq_service.dart';

// RFQ Provider
final rfqProvider = StateNotifierProvider<RFQNotifier, RFQState>((ref) {
  return RFQNotifier();
});

// RFQ State
class RFQState {
  final List<RFQ> rfqs;
  final RFQ? selectedRFQ;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? pagination;

  RFQState({
    this.rfqs = const [],
    this.selectedRFQ,
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  RFQState copyWith({
    List<RFQ>? rfqs,
    RFQ? selectedRFQ,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
    bool clearSelectedRFQ = false,
  }) {
    return RFQState(
      rfqs: rfqs ?? this.rfqs,
      selectedRFQ: clearSelectedRFQ ? null : (selectedRFQ ?? this.selectedRFQ),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pagination: pagination ?? this.pagination,
    );
  }
}

// RFQ Notifier
class RFQNotifier extends StateNotifier<RFQState> {
  RFQNotifier() : super(RFQState());

  final RFQService _rfqService = RFQService();

  // Create RFQ
  Future<void> createRFQ({
    required List<String> products,
    required double idealPrice,
    required int quantity,
    required DateTime deliveryDate,
    required String description,
    List<String>? attachments,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final rfq = await _rfqService.createRFQ(
        products: products,
        idealPrice: idealPrice,
        quantity: quantity,
        deliveryDate: deliveryDate,
        description: description,
        attachments: attachments,
      );

      state = state.copyWith(
        rfqs: [rfq, ...state.rfqs],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Get RFQs
  Future<void> getRFQs({
    String? status,
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final result = await _rfqService.getRFQs(
        status: status,
        page: page,
        limit: limit,
      );

      final List<RFQ> rfqs = result['rfqs'];
      final pagination = result['pagination'];

      state = state.copyWith(
        rfqs: loadMore ? [...state.rfqs, ...rfqs] : rfqs,
        isLoading: false,
        pagination: pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Get RFQ by ID
  Future<void> getRFQById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final rfq = await _rfqService.getRFQById(id);

      state = state.copyWith(
        selectedRFQ: rfq,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Submit quote
  Future<void> submitQuote({
    required String rfqId,
    required double price,
    required int deliveryTime,
    required String description,
    required DateTime validUntil,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updatedRFQ = await _rfqService.submitQuote(
        rfqId: rfqId,
        price: price,
        deliveryTime: deliveryTime,
        description: description,
        validUntil: validUntil,
      );

      // Update the RFQ in the list
      final updatedRFQs = state.rfqs.map((rfq) {
        return rfq.id == updatedRFQ.id ? updatedRFQ : rfq;
      }).toList();

      state = state.copyWith(
        rfqs: updatedRFQs,
        selectedRFQ: updatedRFQ,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Accept quote
  Future<void> acceptQuote({
    required String rfqId,
    required String quoteId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updatedRFQ = await _rfqService.acceptQuote(
        rfqId: rfqId,
        quoteId: quoteId,
      );

      // Update the RFQ in the list
      final updatedRFQs = state.rfqs.map((rfq) {
        return rfq.id == updatedRFQ.id ? updatedRFQ : rfq;
      }).toList();

      state = state.copyWith(
        rfqs: updatedRFQs,
        selectedRFQ: updatedRFQ,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update RFQ status
  Future<void> updateRFQStatus({
    required String rfqId,
    required String status,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updatedRFQ = await _rfqService.updateRFQStatus(
        rfqId: rfqId,
        status: status,
      );

      // Update the RFQ in the list
      final updatedRFQs = state.rfqs.map((rfq) {
        return rfq.id == updatedRFQ.id ? updatedRFQ : rfq;
      }).toList();

      state = state.copyWith(
        rfqs: updatedRFQs,
        selectedRFQ: updatedRFQ,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Delete RFQ
  Future<void> deleteRFQ(String rfqId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _rfqService.deleteRFQ(rfqId);

      // Remove the RFQ from the list
      final updatedRFQs = state.rfqs.where((rfq) => rfq.id != rfqId).toList();

      state = state.copyWith(
        rfqs: updatedRFQs,
        isLoading: false,
        clearSelectedRFQ: state.selectedRFQ?.id == rfqId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear selected RFQ
  void clearSelectedRFQ() {
    state = state.copyWith(clearSelectedRFQ: true);
  }
}
