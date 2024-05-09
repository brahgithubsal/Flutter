import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import '../PdfGenerator/GenerateCv.dart'; // Ensure the path matches your project structure
import 'package:wc_form_validators/wc_form_validators.dart';
class CanadianResumeForm extends StatefulWidget {
  final Function(bool) toggleTheme;

  CanadianResumeForm({required this.toggleTheme});

  @override
  _CanadianResumeFormState createState() => _CanadianResumeFormState();
}

class _CanadianResumeFormState extends State<CanadianResumeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? image;
  String fullName = ''.trim();
  String address = ''.trim();
  String phoneNumber = ''.trim();
  String email = ''.trim();
  String profileSummary = ''.trim();
  List<Map<String, String>> workExperience = [];
  List<String> education = [];
  List<String> skills = [];
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addMarker() {
    final marker = Marker(
      markerId: MarkerId("id-1"),
      position: LatLng(45.4215, -75.6972), // Example position
      infoWindow: InfoWindow(
        title: 'Marker',
        snippet: 'A new marker',
      ),
    );

    setState(() {
      markers.add(marker);
    });
  }
  TextEditingController positionController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController skillController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final File pdfFile = await CanadianResumePdf.generate(
          fullName,
          address,
          phoneNumber,
          email,
          profileSummary,
          workExperience,
          education,
          skills,
            image
        );

       CanadianResumePdf.openFile(pdfFile);
        print('-----all done ---');
      } catch (e) {
        print('Failed to generate PDF: $e');
      }
    }
  }


  void _addWorkExperience() {
    setState(() {
      workExperience.add({
        'position': positionController.text,
        'company': companyController.text,
        'startDate': startDateController.text,
        'endDate': endDateController.text,
        'description': descriptionController.text,
      });

      positionController.clear();
      companyController.clear();
      startDateController.clear();
      endDateController.clear();
      descriptionController.clear();
    });
  }

  void _addEducation() {
    setState(() {
      education.add(educationController.text);
      educationController.clear();
    });
  }

  void _addSkill() {
    setState(() {
      skills.add(skillController.text);
      skillController.clear();
    });
  }
  bool _isMapVisible = false;  // State variable to control visibility of the map

  void _toggleMapVisibility() {
    setState(() {
      _isMapVisible = !_isMapVisible;  // Toggle the map visibility
    });
  }

  @override
  Widget build(BuildContext context) {

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilo'),
        actions: [

        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text('Theme'),
                secondary: Icon(
                  Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.yellow : Colors.grey,
                ),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: widget.toggleTheme,
                activeColor: Colors.yellow,
                activeTrackColor: Colors.yellowAccent,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade400,
              ),
              const SizedBox(
                height: 20,
              ),
              ProfileImage(context),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
                onSaved: (value) {
                  fullName = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) {
                  address = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                maxLength: 8,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: Validators.compose([
                  Validators.email('Please enter valid email'),
                  Validators.required('Please enter your email')
                ]),
                autocorrect: false,

                onSaved: (value) {
                  email = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Profile Summary'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a profile summary';
                  }
                  return null;
                },
                onSaved: (value) {
                  profileSummary = value ?? '';
                },
              ),
              // Other input fields for work experience, education, and skills...
              SizedBox(height: 20),
              Text('Work Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: positionController,
                decoration: InputDecoration(labelText: 'Position'),
              ),
              TextFormField(
                controller: companyController,
                decoration: InputDecoration(labelText: 'Company'),
              ),
              Row(
                children: [
                  Expanded(
                    child: DateTimeField(
                      format: DateFormat("yyyy-MM-dd"),
                    /*  validator: (selectedDateTime) {
                        if (selectedDateTime == null) {
                          return ('Please select a start date.');
                        } else {
                          final now = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day);
                          final dateSelected = DateTime(selectedDateTime.year,
                              selectedDateTime.month, selectedDateTime.day);
                          // If the DateTime difference is negative,
                          // this indicates that the selected DateTime is in the past
                          if (dateSelected.compareTo(now) == 0) {
                            AlertDialog(
                              title: Text("Error"),
                              backgroundColor: Colors.red,
                              titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                            return ('Please select a valid start date.');
                          } else if (!selectedDateTime
                              .difference(DateTime.now())
                              .isNegative) {
                            return ('Date selected in the future.');
                          }
                        }
                      },*/
                      controller: startDateController,
                      decoration: InputDecoration(labelText: 'Start Date'),
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        return date;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DateTimeField(
                      format: DateFormat("yyyy-MM-dd"),
                      controller: endDateController,
                      decoration: InputDecoration(labelText: 'End Date'),
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        return date;
                      },
                    ),
                  ),
                ],
              )
