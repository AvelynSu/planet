import 'package:flutter/cupertino.dart';
import 'package:planet/test_draw/plant_pot_component.dart';
import 'package:planet/test_draw/test_animal.dart';
import 'package:planet/ui/common/base_scaffold.dart';
import 'package:planet/ui/common/line_text_field.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String nickname = "";

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 180),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlantPotComponent(
              name: nickname,
              size: 150,
            ),
            LinedField(
              hintText: "닉네임을 입력하세요",
              align: TextAlign.center,
              onChange: (text) {
                nickname = text;
                setState(() {});
              },
            ),
            AnimalCharacterComponent(
              name: nickname,
              size: 150,
            ),
          ],
        ),
      ),
    );
  }
}
