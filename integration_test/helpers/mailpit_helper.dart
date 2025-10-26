// EduLift Mobile E2E - Mailpit Integration Helper
// Helper class to interact with Mailpit API for email validation in E2E tests
// READ-ONLY operations only - no direct API manipulation

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:edulift/core/config/environment_config.dart';

/// Helper class to interact with Mailpit for E2E email testing
///
/// This class provides READ-ONLY access to emails captured by Mailpit
/// during E2E testing. It does NOT make any backend API calls - only
/// reads emails from the Mailpit service.
///
/// Usage:
/// ```dart
/// final magicLink = await MailpitHelper.waitForMagicLink('user@example.com');
/// await $.native.openUrl(magicLink);
/// ```
class MailpitHelper {
  /// Get Mailpit API URL based on current environment configuration
  static String get _mailpitApiUrl {
    // Get configuration from environment (dart-define)
    final config = EnvironmentConfig.getConfig();
    return config.mailpitApiUrl;
  }

  /// Maximum time to wait for an email
  static const Duration _defaultTimeout = Duration(seconds: 30);

  /// Interval between email check attempts
  static const Duration _retryInterval = Duration(seconds: 2);

  /// Retrieve all emails from Mailpit
  ///
  /// Returns a list of all emails currently in Mailpit
  /// [recipientFilter] - optional filter to only return emails sent to a specific recipient
  static Future<List<MailpitMessage>> getAllEmails({
    String? recipientFilter,
  }) async {
    try {
      debugPrint('📧 Fetching all emails from Mailpit at: $_mailpitApiUrl');
      final uri = Uri.parse('$_mailpitApiUrl/messages');
      debugPrint('🌐 Making request to: $uri');

      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      final response = await dio.get(uri.toString());

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📄 Response data length: ${response.data.toString().length}');

      if (response.statusCode == 200) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;
        debugPrint('🔍 Decoded response keys: ${data.keys}');
        final messages = data['messages'] as List?;

        if (messages != null && messages.isNotEmpty) {
          debugPrint('📬 Found ${messages.length} emails in Mailpit');
          final allEmails = messages
              .map((msg) => MailpitMessage.fromJson(msg))
              .toList();

          // Apply recipient filter if specified
          if (recipientFilter != null) {
            final filteredEmails = allEmails
                .where((email) => email.to.contains(recipientFilter))
                .toList();
            debugPrint(
              '🔍 Filtered to ${filteredEmails.length} emails for recipient: $recipientFilter',
            );
            return filteredEmails;
          }

          return allEmails;
        } else {
          debugPrint('📪 Messages array is empty or null');
        }
      } else {
        debugPrint('❌ Mailpit returned status: ${response.statusCode}');
        debugPrint('📄 Error response data: ${response.data}');
      }

      debugPrint('📪 No emails found in Mailpit');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error retrieving emails from Mailpit: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get full message content by ID
  ///
  /// Returns the complete message including HTML/Text content
  static Future<MailpitFullMessage?> getMessageById(String messageId) async {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    final url = '$_mailpitApiUrl/message/$messageId';

    try {
      debugPrint('📧 Fetching message content for ID: $messageId');
      debugPrint('🌐 GET request to: $url');

      final response = await dio.get(url);

      debugPrint('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;

        // Successfully received message data

        return MailpitFullMessage.fromJson(data);
      } else {
        // Log non-200 responses that don't throw an exception
        debugPrint('⚠️ Received non-200 status: ${response.statusCode}');
        debugPrint('⚠️ Response body: ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      debugPrint(
        '❌ DioException retrieving message content for ID: $messageId',
      );
      debugPrint('   Message: ${e.message}');
      debugPrint('   Response Status: ${e.response?.statusCode}');
      debugPrint('   Response Data: ${e.response?.data}');
      return null;
    } catch (e, s) {
      debugPrint(
        '❌ Unhandled Exception retrieving message content for ID: $messageId',
      );
      debugPrint('   Exception: $e');
      debugPrint('   Stack Trace: $s');
      return null;
    }
  }

  /// Find the latest email for a specific recipient
  ///
  /// Searches through all emails and returns the most recent one
  /// sent to the specified email address and optionally matching subject filter
  ///
  /// [recipientEmail] The email address to search for in the 'to' field
  /// [subjectFilter] Optional filter to only include emails with this text in subject
  static Future<MailpitMessage?> findLatestEmailForRecipient(
    String recipientEmail, {
    String? subjectFilter,
  }) async {
    final emails = await getAllEmails();

    debugPrint('🔍 Looking for emails sent to: $recipientEmail');
    debugPrint('🔍 Total emails in Mailpit: ${emails.length}');

    // Debug: Show first few emails
    for (var i = 0; i < emails.length && i < 3; i++) {
      final email = emails[i];
      debugPrint(
        '  📧 [$i] To: ${email.to.join(', ')} | Subject: ${email.subject}',
      );
    }

    // CRITICAL: Exact match ONLY - no fallback to avoid flapping
    var filteredEmails = emails.where((email) {
      for (final to in email.to) {
        if (to.toLowerCase() == recipientEmail.toLowerCase()) {
          debugPrint('✅ Exact match found: $to == $recipientEmail');
          return true;
        }
      }
      return false;
    }).toList();

    // Apply subject filter if provided
    if (subjectFilter != null) {
      debugPrint('🔍 Applying subject filter: "$subjectFilter"');
      filteredEmails = filteredEmails.where((email) {
        final subjectMatches = email.subject.toLowerCase().contains(
          subjectFilter.toLowerCase(),
        );
        debugPrint(
          '🔍 Subject "${email.subject}" contains "$subjectFilter"? $subjectMatches',
        );
        return subjectMatches;
      }).toList();
      debugPrint(
        '🔍 After subject filter: ${filteredEmails.length} emails remain',
      );
    }

    if (filteredEmails.isEmpty) {
      debugPrint('📪 No emails found for: $recipientEmail');
      debugPrint('🔍 Available recipients:');
      for (final email in emails) {
        debugPrint('  - ${email.to.join(', ')}');
      }
      return null;
    }

    // Sort by creation date (newest first), with ID as tiebreaker for stability
    filteredEmails.sort((a, b) {
      final dateComparison = DateTime.parse(
        b.created,
      ).compareTo(DateTime.parse(a.created));
      if (dateComparison != 0) {
        return dateComparison;
      }
      // If dates are identical, use ID for deterministic ordering
      return b.id.compareTo(a.id);
    });

    final latestEmail = filteredEmails.first;
    debugPrint(
      '📮 Found latest email for $recipientEmail: ${latestEmail.subject}',
    );

    return latestEmail;
  }

  /// Get the full message content for the latest email sent to a recipient
  ///
  /// This is a convenience method that combines findLatestEmailForRecipient
  /// and getMessageById to return the complete email with body content
  static Future<MailpitFullMessage?> getLatestEmailFor(
    String recipientEmail, {
    String? subjectFilter,
  }) async {
    final latestMessage = await findLatestEmailForRecipient(
      recipientEmail,
      subjectFilter: subjectFilter,
    );

    if (latestMessage == null) {
      return null;
    }

    return await getMessageById(latestMessage.id);
  }

  /// Extract magic link from email content
  ///
  /// Parses the email body to find magic link URLs
  /// Supports various URL formats used by the application
  static String? extractMagicLink(MailpitFullMessage email) {
    // Try HTML content first, then fallback to text
    final content = email.html.isNotEmpty ? email.html : email.text;

    print(
      '🔗 EXTRACT: Starting magic link extraction from email: ${email.subject}',
    );
    print('🔗 EXTRACT: HTML content length: ${email.html.length}');
    print('🔗 EXTRACT: Text content length: ${email.text.length}');
    print(
      '🔗 EXTRACT: Using ${email.html.isNotEmpty ? 'HTML' : 'TEXT'} content for extraction',
    );

    if (content.isEmpty) {
      print('❌ EXTRACT: Both HTML and text content are empty!');
      return null;
    }

    // Show first 500 chars of content for debugging
    final preview = content.length > 500 ? content.substring(0, 500) : content;
    print('🔗 EXTRACT: Content preview: $preview');

    // Various patterns to match magic links in email content
    final patterns = [
      // Deep link format: edulift://auth/verify?token=...
      RegExp(
        r'edulift://auth/verify\?token=([a-zA-Z0-9\-_]+)(?:&inviteCode=([a-zA-Z0-9\-_]+))?',
      ),
      // HTTP format with token parameter
      RegExp(
        r'https?://[^/]+/auth/verify\?token=([a-zA-Z0-9\-_]+)(?:&inviteCode=([a-zA-Z0-9\-_]+))?',
      ),
      // Direct token extraction (backup)
      RegExp(r'token=([a-zA-Z0-9\-_]+)'),
    ];

    print('🔍 EXTRACT: Testing ${patterns.length} regex patterns...');

    for (var i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      print('🔍 EXTRACT: Testing pattern $i: ${pattern.pattern}');

      final match = pattern.firstMatch(content);
      if (match != null) {
        final fullMatch = match.group(0)!;
        print(
          '✅ EXTRACT: Pattern $i matched! Found: ${fullMatch.substring(0, math.min(50, fullMatch.length))}...',
        );

        // Ensure it's a proper deep link format
        if (fullMatch.startsWith('edulift://')) {
          print('✅ EXTRACT: Returning edulift:// deep link');
          return fullMatch;
        } else if (fullMatch.startsWith('http')) {
          // Convert HTTP link to deep link format
          final uri = Uri.parse(fullMatch);
          final token = uri.queryParameters['token'];
          final inviteCode = uri.queryParameters['inviteCode'];

          if (token != null) {
            var deepLink = 'edulift://auth/verify?token=$token';
            if (inviteCode != null) {
              deepLink += '&inviteCode=$inviteCode';
            }
            print('✅ EXTRACT: Converted HTTP to deep link: $deepLink');
            return deepLink;
          }
        } else {
          // Token only - construct deep link
          final token = match.group(1);
          print('🔍 EXTRACT: Extracted token: $token');
          if (token != null && token.isNotEmpty) {
            final deepLink = 'edulift://auth/verify?token=$token';
            print('✅ EXTRACT: Constructed deep link from token: $deepLink');
            return deepLink;
          } else {
            print('❌ EXTRACT: Token is null or empty: $token');
          }
        }
      } else {
        print('❌ EXTRACT: Pattern $i no match');
        // Debug: Show where the pattern failed
        if (i == 0) {
          print('🔍 EXTRACT: Looking for edulift:// deep link format');
        } else if (i == 1) {
          print('🔍 EXTRACT: Looking for https?:// URL format');
        } else if (i == 2) {
          print('🔍 EXTRACT: Looking for token= pattern');
          // Let's check if content contains "token" at all
          if (content.toLowerCase().contains('token')) {
            print('🔍 EXTRACT: Content DOES contain "token" - regex issue?');
            final tokenIndex = content.toLowerCase().indexOf('token');
            final tokenContext = content.substring(
              (tokenIndex - 20).clamp(0, content.length),
              (tokenIndex + 50).clamp(0, content.length),
            );
            print('🔍 EXTRACT: Token context: "$tokenContext"');
          } else {
            print('🔍 EXTRACT: Content does NOT contain "token"');
          }
        }
      }
    }

    print(
      '❌ EXTRACT: No magic link found in email content after testing all patterns',
    );
    return null;
  }

  /// Extract invitation code from email content
  ///
  /// Parses the email body to find invitation codes
  static String? extractInvitationCode(MailpitFullMessage email) {
    // Try HTML content first, then fallback to text
    final content = email.html.isNotEmpty ? email.html : email.text;

    debugPrint('🎫 Extracting invitation code from email: ${email.subject}');

    final patterns = [
      // URL parameter format
      RegExp(r'inviteCode=([A-Z0-9_]+)'),
      // Text patterns
      RegExp(r'invitation.*code[:\s]*([A-Z0-9_]{6,})'),
      RegExp(r'code[:\s]*([A-Z0-9_]{6,})'),
      RegExp(r'INV_[0-9]+_[A-Z0-9]+'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        final code = match.group(1) ?? match.group(0);
        debugPrint('✅ Extracted invitation code: $code');
        return code;
      }
    }

    debugPrint('❌ No invitation code found in email content');
    return null;
  }

  /// Wait for a magic link email to arrive for a specific recipient
  ///
  /// Polls Mailpit until an email with a magic link is found for the
  /// specified email address, or timeout is reached
  ///
  /// [recipientEmail] The email address to look for
  /// [timeout] Maximum time to wait (default: 30 seconds)
  ///
  /// Returns the magic link URL or null if not found within timeout
  static Future<String?> waitForMagicLink(
    String recipientEmail, {
    Duration timeout = _defaultTimeout,
  }) async {
    print('🚀 MAILPIT: waitForMagicLink() method STARTED for: $recipientEmail');
    final startTime = DateTime.now();

    print('⏳ MAILPIT: Waiting for magic link email for: $recipientEmail');
    print('⏰ MAILPIT: Timeout: ${timeout.inSeconds} seconds');
    print('🌐 MAILPIT: API URL: $_mailpitApiUrl');

    // CRITICAL: Enhanced connectivity test with Android emulator detection
    debugPrint('📱 ANDROID EMULATOR NETWORK DEBUGGING:');
    debugPrint('   • Expected URL: $_mailpitApiUrl');
    debugPrint('   • Should use 10.0.2.2:8031 for emulator');
    debugPrint('   • Host localhost:8031 NOT accessible from emulator');

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(
        seconds: 10,
      ); // Reduced timeout
      dio.options.receiveTimeout = const Duration(seconds: 10);
      final connectivityTest = await dio.get(
        '$_mailpitApiUrl/messages',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      print('🔗 MAILPIT: Connectivity test: ${connectivityTest.statusCode}');

      if (connectivityTest.statusCode != 200) {
        print(
          '⚠️ MAILPIT: Connectivity test returned ${connectivityTest.statusCode}, continuing anyway...',
        );
      } else {
        // Check if Mailpit has any messages at all to verify it's working
        final data = connectivityTest.data is String
            ? json.decode(connectivityTest.data)
            : connectivityTest.data;
        final totalMessages = data['messages']?.length ?? 0;
        print('📊 MAILPIT: Currently has $totalMessages total messages');
        print('✅ MAILPIT: Network connectivity confirmed!');
      }
    } catch (e) {
      print('⚠️ MAILPIT: Connectivity test failed: $e');
      print(
        '⚠️ MAILPIT: Continuing with email lookup anyway (connectivity test is not critical)...',
      );
      // Don't return null here - continue with the email lookup
    }

    // CRITICAL: Add initial delay to allow backend to send email
    print(
      '⏳ MAILPIT: Initial 2-second delay to allow backend to send email...',
    );
    await Future.delayed(const Duration(seconds: 2));

    var attemptCount = 0;
    while (DateTime.now().difference(startTime) < timeout) {
      attemptCount++;
      print('🔍 MAILPIT: Attempt $attemptCount: Looking for email...');

      final email = await findLatestEmailForRecipient(recipientEmail);

      if (email != null) {
        print('✉️ MAILPIT: Found email: ${email.subject} (ID: ${email.id})');
        // Get full message content to extract magic link
        final fullMessage = await getMessageById(email.id);
        if (fullMessage != null) {
          print('📖 MAILPIT: Retrieved full message content');
          print('📄 MAILPIT: HTML content length: ${fullMessage.html.length}');
          print('📄 MAILPIT: Text content length: ${fullMessage.text.length}');

          final magicLink = extractMagicLink(fullMessage);
          if (magicLink != null) {
            print(
              '✅ MAILPIT: Magic link received for $recipientEmail: ${magicLink.substring(0, 50)}...',
            );
            return magicLink;
          } else {
            print('❌ MAILPIT: No magic link found in email content');
            // Debug: Print first 200 chars of email content
            final content = fullMessage.html.isNotEmpty
                ? fullMessage.html
                : fullMessage.text;
            debugPrint(
              '📝 Email content preview: ${content.substring(0, content.length.clamp(0, 200))}...',
            );
          }
        } else {
          debugPrint(
            '❌ Failed to get full message content for ID: ${email.id}',
          );
        }
      } else {
        print('❌ MAILPIT: No email found for recipient: $recipientEmail');
        // Debug: Show all available emails
        final allEmails = await getAllEmails();
        debugPrint('📋 Total emails in Mailpit: ${allEmails.length}');
        for (var i = 0; i < allEmails.length && i < 5; i++) {
          final e = allEmails[i];
          debugPrint(
            '  📧 [$i] To: ${e.to.join(', ')} | Subject: ${e.subject}',
          );
        }
      }

      final elapsed = DateTime.now().difference(startTime).inSeconds;
      print('⏳ MAILPIT: Still waiting for magic link... (${elapsed}s elapsed)');
      print('🔄 MAILPIT: Will retry in ${_retryInterval.inSeconds}s...');

      // Add periodic connectivity check every 10 seconds
      if (elapsed % 10 == 0 && elapsed > 0) {
        debugPrint('🔍 Periodic connectivity check...');
        try {
          final dio = Dio();
          dio.options.connectTimeout = const Duration(seconds: 5);
          dio.options.receiveTimeout = const Duration(seconds: 5);
          final quickTest = await dio.get('$_mailpitApiUrl/messages');
          debugPrint(
            '✅ Mailpit still accessible (status: ${quickTest.statusCode})',
          );
        } catch (e) {
          debugPrint('⚠️ Mailpit connectivity issue: $e');
        }
      }

      await Future.delayed(_retryInterval);
    }

    print(
      '⏰ MAILPIT: Timeout reached waiting for magic link for: $recipientEmail',
    );
    print('🔍 MAILPIT: Total attempts made: $attemptCount');

    // Final debug: Show all emails one more time
    debugPrint('📋 Final email dump:');
    await debugPrintAllEmails();

    return null;
  }

  /// Wait for any email to arrive for a specific recipient
  ///
  /// [recipientEmail] The email address to look for
  /// [timeout] Maximum time to wait (default: 30 seconds)
  /// [subjectFilter] Optional filter to only include emails with this text in subject
  ///
  /// Returns the email or null if not found within timeout
  static Future<MailpitMessage?> waitForEmail(
    String recipientEmail, {
    Duration timeout = _defaultTimeout,
    String? subjectFilter,
  }) async {
    final startTime = DateTime.now();

    debugPrint(
      '⏳ Waiting for email for: $recipientEmail${subjectFilter != null ? ' with subject containing "$subjectFilter"' : ''}',
    );

    while (DateTime.now().difference(startTime) < timeout) {
      final email = await findLatestEmailForRecipient(
        recipientEmail,
        subjectFilter: subjectFilter,
      );
      if (email != null) {
        debugPrint('✅ Email received for $recipientEmail: ${email.subject}');
        return email;
      }

      await Future.delayed(_retryInterval);
    }

    debugPrint('⏰ Timeout reached waiting for email for: $recipientEmail');
    return null;
  }

  /// Clear emails for a specific recipient (safe for parallel test execution)
  ///
  /// This method only deletes emails sent to the specified recipient,
  /// making it safe to use in parallel test execution as it won't
  /// interfere with other tests using different email addresses.
  ///
  /// [recipientEmail] The email address to clear emails for
  /// [maxAge] Optional maximum age of emails to consider (default: no limit)
  ///
  /// Returns the number of emails deleted
  static Future<int> clearEmailsForRecipient(
    String recipientEmail, {
    Duration? maxAge,
  }) async {
    try {
      debugPrint('🗑️  Clearing emails for recipient: $recipientEmail');

      // Get all emails first
      final emails = await getAllEmails();

      // Filter emails for the specific recipient
      final emailsToDelete = emails.where((email) {
        // Check if email is for the recipient
        final isForRecipient = email.to.any(
          (to) => to.toLowerCase().contains(recipientEmail.toLowerCase()),
        );

        if (!isForRecipient) return false;

        // Check age if specified
        if (maxAge != null) {
          try {
            final emailDate = DateTime.parse(email.created);
            final cutoffDate = DateTime.now().subtract(maxAge);
            return emailDate.isAfter(cutoffDate);
          } catch (e) {
            debugPrint('⚠️ Could not parse email date: ${email.created}');
            return true; // Include if date parsing fails
          }
        }

        return true;
      }).toList();

      if (emailsToDelete.isEmpty) {
        debugPrint('📪 No emails found for recipient: $recipientEmail');
        return 0;
      }

      debugPrint(
        '🗑️  Found ${emailsToDelete.length} emails to delete for $recipientEmail',
      );

      // Delete each email individually
      var deletedCount = 0;
      for (final email in emailsToDelete) {
        try {
          final dio = Dio();
          dio.options.connectTimeout = const Duration(seconds: 10);
          dio.options.receiveTimeout = const Duration(seconds: 10);
          final response = await dio.delete(
            '$_mailpitApiUrl/message/${email.id}',
          );

          if (response.statusCode == 200) {
            deletedCount++;
          } else {
            debugPrint(
              '⚠️ Failed to delete email ${email.id}: ${response.statusCode}',
            );
          }
        } catch (e) {
          debugPrint('⚠️ Error deleting email ${email.id}: $e');
        }
      }

      debugPrint(
        '✅ Successfully deleted $deletedCount emails for $recipientEmail',
      );
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Error clearing emails for recipient $recipientEmail: $e');
      return 0;
    }
  }

  /// Get count of emails in Mailpit (for debugging)
  static Future<int> getEmailCount() async {
    final emails = await getAllEmails();
    final count = emails.length;
    debugPrint('📊 Mailpit contains $count emails');
    return count;
  }

  /// Debug: Print all email subjects (for troubleshooting)
  static Future<void> debugPrintAllEmails() async {
    final emails = await getAllEmails();
    debugPrint('📧 Debug: All emails in Mailpit:');
    for (var i = 0; i < emails.length; i++) {
      final email = emails[i];
      debugPrint(
        '  ${i + 1}. To: ${email.to.join(', ')} | Subject: ${email.subject}',
      );
    }
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
    return 'MailpitMessage(id: $id, to: ${to.join(', ')}, subject: $subject, created: $created)';
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
      attachments: (json['Attachments'] is List)
          ? (json['Attachments'] as List)
                .length // If it's a list, count items
          : (json['Attachments'] as int? ??
                0), // If it's a number, use directly
    );
  }

  @override
  String toString() {
    return 'MailpitFullMessage(id: $id, to: ${to.join(', ')}, subject: $subject, created: $created)';
  }

  /// Check if the email content contains a specific text
  ///
  /// Searches in both HTML and plain text content
  bool containsText(String text) {
    final content = html.isNotEmpty ? html : this.text;
    return content.toLowerCase().contains(text.toLowerCase());
  }
}
