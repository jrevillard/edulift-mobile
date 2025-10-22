/// Email Debugging Helper for Mailpit Integration
///
/// This helper provides detailed debugging utilities to inspect emails
/// in Mailpit during test execution, specifically focusing on email
/// subject analysis for invitation flows.

import 'package:flutter/foundation.dart';
import 'mailpit_helper.dart';

class EmailDebuggingHelper {
  /// Inspect all emails in Mailpit with detailed subject and content analysis
  ///
  /// This method retrieves all emails and provides detailed debugging information
  /// to help identify why certain emails aren't being found by filtering logic.
  static Future<Map<String, dynamic>> inspectAllEmails() async {
    try {
      debugPrint('🔍 EMAIL DEBUG: Starting comprehensive email inspection...');

      final emails = await MailpitHelper.getAllEmails();
      debugPrint('📊 EMAIL DEBUG: Found ${emails.length} total emails in Mailpit');

      if (emails.isEmpty) {
        return {
          'totalEmails': 0,
          'emailsBySubject': <String, List<Map<String, dynamic>>>{},
          'emailsByRecipient': <String, List<Map<String, dynamic>>>{},
          'subjectPatterns': <String>[],
          'debugInfo': 'No emails found in Mailpit',
        };
      }

      // Group emails by subject patterns
      final emailsBySubject = <String, List<Map<String, dynamic>>>{};
      final emailsByRecipient = <String, List<Map<String, dynamic>>>{};
      final subjectPatterns = <String>[];

      for (final email in emails) {
        final emailData = {
          'id': email.id,
          'subject': email.subject,
          'to': email.to,
          'from': email.from,
          'created': email.created,
          'snippet': email.snippet,
        };

        // Group by subject
        emailsBySubject.putIfAbsent(email.subject, () => []).add(emailData);

        // Group by recipient
        for (final recipient in email.to) {
          emailsByRecipient.putIfAbsent(recipient, () => []).add(emailData);
        }

        // Track unique subject patterns
        if (!subjectPatterns.contains(email.subject)) {
          subjectPatterns.add(email.subject);
        }

        debugPrint('📧 EMAIL DEBUG: [${email.id}] Subject: "${email.subject}" | To: ${email.to.join(', ')}');
      }

      debugPrint('📋 EMAIL DEBUG: Unique subject patterns found:');
      for (final pattern in subjectPatterns) {
        debugPrint('  - "$pattern"');
      }

      return {
        'totalEmails': emails.length,
        'emailsBySubject': emailsBySubject,
        'emailsByRecipient': emailsByRecipient,
        'subjectPatterns': subjectPatterns,
        'debugInfo': 'Email inspection completed successfully',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ EMAIL DEBUG: Error during email inspection: $e');
      debugPrint('📋 EMAIL DEBUG: Stack trace: $stackTrace');
      return {
        'totalEmails': 0,
        'emailsBySubject': <String, List<Map<String, dynamic>>>{},
        'emailsByRecipient': <String, List<Map<String, dynamic>>>{},
        'subjectPatterns': <String>[],
        'debugInfo': 'Error during inspection: $e',
      };
    }
  }

  /// Analyze invitation-related emails specifically
  ///
  /// This method filters emails to find those that might be invitations
  /// and analyzes their subjects against common filtering patterns.
  static Future<Map<String, dynamic>> analyzeInvitationEmails() async {
    try {
      debugPrint('🎯 INVITATION DEBUG: Analyzing invitation-specific emails...');

      final emails = await MailpitHelper.getAllEmails();

      // Patterns to test against email subjects
      final subjectPatterns = [
        'Invitation',        // Current filter in getInvitationEmail
        'invitation',        // Lowercase version
        'invite',           // Short form
        'Join',             // Alternative pattern
        'Family',           // Context-specific
        'Admin',            // Role-specific
        'Member',           // Role-specific
      ];

      final invitationCandidates = <Map<String, dynamic>>[];
      final subjectAnalysis = <String, Map<String, dynamic>>{};

      for (final email in emails) {
        final emailData = {
          'id': email.id,
          'subject': email.subject,
          'to': email.to,
          'from': email.from,
          'created': email.created,
          'snippet': email.snippet,
          'matchedPatterns': <String>[],
          'isInvitationCandidate': false,
        };

        // Test each pattern against the subject
        for (final pattern in subjectPatterns) {
          if (email.subject.contains(pattern)) {
            (emailData['matchedPatterns'] as List<String>).add(pattern);
            emailData['isInvitationCandidate'] = true;
          }
        }

        // Check for invitation-like content in snippet
        final snippet = email.snippet.toLowerCase();
        if (snippet.contains('invitation') ||
            snippet.contains('invite') ||
            snippet.contains('join') ||
            snippet.contains('family')) {
          emailData['hasInvitationContent'] = true;
          emailData['isInvitationCandidate'] = true;
        }

        if (emailData['isInvitationCandidate'] == true) {
          invitationCandidates.add(emailData);
        }

        // Analyze subject patterns
        subjectAnalysis[email.subject] = {
          'count': (subjectAnalysis[email.subject]?['count'] ?? 0) + 1,
          'recipients': [...(subjectAnalysis[email.subject]?['recipients'] ?? []), ...email.to],
          'matchedPatterns': emailData['matchedPatterns'],
          'isInvitationCandidate': emailData['isInvitationCandidate'],
        };
      }

      debugPrint('🎯 INVITATION DEBUG: Found ${invitationCandidates.length} invitation candidates');
      for (final candidate in invitationCandidates) {
        debugPrint('  📧 Candidate: "${candidate['subject']}" | Patterns: ${candidate['matchedPatterns']}');
      }

      return {
        'totalEmails': emails.length,
        'invitationCandidates': invitationCandidates,
        'subjectAnalysis': subjectAnalysis,
        'testedPatterns': subjectPatterns,
        'currentFilterPattern': 'Invitation',
        'debugInfo': 'Invitation analysis completed',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ INVITATION DEBUG: Error during invitation analysis: $e');
      debugPrint('📋 INVITATION DEBUG: Stack trace: $stackTrace');
      return {
        'totalEmails': 0,
        'invitationCandidates': [],
        'subjectAnalysis': {},
        'testedPatterns': [],
        'currentFilterPattern': 'Invitation',
        'debugInfo': 'Error during analysis: $e',
      };
    }
  }

  /// Compare member vs admin invitation emails
  ///
  /// This method looks for emails sent to specific recipients and compares
  /// their subjects to identify differences between member and admin invitations.
  static Future<Map<String, dynamic>> compareMemberVsAdminInvitations({
    required String memberEmail,
    required String adminEmail,
  }) async {
    try {
      debugPrint('⚖️ COMPARISON DEBUG: Comparing member vs admin invitations...');
      debugPrint('   Member email: $memberEmail');
      debugPrint('   Admin email: $adminEmail');

      final emails = await MailpitHelper.getAllEmails();

      final memberEmails = emails.where((email) =>
        email.to.any((to) => to.toLowerCase().contains(memberEmail.toLowerCase()))
      ).toList();

      final adminEmails = emails.where((email) =>
        email.to.any((to) => to.toLowerCase().contains(adminEmail.toLowerCase()))
      ).toList();

      debugPrint('📊 COMPARISON DEBUG: Found ${memberEmails.length} emails for member');
      debugPrint('📊 COMPARISON DEBUG: Found ${adminEmails.length} emails for admin');

      final memberData = <Map<String, dynamic>>[];
      final adminData = <Map<String, dynamic>>[];

      // Analyze member emails
      for (final email in memberEmails) {
        final data = {
          'id': email.id,
          'subject': email.subject,
          'to': email.to,
          'created': email.created,
          'snippet': email.snippet,
          'containsInvitation': email.subject.contains('Invitation'),
          'containsInvitationLower': email.subject.toLowerCase().contains('invitation'),
        };
        memberData.add(data);
        debugPrint('👤 MEMBER EMAIL: "${email.subject}" | Contains "Invitation": ${data['containsInvitation']}');
      }

      // Analyze admin emails
      for (final email in adminEmails) {
        final data = {
          'id': email.id,
          'subject': email.subject,
          'to': email.to,
          'created': email.created,
          'snippet': email.snippet,
          'containsInvitation': email.subject.contains('Invitation'),
          'containsInvitationLower': email.subject.toLowerCase().contains('invitation'),
        };
        adminData.add(data);
        debugPrint('👑 ADMIN EMAIL: "${email.subject}" | Contains "Invitation": ${data['containsInvitation']}');
      }

      // Compare patterns
      final memberSubjects = memberData.map((e) => e['subject'] as String).toSet();
      final adminSubjects = adminData.map((e) => e['subject'] as String).toSet();

      final commonSubjects = memberSubjects.intersection(adminSubjects);
      final memberOnlySubjects = memberSubjects.difference(adminSubjects);
      final adminOnlySubjects = adminSubjects.difference(memberSubjects);

      debugPrint('📈 COMPARISON RESULTS:');
      debugPrint('  Common subjects: ${commonSubjects.toList()}');
      debugPrint('  Member-only subjects: ${memberOnlySubjects.toList()}');
      debugPrint('  Admin-only subjects: ${adminOnlySubjects.toList()}');

      return {
        'memberEmails': memberData,
        'adminEmails': adminData,
        'memberSubjects': memberSubjects.toList(),
        'adminSubjects': adminSubjects.toList(),
        'commonSubjects': commonSubjects.toList(),
        'memberOnlySubjects': memberOnlySubjects.toList(),
        'adminOnlySubjects': adminOnlySubjects.toList(),
        'currentFilterPattern': 'Invitation',
        'memberMatchesFilter': memberData.where((e) => e['containsInvitation'] == true).length,
        'adminMatchesFilter': adminData.where((e) => e['containsInvitation'] == true).length,
        'debugInfo': 'Comparison completed',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ COMPARISON DEBUG: Error during comparison: $e');
      debugPrint('📋 COMPARISON DEBUG: Stack trace: $stackTrace');
      return {
        'memberEmails': [],
        'adminEmails': [],
        'memberSubjects': [],
        'adminSubjects': [],
        'commonSubjects': [],
        'memberOnlySubjects': [],
        'adminOnlySubjects': [],
        'currentFilterPattern': 'Invitation',
        'memberMatchesFilter': 0,
        'adminMatchesFilter': 0,
        'debugInfo': 'Error during comparison: $e',
      };
    }
  }

  /// Test different email filtering patterns
  ///
  /// This method tests various patterns against all emails to identify
  /// the most appropriate filter for invitation emails.
  static Future<Map<String, dynamic>> testEmailFilteringPatterns({
    String? specificRecipient,
  }) async {
    try {
      debugPrint('🧪 FILTER TEST: Testing different email filtering patterns...');

      final emails = await MailpitHelper.getAllEmails();

      // Filter by specific recipient if provided
      final testEmails = specificRecipient != null
        ? emails.where((email) =>
            email.to.any((to) => to.toLowerCase().contains(specificRecipient.toLowerCase()))
          ).toList()
        : emails;

      debugPrint('📊 FILTER TEST: Testing against ${testEmails.length} emails');

      // Different filtering patterns to test
      final patterns = <String, bool Function(String subject)>{
        'exact_Invitation': (subject) => subject.contains('Invitation'),
        'lowercase_invitation': (subject) => subject.toLowerCase().contains('invitation'),
        'invite_only': (subject) => subject.toLowerCase().contains('invite'),
        'join_family': (subject) => subject.toLowerCase().contains('join') && subject.toLowerCase().contains('family'),
        'family_only': (subject) => subject.toLowerCase().contains('family'),
        'admin_or_member': (subject) => subject.toLowerCase().contains('admin') || subject.toLowerCase().contains('member'),
        'edulift_family': (subject) => subject.toLowerCase().contains('edulift') && subject.toLowerCase().contains('family'),
      };

      final patternResults = <String, Map<String, dynamic>>{};

      for (final entry in patterns.entries) {
        final patternName = entry.key;
        final patternFunction = entry.value;

        final matchingEmails = <Map<String, dynamic>>[];

        for (final email in testEmails) {
          if (patternFunction(email.subject)) {
            matchingEmails.add({
              'id': email.id,
              'subject': email.subject,
              'to': email.to,
              'created': email.created,
              'snippet': email.snippet,
            });
          }
        }

        patternResults[patternName] = {
          'matchCount': matchingEmails.length,
          'matchingEmails': matchingEmails,
          'matchRate': testEmails.isNotEmpty ? (matchingEmails.length / testEmails.length) : 0.0,
        };

        debugPrint('🧪 PATTERN "$patternName": ${matchingEmails.length}/${testEmails.length} matches');
      }

      // Find the best pattern (highest match count but not 100% to avoid overly broad patterns)
      final sortedPatterns = patternResults.entries.toList()
        ..sort((a, b) => b.value['matchCount'].compareTo(a.value['matchCount']));

      return {
        'totalEmailsTested': testEmails.length,
        'patternResults': patternResults,
        'bestPattern': sortedPatterns.isNotEmpty ? sortedPatterns.first.key : null,
        'currentPattern': 'exact_Invitation',
        'recommendedPattern': _getRecommendedPattern(patternResults),
        'debugInfo': 'Filter pattern testing completed',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ FILTER TEST: Error during pattern testing: $e');
      debugPrint('📋 FILTER TEST: Stack trace: $stackTrace');
      return {
        'totalEmailsTested': 0,
        'patternResults': {},
        'bestPattern': null,
        'currentPattern': 'exact_Invitation',
        'recommendedPattern': null,
        'debugInfo': 'Error during pattern testing: $e',
      };
    }
  }

  /// Get recommended pattern based on results
  static String? _getRecommendedPattern(Map<String, Map<String, dynamic>> patternResults) {
    // Look for patterns that have matches but aren't overly broad
    for (final entry in patternResults.entries) {
      final matchCount = entry.value['matchCount'] as int;
      final matchRate = entry.value['matchRate'] as double;

      // Good patterns: have matches but not too broad (not 100% match rate unless very few emails)
      if (matchCount > 0 && (matchRate < 1.0 || matchCount <= 3)) {
        return entry.key;
      }
    }

    // Fallback to any pattern with matches
    for (final entry in patternResults.entries) {
      if ((entry.value['matchCount'] as int) > 0) {
        return entry.key;
      }
    }

    return null;
  }

  /// Comprehensive email timing analysis
  ///
  /// This method analyzes the timing of email delivery to identify
  /// potential timing issues affecting email filtering.
  static Future<Map<String, dynamic>> analyzeEmailTiming({
    String? memberEmail,
    String? adminEmail,
  }) async {
    try {
      debugPrint('⏰ TIMING DEBUG: Analyzing email delivery timing...');

      final emails = await MailpitHelper.getAllEmails();

      if (emails.isEmpty) {
        return {
          'totalEmails': 0,
          'emailTimeline': [],
          'memberEmailTiming': [],
          'adminEmailTiming': [],
          'debugInfo': 'No emails found for timing analysis',
        };
      }

      // Sort emails by creation time
      final sortedEmails = [...emails]
        ..sort((a, b) => DateTime.parse(a.created).compareTo(DateTime.parse(b.created)));

      final emailTimeline = <Map<String, dynamic>>[];
      final memberEmailTiming = <Map<String, dynamic>>[];
      final adminEmailTiming = <Map<String, dynamic>>[];

      DateTime? firstEmailTime;

      for (final email in sortedEmails) {
        final emailTime = DateTime.parse(email.created);
        firstEmailTime ??= emailTime;

        final timelineEntry = {
          'id': email.id,
          'subject': email.subject,
          'to': email.to,
          'created': email.created,
          'timeFromFirst': emailTime.difference(firstEmailTime).inSeconds,
          'isForMember': memberEmail != null && email.to.any((to) => to.toLowerCase().contains(memberEmail.toLowerCase())),
          'isForAdmin': adminEmail != null && email.to.any((to) => to.toLowerCase().contains(adminEmail.toLowerCase())),
        };

        emailTimeline.add(timelineEntry);

        if (timelineEntry['isForMember'] == true) {
          memberEmailTiming.add(timelineEntry);
        }

        if (timelineEntry['isForAdmin'] == true) {
          adminEmailTiming.add(timelineEntry);
        }

        debugPrint('⏰ EMAIL [+${timelineEntry['timeFromFirst']}s]: "${email.subject}" -> ${email.to.join(', ')}');
      }

      return {
        'totalEmails': emails.length,
        'emailTimeline': emailTimeline,
        'memberEmailTiming': memberEmailTiming,
        'adminEmailTiming': adminEmailTiming,
        'firstEmailTime': firstEmailTime?.toIso8601String(),
        'lastEmailTime': sortedEmails.last.created,
        'totalTimeSpan': DateTime.parse(sortedEmails.last.created).difference(firstEmailTime!).inSeconds,
        'debugInfo': 'Timing analysis completed',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ TIMING DEBUG: Error during timing analysis: $e');
      debugPrint('📋 TIMING DEBUG: Stack trace: $stackTrace');
      return {
        'totalEmails': 0,
        'emailTimeline': [],
        'memberEmailTiming': [],
        'adminEmailTiming': [],
        'debugInfo': 'Error during timing analysis: $e',
      };
    }
  }

  /// Full diagnostic report combining all analysis methods
  ///
  /// This method runs all debugging utilities and provides a comprehensive
  /// report to identify the root cause of email filtering issues.
  static Future<Map<String, dynamic>> generateFullDiagnosticReport({
    String? memberEmail,
    String? adminEmail,
  }) async {
    try {
      debugPrint('🔬 FULL DIAGNOSTIC: Generating comprehensive email analysis report...');

      final results = <String, dynamic>{};

      // Run all analysis methods
      results['emailInspection'] = await inspectAllEmails();
      results['invitationAnalysis'] = await analyzeInvitationEmails();
      results['filterPatternTesting'] = await testEmailFilteringPatterns();
      results['timingAnalysis'] = await analyzeEmailTiming(
        memberEmail: memberEmail,
        adminEmail: adminEmail,
      );

      if (memberEmail != null && adminEmail != null) {
        results['memberVsAdminComparison'] = await compareMemberVsAdminInvitations(
          memberEmail: memberEmail,
          adminEmail: adminEmail,
        );
      }

      // Generate summary and recommendations
      final totalEmails = results['emailInspection']['totalEmails'] as int;
      final invitationCandidates = results['invitationAnalysis']['invitationCandidates'] as List;
      final patternResults = results['filterPatternTesting']['patternResults'] as Map;
      final recommendedPattern = results['filterPatternTesting']['recommendedPattern'] as String?;

      final summary = {
        'totalEmailsFound': totalEmails,
        'invitationCandidatesFound': invitationCandidates.length,
        'currentFilterPattern': 'Invitation',
        'currentFilterMatches': patternResults['exact_Invitation']?['matchCount'] ?? 0,
        'recommendedFilterPattern': recommendedPattern,
        'recommendedFilterMatches': recommendedPattern != null ? (patternResults[recommendedPattern]?['matchCount'] ?? 0) : 0,
        'issueIdentified': _identifyMainIssue(results),
        'recommendations': _generateRecommendations(results),
      };

      results['summary'] = summary;
      results['debugInfo'] = 'Full diagnostic report completed successfully';

      debugPrint('📊 DIAGNOSTIC SUMMARY:');
      debugPrint('  Total emails: ${summary['totalEmailsFound']}');
      debugPrint('  Invitation candidates: ${summary['invitationCandidatesFound']}');
      debugPrint('  Current filter matches: ${summary['currentFilterMatches']}');
      debugPrint('  Recommended pattern: ${summary['recommendedFilterPattern']}');
      debugPrint('  Recommended pattern matches: ${summary['recommendedFilterMatches']}');
      debugPrint('  Main issue: ${summary['issueIdentified']}');

      return results;
    } catch (e, stackTrace) {
      debugPrint('❌ FULL DIAGNOSTIC: Error generating diagnostic report: $e');
      debugPrint('📋 FULL DIAGNOSTIC: Stack trace: $stackTrace');
      return {
        'summary': {
          'totalEmailsFound': 0,
          'invitationCandidatesFound': 0,
          'currentFilterPattern': 'Invitation',
          'currentFilterMatches': 0,
          'recommendedFilterPattern': null,
          'recommendedFilterMatches': 0,
          'issueIdentified': 'Error during analysis',
          'recommendations': ['Fix analysis error and retry'],
        },
        'debugInfo': 'Error during diagnostic report generation: $e',
      };
    }
  }

  /// Identify the main issue based on analysis results
  static String _identifyMainIssue(Map<String, dynamic> results) {
    final totalEmails = results['emailInspection']['totalEmails'] as int;
    final invitationCandidates = results['invitationAnalysis']['invitationCandidates'] as List;
    final currentFilterMatches = results['filterPatternTesting']['patternResults']['exact_Invitation']?['matchCount'] ?? 0;

    if (totalEmails == 0) {
      return 'No emails found in Mailpit - emails may not be sending';
    }

    if (invitationCandidates.isEmpty) {
      return 'No invitation-like emails found - check if invitations are actually being sent';
    }

    if (currentFilterMatches == 0 && invitationCandidates.isNotEmpty) {
      return 'Invitation emails exist but current filter "Invitation" does not match them - filter pattern needs updating';
    }

    if (currentFilterMatches > 0) {
      return 'Filter pattern works but may have timing or specific email issues';
    }

    return 'Unknown issue - requires manual investigation';
  }

  /// Generate recommendations based on analysis results
  static List<String> _generateRecommendations(Map<String, dynamic> results) {
    final recommendations = <String>[];

    final totalEmails = results['emailInspection']['totalEmails'] as int;
    final invitationCandidates = results['invitationAnalysis']['invitationCandidates'] as List;
    final currentFilterMatches = results['filterPatternTesting']['patternResults']['exact_Invitation']?['matchCount'] ?? 0;
    final recommendedPattern = results['filterPatternTesting']['recommendedPattern'] as String?;
    final subjectPatterns = results['emailInspection']['subjectPatterns'] as List;

    if (totalEmails == 0) {
      recommendations.add('Verify email sending configuration in backend');
      recommendations.add('Check Mailpit connectivity and configuration');
      recommendations.add('Ensure test timing allows for email delivery');
    } else if (invitationCandidates.isEmpty) {
      recommendations.add('Verify invitation email templates contain expected keywords');
      recommendations.add('Check if invitation sending logic is working correctly');
      recommendations.add('Review actual email subjects: ${subjectPatterns.take(5).join(', ')}');
    } else if (currentFilterMatches == 0 && invitationCandidates.isNotEmpty) {
      recommendations.add('Update email filter from "Invitation" to "${recommendedPattern ?? 'a more flexible pattern'}"');
      recommendations.add('Consider case-insensitive filtering');
      recommendations.add('Use partial matching instead of exact keyword matching');
    } else {
      recommendations.add('Check email timing - add delays if needed');
      recommendations.add('Verify specific email recipient filtering logic');
      recommendations.add('Consider using more robust email identification methods');
    }

    if (recommendedPattern != null && recommendedPattern != 'exact_Invitation') {
      recommendations.add('Implement filter pattern: $recommendedPattern');
    }

    return recommendations;
  }
}