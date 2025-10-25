// EduLift Mobile - Mailpit Integration Helper for E2E Tests
// Helper class to interact with Mailpit API for email validation in E2E tests

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:edulift/core/config/environment_config.dart';

/// Helper class to interact with Mailpit for E2E email testing
class MailpitHelper {
  static String get _baseUrl => EnvironmentConfig.getConfig().mailpitApiUrl;

  /// Retrieve all emails from Mailpit
  static Future<List<MailpitMessage>> getAllEmails() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/messages'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = data['messages'] as List?;

        if (messages != null) {
          return messages.map((msg) => MailpitMessage.fromJson(msg)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error retrieving emails from Mailpit: $e');
      return [];
    }
  }

  /// Get full message content by ID
  static Future<MailpitFullMessage?> getMessageById(String messageId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/message/$messageId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MailpitFullMessage.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving message content from Mailpit: $e');
      return null;
    }
  }

  /// Find the latest magic link email for a specific recipient
  static Future<MailpitMessage?> findLatestMagicLinkEmail(
    String recipientEmail,
  ) async {
    final emails = await getAllEmails();

    return emails
        .where(
          (email) =>
              email.to.any((to) => to.contains(recipientEmail)) &&
              email.subject.contains('Magic Link'),
        )
        .fold<MailpitMessage?>(null, (latest, current) {
          if (latest == null) return current;
          return DateTime.parse(
                current.created,
              ).isAfter(DateTime.parse(latest.created))
              ? current
              : latest;
        });
  }

  /// Extract magic link token from email content
  static String? extractMagicLinkToken(MailpitFullMessage email) {
    // Try HTML content first, then fallback to text
    final content = email.html.isNotEmpty ? email.html : email.text;

    // Look for token in various formats
    final patterns = [
      RegExp(r'token=([a-zA-Z0-9\-_]+)'),
      RegExp(r'verify\?.*token=([a-zA-Z0-9\-_]+)'),
      RegExp(r'/auth/verify/([a-zA-Z0-9\-_]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Extract invitation code from email content
  static String? extractInvitationCode(MailpitFullMessage email) {
    // Try HTML content first, then fallback to text
    final content = email.html.isNotEmpty ? email.html : email.text;

    final patterns = [
      RegExp(r'inviteCode=([A-Z0-9_]+)'),
      RegExp(r'invitation.*code.*([A-Z0-9_]{6,})'),
      RegExp(r'code:\s*([A-Z0-9_]{6,})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Clear emails for a specific recipient (safe for parallel test execution)
  static Future<int> clearEmailsForRecipient(String recipientEmail) async {
    try {
      final emails = await getAllEmails();
      final emailsToDelete = emails
          .where(
            (email) => email.to.any(
              (to) => to.toLowerCase().contains(recipientEmail.toLowerCase()),
            ),
          )
          .toList();

      var deletedCount = 0;
      for (final email in emailsToDelete) {
        try {
          final response = await http.delete(
            Uri.parse('$_baseUrl/message/${email.id}'),
          );
          if (response.statusCode == 200) deletedCount++;
        } catch (e) {
          debugPrint('Error deleting email ${email.id}: $e');
        }
      }

      return deletedCount;
    } catch (e) {
      debugPrint('Error clearing emails for recipient $recipientEmail: $e');
      return 0;
    }
  }

  /// Wait for an email to arrive with retry logic
  static Future<MailpitMessage?> waitForEmailWithRetry(
    String recipientEmail, {
    Duration timeout = const Duration(seconds: 30),
    Duration retryInterval = const Duration(seconds: 2),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final email = await findLatestMagicLinkEmail(recipientEmail);
      if (email != null) {
        return email;
      }

      await Future.delayed(retryInterval);
    }

    return null;
  }
}

/// Data class representing a Mailpit message summary (from /api/v1/messages)
class MailpitMessage {
  final String id;
  final String messageId;
  final List<String> to;
  final List<String> cc;
  final List<String> bcc;
  final String from;
  final String subject;
  final String created;
  final String snippet;
  final bool read;
  final List<String> tags;
  final int attachments;

  MailpitMessage({
    required this.id,
    required this.messageId,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.from,
    required this.subject,
    required this.created,
    required this.snippet,
    required this.read,
    required this.tags,
    required this.attachments,
  });

  factory MailpitMessage.fromJson(Map<String, dynamic> json) {
    // Extract email addresses from Address objects
    List<String> extractAddresses(dynamic addressData) {
      if (addressData == null) return [];

      if (addressData is List) {
        return addressData
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['Address']?.toString() ?? '';
              }
              return item.toString();
            })
            .where((email) => email.isNotEmpty)
            .cast<String>()
            .toList();
      }

      return [];
    }

    // Extract From address
    String extractFromAddress(dynamic fromData) {
      if (fromData == null) return '';
      if (fromData is Map<String, dynamic>) {
        return fromData['Address']?.toString() ?? '';
      }
      return fromData.toString();
    }

    return MailpitMessage(
      id: json['ID']?.toString() ?? '',
      messageId: json['MessageID']?.toString() ?? '',
      to: extractAddresses(json['To']),
      cc: extractAddresses(json['Cc']),
      bcc: extractAddresses(json['Bcc']),
      from: extractFromAddress(json['From']),
      subject: json['Subject']?.toString() ?? '',
      created: json['Created']?.toString() ?? DateTime.now().toIso8601String(),
      snippet: json['Snippet']?.toString() ?? '',
      read: json['Read'] == true,
      tags: (json['Tags'] as List?)?.cast<String>() ?? [],
      attachments: json['Attachments']?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'MailpitMessage(id: $id, to: ${to.join(', ')}, from: $from, subject: $subject, created: $created)';
  }
}

/// Data class representing a full Mailpit message (from /api/v1/message/{id})
class MailpitFullMessage {
  final String id;
  final String messageId;
  final List<String> to;
  final List<String> cc;
  final List<String> bcc;
  final String from;
  final String subject;
  final String created;
  final String html;
  final String text;
  final bool read;
  final List<String> tags;
  final int attachments;

  MailpitFullMessage({
    required this.id,
    required this.messageId,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.from,
    required this.subject,
    required this.created,
    required this.html,
    required this.text,
    required this.read,
    required this.tags,
    required this.attachments,
  });

  factory MailpitFullMessage.fromJson(Map<String, dynamic> json) {
    // Extract email addresses from Address objects
    List<String> extractAddresses(dynamic addressData) {
      if (addressData == null) return [];

      if (addressData is List) {
        return addressData
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['Address']?.toString() ?? '';
              }
              return item.toString();
            })
            .where((email) => email.isNotEmpty)
            .cast<String>()
            .toList();
      }

      return [];
    }

    // Extract From address
    String extractFromAddress(dynamic fromData) {
      if (fromData == null) return '';
      if (fromData is Map<String, dynamic>) {
        return fromData['Address']?.toString() ?? '';
      }
      return fromData.toString();
    }

    return MailpitFullMessage(
      id: json['ID']?.toString() ?? '',
      messageId: json['MessageID']?.toString() ?? '',
      to: extractAddresses(json['To']),
      cc: extractAddresses(json['Cc']),
      bcc: extractAddresses(json['Bcc']),
      from: extractFromAddress(json['From']),
      subject: json['Subject']?.toString() ?? '',
      created: json['Created']?.toString() ?? DateTime.now().toIso8601String(),
      html: json['HTML']?.toString() ?? '',
      text: json['Text']?.toString() ?? '',
      read: json['Read'] == true,
      tags: (json['Tags'] as List?)?.cast<String>() ?? [],
      attachments: json['Attachments']?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'MailpitFullMessage(id: $id, to: ${to.join(', ')}, from: $from, subject: $subject, created: $created)';
  }
}
