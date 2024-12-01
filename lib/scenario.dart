import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterpractice/providers/Scenario_park_provider.dart';
import 'providers/Scenario_c_provider.dart';
import 'package:provider/provider.dart';
import 'providers/Scenario_Manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'character.dart';

AudioPlayer _audioPlayer = AudioPlayer();


class Scenario extends StatelessWidget {
  final String label;
  final String user_id;
  final String profile_name;

  Scenario({required this.label, required this.user_id, required this.profile_name});

  Future<String> _learnstart(String scenario_id) async {
    final url = Uri.parse("http://20.9.151.223:8080/learn/start");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "scenario_id": scenario_id,
        "user_id": user_id,
        "profile_name": profile_name,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["learning_log_id"].toString(); // 정정: JSON 키 값 "learning_log_id" 확인
    } else {
      throw Exception("Failed to start learning");
    }
  }

  @override
  Widget build(BuildContext context) {
    Character acterWidget = Character(userId: user_id, profile: profile_name);
    if (label == '편의점') {
      return FutureBuilder<String>(
        future: _learnstart('1'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중 상태
            return Scaffold(
              appBar: AppBar(title: Text('로딩 중...')),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // 에러 상태
            return Scaffold(
              appBar: AppBar(title: Text('접속 장애 페이지')),
              body: Center(
                child: Text(
                  '죄송합니다. $label Scenario 이용에 장애가 발생했습니다.\n에러: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            // 정상 상태
            final learning_log_id = snapshot.data!;
            return ChangeNotifierProvider<Scenario_Manager>(
              create: (context) => Sinario_c_provider(learningLogId: learning_log_id, acter: acterWidget),
              child: const Scenario_Canvas(),
            );
          }
        },
      );
    } else {
      return FutureBuilder<String>(
        future: _learnstart('1'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중 상태
            return Scaffold(
              appBar: AppBar(title: Text('로딩 중...')),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // 에러 상태
            return Scaffold(
              appBar: AppBar(title: Text('접속 장애 페이지')),
              body: Center(
                child: Text(
                  '죄송합니다. $label Scenario 이용에 장애가 발생했습니다.\n에러: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            // 정상 상태
            final learning_log_id = snapshot.data!;
            return ChangeNotifierProvider<Scenario_Manager>(
              create: (context) => Scenario_park_provider(learningLogId: learning_log_id, acter: acterWidget),
              child: const Scenario_Canvas(),
            );
          }
        },
      );
    }
  }
}

class Scenario_Canvas extends StatefulWidget {
  const Scenario_Canvas({super.key});

  @override
  State<Scenario_Canvas> createState() => _Scenario_CanvasState();
}

class _Scenario_CanvasState extends State<Scenario_Canvas> {
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth_for_left = MediaQuery.of(context).size.width;
    double screenHeight_for_left = MediaQuery.of(context).size.height;

    double screenWidth_for_right = MediaQuery.of(context).size.width;
    double screenHeight_for_right = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지 추가
          Positioned.fill(
            child: Image.asset(
              "assets/background.jpg", // 배경 이미지 파일 경로
              fit: BoxFit.cover, // 화면에 꽉 차도록 설정
            ),
          ),
          Positioned.fill(
            child: Text(
              Provider.of<Scenario_Manager>(context, listen: false).title,
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),

          // 위의 ListView 콘텐츠 추가
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Consumer<Scenario_Manager>(
                      builder: (context, sinarioProvider, child) {
                        return Container(
                          width: screenWidth_for_left * 0.45,
                          height: screenHeight_for_left * 0.57,
                          //16:11
                          decoration: BoxDecoration(
                            color: Color(0xfff0dff2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green,
                              width: 1,
                            ),
                          ),
                          child: sinarioProvider.leftScreen[sinarioProvider.index],
                        );
                      },
                    ),
                    Consumer<Scenario_Manager>(
                      builder: (context, sinarioProvider, child) {
                        return Container(
                          width: screenWidth_for_right * 0.4,
                          height: screenHeight_for_right * 0.5,
                          decoration: BoxDecoration(
                            color: Color(0xfff0dff2),
                            border: Border.all(
                              color: Colors.green,
                              width: 1,
                            ),
                          ),
                          child: sinarioProvider.rightScreen[sinarioProvider.index],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight_for_right * 0.8),
              Center(
                child: Consumer<Scenario_Manager>(
                    builder: (context, sinarioProvider, child) {
                      return Container(
                        width: screenWidth_for_right * 0.9,
                        height: screenHeight_for_right * 0.18,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.lightGreenAccent,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          sinarioProvider.subtitle, // Scenario_Manager에서 제공하는 텍스트
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
