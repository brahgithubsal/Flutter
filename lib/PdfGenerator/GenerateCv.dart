import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pd;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class CanadianResumePdf {
  static Future<File> generate(
      String fullName,
      String address,
      String phoneNumber,
      String email,
      String profileSummary,
      List<Map<String, String>> workExperience,
      List<String> education,
      List<String> skills,
      File? image,
      ) async {
    final myTheme = pd.ThemeData.withFont(
      base: pd.Font.ttf(await rootBundle.load("fonts/OpenSans-Regular.ttf")),
      bold: pd.Font.ttf(await rootBundle.load("fonts/OpenSans-Bold.ttf")),
      italic: pd.Font.ttf(await rootBundle.load("fonts/OpenSans-Italic.ttf")),
      boldItalic: pd.Font.ttf(await rootBundle.load("fonts/OpenSans-BoldItalic.ttf")),
    );

    final pdf = pd.Document(theme: myTheme);
    pdf.addPage(
      pd.Page(
        build: (context) => pd.Column(
          crossAxisAlignment: pd.CrossAxisAlignment.start,
          children: [
            buildHeader(image, fullName),
            pd.SizedBox(height: 20),
            buildSectionTitle('Contact Information'),
            pd.SizedBox(height: 10),
            buildContactInfo(address, phoneNumber, email),
            pd.SizedBox(height: 20),
            buildSectionTitle('Profile Summary'),
            pd.SizedBox(height: 10),
            buildProfileSummary(profileSummary),
            pd.SizedBox(height: 20),
            buildSectionTitle('Work Experience'),
            pd.SizedBox(height: 10),
            ...workExperience.map((exp) => buildWorkExperience(exp)),
            pd.SizedBox(height: 20),
            buildSectionTitle('Education'),
            pd.SizedBox(height: 10),
            ...education.map((edu) => buildEducation(edu)),
            pd.SizedBox(height: 20),
            buildSectionTitle('Skills'),
            pd.SizedBox(height: 10),
            buildSkills(skills),
          ],
        ),
      ),
    );

    try {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final path = directory!.path;
      final file = File('${path}/${fullName.replaceAll(' ', '_')}.pdf');

      await file.writeAsBytes(await pdf.save());

      if (await file.exists()) {
        print('File saved successfully: $path');
      } else {
        print('File not saved at the expected location.');
      }

      return file;
    } catch (e) {
      print('An error occurred while writing the file: $e');
      throw Exception('Failed to write the file');
    }
  }

  static pd.Widget buildHeader(File? image, String fullName) {
    if (image != null) {
      final imageProvider = pd.MemoryImage(image.readAsBytesSync());
      return pd.Row(
        children: [
          pd.Image(imageProvider, height: 80, width: 80),
          pd.SizedBox(width: 20),
          pd.Text(
            fullName,
            style: pd.TextStyle(fontSize: 24, fontWeight: pd.FontWeight.bold),
          ),
        ],
      );
    } else {
      return pd.Text(
        fullName,
        style: pd.TextStyle(fontSize: 24, fontWeight: pd.FontWeight.bold),
      );
    }
  }


  static pd.Widget buildSectionTitle(String title) => pd.Text(
    title,
    style: pd.TextStyle(fontSize: 18, fontWeight: pd.FontWeight.bold),
  );

  static pd.Widget buildContactInfo(String address, String phoneNumber, String email) => pd.Column(
    crossAxisAlignment: pd.CrossAxisAlignment.start,
    children: [
      pd.Text('Address: $address'),
      pd.SizedBox(height: 5),
      pd.Text('Phone: $phoneNumber'),
      pd.SizedBox(height: 5),
      pd.Text('Email: $email'),
    ],
  );

  static pd.Widget buildProfileSummary(String summary) => pd.Text(
    summary,
    textAlign: pd.TextAlign.justify,
  );

  static pd.Widget buildWorkExperience(Map<String, String> experience) => pd.Column(
    crossAxisAlignment: pd.CrossAxisAlignment.start,
    children: [
      pd.Text(
        experience['position']!,
        style: pd.TextStyle(fontWeight: pd.FontWeight.bold),
      ),
      pd.Text(experience['company']!),
      pd.Text('${experience['startDate']} - ${experience['endDate'] ?? 'Present'}'),
      pd.SizedBox(height: 5),
      pd.Text(experience['description']!),
      pd.SizedBox(height: 10),
    ],
  );

  static pd.Widget buildEducation(String education) => pd.Text(
    education,
    textAlign: pd.TextAlign.justify,
  );

  static pd.Widget buildSkills(List<String> skills) => pd.Column(
    crossAxisAlignment: pd.CrossAxisAlignment.start,
    children: skills.map((skill) => pd.Text('• $skill')).toList(),
  );

  static Future<void> openFile(File file) async {
    try {
      final url = file.path;

      if (!await file.exists()) {
        print('File does not exist');
        return;
      }

      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          await OpenFile.open(url);
        } else if (result.isPermanentlyDenied) {
          openAppSettings(); // Prompt user to manually enable the permission
        } else {
          print('Permission denied to access storage');
        }
      } else {
        await OpenFile.open(url);
      }
    } catch (e) {
      print('An error occurred while opening the file : $e');
      throw Exception('Failed to open the file');
    }
  }
}
