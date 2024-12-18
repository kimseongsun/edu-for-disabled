import 'package:flutter/material.dart';
import 'package:flutterpractice/scenarios/tts.dart';
import 'package:flutterpractice/scenarios/stt.dart';
import 'package:provider/provider.dart';
import '../../providers/Scenario_Manager.dart';

import 'package:rive/rive.dart' hide Image;
import '../StepData.dart';

final tts = TTS();
final stt = STT();

class Scenario_park_5_left extends StatefulWidget {
  final StatefulWidget acter;

  const Scenario_park_5_left({super.key, required this.acter});

  @override
  State<Scenario_park_5_left> createState() => _Scenario_park_5_leftState();
}

class _Scenario_park_5_leftState extends State<Scenario_park_5_left> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage("assets/park/park_meal.webp"),
              fit: BoxFit.cover, // 이미지가 Container에 꽉 차도록 설정
            ),
          ),
          Positioned.fill(
              child: widget.acter
          ),
        ],
      ),
    );
  }
}

class Scenario_park_5_right extends StatefulWidget {
  final StepData step_data;

  const Scenario_park_5_right({super.key, required this.step_data});

  @override
  State<Scenario_park_5_right> createState() => _Scenario_park_5_rightState();
}

class _Scenario_park_5_rightState extends State<Scenario_park_5_right> {


  SMIBool? _bool1;
  SMIBool? _bool2;

  String answer = '';

  Future<void> _playWelcomeTTS() async {
    await Future.delayed(Duration(milliseconds: 300));
    await Provider.of<Scenario_Manager>(context, listen: false).updateSubtitle(
        "재밌게 놀다보니 배가 고프네요. 밥을 먹어볼까요?\n"
            "그 전에 \"잘 먹겠습니다.\" 라고 직접 소리내어 말해보세요. "
    );
    await tts.TextToSpeech(
        "재밌게 놀다보니 배가 고프네요. 밥을 먹어볼까요?"
            "그 전에 잘 먹겠습니다. 라고 직접 소리내어 말해보세요. ",
        "ko-KR-Wavenet-D");
    await tts.player.onPlayerComplete.first;
  }

  void _onRiveInit(Artboard artboard) async{
    await _playWelcomeTTS();
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
      onStateChange: _onStateChange,
    );

    if (controller != null) {
      artboard.addController(controller);

      _bool1 = controller.findInput<bool>('Boolean 1') as SMIBool?;
      _bool2 = controller.findInput<bool>('Boolean 2') as SMIBool?;

    }
    _bool1?.value = true;

    answer = await stt.gettext(6);
    print("ANSWER: $answer");
  }

  void _onStateChange(String stateMachineName, String stateName) async {

    if (stateName == 'ExitState') {
      await Provider.of<Scenario_Manager>(context, listen: false).updateSubtitle(
          "참 잘했어요. 앞으로는 밥 먹기 전에 먼저 인사를 씩씩하게 해보도록 해요.");
      await tts.TextToSpeech(
          "참 잘했어요. 앞으로는 밥 먹기 전에 먼저 인사를 씩씩하게 해보도록 해요",
          "ko-KR-Wavenet-D");
      await tts.player.onPlayerComplete.first;
      tts.dispose();

      widget.step_data.sendStepData(
          "park 5",
          "(밥을 먹는 상황)밥을 먹기 전 \"잘 먹겠습니다.\" 라고 소리내어 말해보세요",
          "정답: \"잘 먹겠습니다\" ",
          "응답(소리내어 말하기): $answer",
      );
      Provider.of<Scenario_Manager>(context, listen: false).decrement_flag();
      Provider.of<Scenario_Manager>(context, listen: false).updateIndex();
    } else if (stateName == "Timer exit") {
      _bool2?.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(children: [
              RiveAnimation.asset(
                "assets/common/icon_recording.riv",
                fit: BoxFit.contain,
                onInit: _onRiveInit,
              ),
        ]),
      ),
    );
  }
}
