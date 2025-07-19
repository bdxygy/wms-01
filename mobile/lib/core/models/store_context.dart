import 'package:json_annotation/json_annotation.dart';
import 'store.dart';

part 'store_context.g.dart';

@JsonSerializable()
class StoreContext {
  final String? selectedStoreId;
  final Store? selectedStore;
  final List<Store> availableStores;
  final DateTime? lastUpdated;
  final bool isLoading;
  final String? error;

  const StoreContext({
    this.selectedStoreId,
    this.selectedStore,
    this.availableStores = const [],
    this.lastUpdated,
    this.isLoading = false,
    this.error,
  });

  factory StoreContext.fromJson(Map<String, dynamic> json) => _$StoreContextFromJson(json);

  Map<String, dynamic> toJson() => _$StoreContextToJson(this);

  // Factory constructors for common states
  factory StoreContext.initial() {
    return const StoreContext(
      isLoading: false,
      availableStores: [],
    );
  }

  factory StoreContext.loading() {
    return const StoreContext(
      isLoading: true,
      availableStores: [],
    );
  }

  factory StoreContext.error(String errorMessage) {
    return StoreContext(
      isLoading: false,
      error: errorMessage,
      availableStores: const [],
    );
  }

  factory StoreContext.loaded({
    required List<Store> stores,
    Store? selectedStore,
  }) {
    return StoreContext(
      selectedStore: selectedStore,
      selectedStoreId: selectedStore?.id,
      availableStores: stores,
      lastUpdated: DateTime.now(),
      isLoading: false,
    );
  }

  // Helper getters
  bool get hasStoreSelected => selectedStore != null;
  bool get hasAvailableStores => availableStores.isNotEmpty;
  bool get needsStoreSelection => !hasStoreSelected && hasAvailableStores;
  bool get hasError => error != null;
  String? get selectedStoreName => selectedStore?.name;

  // Store selection validation
  bool canSelectStore(String storeId) {
    return availableStores.any((store) => store.id == storeId && store.isActive);
  }

  Store? getStoreById(String storeId) {
    try {
      return availableStores.firstWhere((store) => store.id == storeId);
    } catch (e) {
      return null;
    }
  }

  // Copy with method for state updates
  StoreContext copyWith({
    String? selectedStoreId,
    Store? selectedStore,
    List<Store>? availableStores,
    DateTime? lastUpdated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelectedStore = false,
  }) {
    return StoreContext(
      selectedStoreId: clearSelectedStore ? null : (selectedStoreId ?? this.selectedStoreId),
      selectedStore: clearSelectedStore ? null : (selectedStore ?? this.selectedStore),
      availableStores: availableStores ?? this.availableStores,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // Persistence helpers
  Map<String, dynamic> toPersistedJson() {
    return {
      'selectedStoreId': selectedStoreId,
      'selectedStore': selectedStore?.toJson(),
      'availableStores': availableStores.map((store) => store.toJson()).toList(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory StoreContext.fromPersistedJson(Map<String, dynamic> json) {
    return StoreContext(
      selectedStoreId: json['selectedStoreId'] as String?,
      selectedStore: json['selectedStore'] != null 
          ? Store.fromJson(json['selectedStore'] as Map<String, dynamic>)
          : null,
      availableStores: (json['availableStores'] as List<dynamic>?)
          ?.map((store) => Store.fromJson(store as Map<String, dynamic>))
          .toList() ?? [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      isLoading: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreContext &&
          runtimeType == other.runtimeType &&
          selectedStoreId == other.selectedStoreId &&
          selectedStore == other.selectedStore &&
          availableStores.length == other.availableStores.length &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      selectedStoreId.hashCode ^
      selectedStore.hashCode ^
      availableStores.hashCode ^
      isLoading.hashCode ^
      error.hashCode;

  @override
  String toString() {
    return 'StoreContext{'
        'selectedStoreId: $selectedStoreId, '
        'selectedStore: ${selectedStore?.name}, '
        'availableStores: ${availableStores.length}, '
        'isLoading: $isLoading, '
        'hasError: $hasError'
        '}';
  }
}