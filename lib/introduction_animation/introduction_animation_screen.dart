import 'package:jinsei/Routers/something.dart';
import 'package:jinsei/introduction_animation/components/digital_prescription_introduction.dart';
import 'package:jinsei/introduction_animation/components/center_next_button.dart';
import 'package:jinsei/introduction_animation/components/medicine_reminder_introduction.dart';
import 'package:jinsei/introduction_animation/components/booking_appointment_introduction.dart';
import 'package:jinsei/introduction_animation/components/jinsei_introduction.dart';
import 'package:jinsei/introduction_animation/components/top_back_skip_view.dart';
import 'package:jinsei/introduction_animation/components/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:jinsei/home.dart';

class IntroductionAnimationScreen extends StatefulWidget {
  const IntroductionAnimationScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionAnimationScreen> createState() =>
      _IntroductionAnimationScreenState();
}

class _IntroductionAnimationScreenState
    extends State<IntroductionAnimationScreen> with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _animationController?.animateTo(0.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F8),
      body: Stack(
        children: [
          JinseiIntroduction(
            animationController: _animationController!,
          ),
          BookingAppointmentIntroduction(
            animationController: _animationController!,
          ),
          DigitalPrescriptionIntroduction(
            animationController: _animationController!,
          ),
          MedicineReminderIntroduction(
            animationController: _animationController!,
          ),
          WelcomeView(
            animationController: _animationController!,
          ),
          TopBackSkipView(
            onBackClick: _onBackClick,
            onSkipClick: _onSkipClick,
            animationController: _animationController!,
          ),
          CenterNextButton(
            animationController: _animationController!,
            onNextClick: _onNextClick,
          ),
        ],
      ),
    );
  }

  void _onSkipClick() {
    _animationController?.animateTo(0.8,
        duration: const Duration(milliseconds: 1200));
  }

  void _onBackClick() {
    if (_animationController!.value >= 0 &&
        _animationController!.value <= 0.2) {
      _animationController?.animateTo(0.0);
    } else if (_animationController!.value > 0.2 &&
        _animationController!.value <= 0.4) {
      _animationController?.animateTo(0.2);
    } else if (_animationController!.value > 0.4 &&
        _animationController!.value <= 0.6) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value > 0.6 &&
        _animationController!.value <= 0.8) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value > 0.8 &&
        _animationController!.value <= 1.0) {
      _animationController?.animateTo(0.8);
    }
  }

  void _onNextClick() {
    if (_animationController!.value >= 0 &&
        _animationController!.value <= 0.2) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value > 0.2 &&
        _animationController!.value <= 0.4) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value > 0.4 &&
        _animationController!.value <= 0.6) {
      _animationController?.animateTo(0.8);
    } else if (_animationController!.value > 0.6 &&
        _animationController!.value <= 0.8) {
      _signUpClick();
    }
  }

  void _signUpClick() {
    Navigator.push(
      context,
      CustomPageRoute(
        builder: (context) => const Home(initialPage: 0),
      ),
    );
  }
}