,
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null,
              ),
              ElevatedButton(
                onPressed: _addWorkExperience,
                child: Text('Press to add Work Experience'),
              ),

              // Education section
              SizedBox(height: 20),
              Text('Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: educationController,
                decoration: InputDecoration(labelText: 'Education'),
              ),
              ElevatedButton(
                onPressed: _addEducation,
                child: Text('Press to add Education'),
              ),

              // Skills section
              SizedBox(height: 20),
              Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: skillController,
                decoration: InputDecoration(labelText: 'Skill'),
              ),
              ElevatedButton(
                onPressed: _addSkill,
                child: Text('Press to add skills'),
              ),

              SizedBox(height: 20),
              Text('Want to see Localisation of the top 50 IT Companies In Canada',textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              /*ElevatedButton(
                onPressed: _toggleMapVisibility,
                child: Text(_isMapVisible ? 'Hide Map' : 'Show Map'),  // Text changes based on map visibility
              ),*/
              Center(
                child: ElevatedButton(
                  onPressed: _toggleMapVisibility,
                  child: Text(_isMapVisible ? 'Hide Map' : 'Show Map'),
                ),
              ),

              // Conditionally display the map
              if (_isMapVisible)
                Container(
                  height: 300,  // Set the map height
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(43.6476246, -79.3954849),
                      zoom: 10.0,
                    ),
                     markers:
                     {
                              Marker(
                              markerId: MarkerId(
                              'Shopify'),
                              infoWindow: InfoWindow(title: 'Shopify'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                              position: LatLng(43.6476246,-79.3954849),
                              ),
                              Marker(
                              markerId: MarkerId('Top Hat'),
                              infoWindow: InfoWindow(title: 'Top Hat'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                              position: LatLng(43.6700798,-79.3892593),
                              ),
                              Marker(
                              markerId: MarkerId('Kira Systems'),
                              infoWindow: InfoWindow(title: 'Kira Systems'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                              position: LatLng(43.6485557,-79.3892822),
                              ),
                              Marker(
                              markerId: MarkerId('Ritual Technologies'),
                              infoWindow: InfoWindow(title: 'Ritual Technologies'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                              position: LatLng(43.6525269,-79.3819428),
                              ),
                              Marker(
                              markerId: MarkerId('A3Logics'),
                              infoWindow: InfoWindow(title: 'A3Logics'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                              position: LatLng(26.9124336,75.7872709 ),
                              ),
                              Marker(
                              markerId: MarkerId('Datarockets'),
                              infoWindow: InfoWindow(title: '750 Lexington Ave #12-125, New York City'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                              position: LatLng(40.7580277,-73.9855547),
                              ),
                              Marker(
                              markerId: MarkerId('Datarockets'),
                              infoWindow: InfoWindow(title: '80 Queens Wharf Rd #1015, Toronto'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                              position: LatLng(43.6629295,-79.3957348),
                              )
                     },
                  ),
                ),
              SizedBox(height: 20),
              Center(
                  child:ElevatedButton(
                onPressed: _submitForm,
                child: Text('Generate Resume'),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Future pickImage(BuildContext context, ImageSource source) async {
    try {
      final image = await ImagePicker()
          .pickImage(source: source)
          .then((value) => setState(() => this.image = File(value!.path)));
      Navigator.pop(context);
    } on PlatformException catch (e) {
      print('faild to pick image ya looo :$e');
    }
  }

  Future<File> saveImage(String imagePath) async {
    final Directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    image = File('${Directory.path}/$name');
    return File(imagePath).copy(imagePath);
  }

  Widget ProfileImage(BuildContext context) {
    log("************image****************" );
    log(image.toString());
    return Center(
      child: Stack(
        children: <Widget>[
          InkWell(
            onTap: () {
              showModalBottomSheet(
                  context: this.context,
                  builder: ((builder) => bottomSheet(context)));
            },
            child: CircleAvatar(
              radius: 53,
              backgroundImage: image == null
                  ? const AssetImage('img/undraw_Pic_profile_re_7g2h.png')
                  : FileImage(image!) as ImageProvider,
            ),
          ),
          Positioned(
              bottom: -1.0,
              right: 1.0,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: this.context,
                      builder: ((builder) => bottomSheet(context)));
                },
                child: Icon(
                  Icons.camera,
                  color: Colors.black38,
                  size: 35.0,
                ),
              ))
        ],
      ),
    );
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(this.context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text("Choose profile photo",
              style: TextStyle(fontSize: 20)),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return  Colors.blueAccent;
                        }
                        return  Colors.blueAccent;
                      }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)))),
                  onPressed: () {
                    pickImage(context, ImageSource.camera);
                  },
                  icon: Icon(
                    Icons.camera,
                    color:  Colors.white,
                  ),
                  label: Text(
                    "Camera",
                    style: TextStyle(color:  Colors.white),
                  )),
              const SizedBox(
                height: 10,
                width: 10,
              ),
              ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return  Colors.blueAccent;
                        }
                        return  Colors.blueAccent;
                      }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)))),
                  onPressed: () {
                    pickImage(context, ImageSource.gallery);
                  },
                  icon: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Gallerie",
                    style: TextStyle(color:  Colors.white),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
