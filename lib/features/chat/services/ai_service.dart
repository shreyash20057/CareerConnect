import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/user_model.dart';
import '../../../models/job_model.dart';

/// Calls your Firebase Cloud Function which proxies to Claude API.
/// The Cloud Function holds the API key — never in Flutter code.
class AIService {
  // Replace with your Firebase Cloud Function URL after deployment
  static const String _functionUrl =
      'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/careerAssistant';

  Future<String> chat({
    required String userMessage,
    required List<Map<String, String>> history,
    UserModel? userProfile,
    JobModel? selectedJob,
  }) async {
    try {
      final systemContext = _buildSystemContext(userProfile, selectedJob);

      final response = await http
          .post(
            Uri.parse(_functionUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': userMessage,
              'history': history,
              'systemContext': systemContext,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'I encountered an error. Please try again.';
      } else {
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      return _getFallbackResponse(userMessage);
    }
  }

  String _buildSystemContext(UserModel? user, JobModel? job) {
    final buffer = StringBuffer();
    buffer.writeln('You are CareerConnect AI, a helpful career assistant.');
    buffer.writeln(
        'You help students and job seekers with career guidance, interview prep, skill development, and job search.');

    if (user != null) {
      buffer.writeln('\nUser context:');
      if (user.fullName.isNotEmpty) {
        buffer.writeln('Name: ${user.fullName}');
      }
      if (user.skills.isNotEmpty) {
        buffer.writeln('Skills: ${user.skills.join(', ')}');
      }
      if (user.graduation != null) {
        buffer.writeln(
            'Education: ${user.graduation!.degree} in ${user.graduation!.branch} from ${user.graduation!.college}');
      }
    }

    if (job != null) {
      buffer.writeln('\nCurrently viewing job:');
      buffer.writeln('Title: ${job.title}');
      buffer.writeln('Company: ${job.companyName}');
      buffer.writeln('Required skills: ${job.requiredSkills.join(', ')}');
    }

    buffer.writeln(
        '\nKeep responses concise, practical, and personalized. Use formatting when helpful.');
    return buffer.toString();
  }

  String _getFallbackResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('skill') || q.contains('learn')) {
      return "For your career goals, I'd recommend focusing on high-demand skills like Flutter, Python, cloud platforms (AWS/GCP), and system design. Start with one area, build projects, and contribute to open source. Would you like a specific learning roadmap?";
    }
    if (q.contains('interview')) {
      return "Great question! For tech interviews:\n\n**Technical:**\n• LeetCode (Easy → Medium problems)\n• System design fundamentals\n• Deep dive on your tech stack\n\n**Behavioral:**\n• Prepare STAR-format stories\n• Know your resume cold\n• Research the company well\n\nWant me to create a prep plan for a specific role?";
    }
    if (q.contains('resume')) {
      return "Strong resume tips:\n\n• Lead with impact numbers (e.g. 'improved load time by 40%')\n• One page if <3 years experience\n• Strong action verbs: Built, Optimized, Led, Reduced\n• GitHub link for your best projects\n• Tailor it to each job description\n\nWould you like help with a specific section?";
    }
    if (q.contains('salary') || q.contains('negotiate')) {
      return "Salary negotiation tips:\n\n• Research market rates on LinkedIn, Glassdoor, levels.fyi\n• Never give a number first — ask for their range\n• Always negotiate — 80% of offers have room\n• Consider total comp: equity, benefits, learning opportunities\n• Be confident but collaborative in tone";
    }
    return "I'm your CareerConnect AI assistant! I can help you with:\n\n• **Career guidance** and planning\n• **Interview preparation** strategies  \n• **Skill gap analysis** for specific roles\n• **Resume improvement** tips\n• **Job search** strategies\n\nWhat would you like to work on today?";
  }
}