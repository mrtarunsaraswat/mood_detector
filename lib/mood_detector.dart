import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoodDetectorWebService {
  static const _api_key = 'Replace with own api';
  static const String _baseUrl =
      'https://twinword-emotion-analysis-v1.p.rapidapi.com/analyze/';
  static const Map<String, String> _header = {
    'content-type': 'application/x-www-form-urlencoded',
    'x-rapidapi-host': 'twinword-emotion-analysis-v1.p.rapidapi.com',
    'x-rapidapi-key': _api_key,
    'useQueryString': 'true',
  };

  Future<Mood> post({@required Map<String, String> query}) async {
    final response = await http.post(_baseUrl, headers: _header, body: query);

    if (response.statusCode == 200) {
      print('success' + response.body);
      print(json.decode(response.body));
      return Mood.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load json data');
    }
  }
}

class Mood {
  final String emotions;

  Mood({this.emotions});

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(emotions: json['emotions_detected'][0]);
  }
}

class MoodDetector extends StatefulWidget {
  @override
  _MoodDetectorState createState() => _MoodDetectorState();
}

class _MoodDetectorState extends State<MoodDetector> {
  bool _loading = true;
  final myController = TextEditingController();

  MoodDetectorWebService apiService = MoodDetectorWebService();
  Future<Mood> analysis;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.blueGrey,
          child: Center(
            child: ListView(
              padding: EdgeInsets.only(left: 20, right: 20),
              shrinkWrap: true,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Mood Detector',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 28),
                        ),
                        SizedBox(height: 30),
                        Container(
                          height: 150,
                          child: Image.asset('assets/mood.png'),
                        ),
                        SizedBox(height: 40),
                        Container(
                          child: Center(
                              child: Container(
                                  width: 300,
                                  child: Column(
                                    children: <Widget>[
                                      TextField(
                                        controller: myController,
                                        decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 21,
                                            ),
                                            labelText: 'Enter a search term: '),
                                      ),
                                      SizedBox(height: 30),
                                    ],
                                  ))),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    analysis = apiService.post(
                                        query: {'text': myController.text});
                                  });
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 180,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 17),
                                  decoration: BoxDecoration(
                                      color: Color(0xFF56ab2f),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    'Find Mood',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              FutureBuilder<Mood>(
                                  future: analysis,
                                  builder: (context, snapShot) {
                                    if (snapShot.connectionState ==
                                        ConnectionState.waiting)
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    else if (snapShot.hasError) {
                                      return Center(
                                        child: Text("ERROR: ${snapShot.error}"),
                                      );
                                    }
                                    else if (snapShot.data.emotions.isEmpty) {
                                      return Center(
                                        child: Text("No mood detected"),
                                      );
                                    }
                                    else {
                                      if (snapShot.hasData &&
                                          snapShot.data.emotions.isNotEmpty)
                                        return Text(
                                          'Detected Mood: ' +
                                              snapShot.data.emotions,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 25,
                                          ),
                                        );
                                      else //`snapShot.hasData` can be false if the `snapshot.data` is null
                                        return Center(child: Text("👆",style: TextStyle(fontSize: 20),));
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
