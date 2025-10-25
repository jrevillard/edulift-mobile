import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item_dto.freezed.dart';
part 'activity_item_dto.g.dart';

@freezed
abstract class ActivityItemDto with _$ActivityItemDto {
  const factory ActivityItemDto({
    required String id,
    required String
        type, // 'schedule_created', 'child_added', 'vehicle_assigned', etc.
    required String description,
    required String timestamp,
    required String? userId,
    required String? userName,
    Map<String, dynamic>? metadata,
  }) = _ActivityItemDto;

  factory ActivityItemDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemDtoFromJson(json);
}
