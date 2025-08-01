import 'dart:developer';
import 'member.dart';

class Participant {
  final int participantId;
  String statusType;
  final String teamType;
  final int? holeNumber; // nullable로 변경
  final int groupType;
  final int? sumScore; // nullable로 변경
  final String rank;
  final String? handicapRank;
  final int? handicapScore;
  final Member? member; // member 속성


  Participant({
    required this.participantId,
    required this.statusType,
    required this.teamType,
    this.holeNumber, // nullable이기 때문에 required 제거
    required this.groupType,
    this.sumScore, // nullable이기 때문에 required 제거
    required this.rank,
    this.handicapRank,
    this.handicapScore,
    this.member,
  });

  // copyWith 메서드 추가
  Participant copyWith({
    String? statusType,
    int? sumScore,
    String? rank,
  }) {
    return Participant(
      participantId: participantId,
      statusType: statusType ?? this.statusType, // 기존 상태 유지
      teamType: teamType,
      holeNumber: holeNumber,
      groupType: groupType,
      sumScore: sumScore ?? this.sumScore,
      rank: rank ?? this.rank,
      handicapRank: handicapRank,
      handicapScore: handicapScore,
      member: member,
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    try {
      return Participant(
      participantId: json['participant_id'] ?? 0,
      statusType: json['status_type'] ?? '',
      teamType: json['team_type'] ?? '',
      holeNumber: json['hole_number'],
      groupType: json['group_type'] ?? 0,
      sumScore: json['sum_score'],
      rank: json['rank'] ?? "",
      handicapRank: json['handicap_rank'],
      handicapScore: json['handicap_score'],
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
    );
    } catch (e, stackTrace) {
      log("=== Participant.fromJson 에러 발생 ===");
      log("JSON: $json");
      log("에러: $e");
      log("스택 트레이스: $stackTrace");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'participant_id': participantId,
      'status_type': statusType,
      'team_type': teamType,
      'hole_number': holeNumber, // nullable이므로 null이 아닐 때만 포함
      'group_type': groupType,
      'sum_score': sumScore, // nullable이므로 null이 아닐 때만 포함
      'rank': rank,
      'handicap_rank': handicapRank,
      'handicap_score': handicapScore,
    };
  }
}

