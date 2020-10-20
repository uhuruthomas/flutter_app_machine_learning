import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io' as Io;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String apikey = '4241cd5ab688957';
  String parsedtext = '';
  bool uploading = false;

  parseText() async {
    //pick the image
    final imagefile = await ImagePicker().getImage(source: ImageSource.camera, maxHeight: 970, maxWidth: 670,);
    //prepare the image
    setState(() {
      uploading == true;
    });
    var bytes = Io.File(imagefile.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);
    print(img64.toString());
    //send to api
    var url = 'https://api.ocr.space/parse/image';
    var payload = {'base64Image' : 'data:image/jpg;base64, ${img64.toString()}'};
    var header = {'apikey': apikey};
    var post = await http.post(url, body: payload, headers:header );
    //get results from api
    var result = jsonDecode(post.body);
    setState(() {
      uploading = false;
      parsedtext = result['ParsedResults'][0]['ParsedText'];
    });
    //print(result['ParsedResults'][0]['ParsedText']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 30.0),
              alignment: Alignment.center,
              child: Text(
                'OCR App',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 15,),
            GestureDetector(
              onTap: ()=> parseText(),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.5,
                height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(20.0),
                    color: Colors.purple,
                  ),
                child: Text('Upload Image', style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 20,
                ),),
              ),
            ),
            SizedBox(height: 10,),
            uploading == false ? Container() : CircularProgressIndicator(),
            SizedBox(height: 70,),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('ParsedText is:', style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                  SizedBox(height: 10,),
                  Text(parsedtext, style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
