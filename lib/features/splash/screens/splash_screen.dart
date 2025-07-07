import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _rotationController;
  late Animation<double> logoScaleAnimation;
  late Animation<double> logoOpacityAnimation;
  late Animation<double> textSlideAnimation;
  late Animation<double> textOpacityAnimation;
  late Animation<double> rotationAnimation;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startAnimations();
    _navigateToOnboarding();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Logo animations
    logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeIn,
    ));

    // Text animations
    textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutBack,
    ));

    textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeIn,
    ));

    // Rotation animation
    rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  void _startAnimations() {
    // Start logo animation immediately
    _logoAnimationController.forward();
    
    // Start text animation after a delay
    Timer(Duration(milliseconds: 800), () {
      _textAnimationController.forward();
    });

    // Start rotation animation and repeat
    Timer(Duration(milliseconds: 1500), () {
      _rotationController.repeat();
    });
  }

  _navigateToOnboarding() {
    Timer(Duration(seconds: 4), () {
      Get.offNamed('/onboarding');
    });
  }

  @override
  void onClose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _rotationController.dispose();
    super.onClose();
  }
}

class SplashScreen extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2A2A2A),
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated RDX Logo
                  AnimatedBuilder(
                    animation: controller.logoScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: controller.logoScaleAnimation.value,
                        child: Opacity(
                          opacity: controller.logoOpacityAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4CAF50).withOpacity(0.2),
                                  Color(0xFF45A049).withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4CAF50).withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: Color(0xFF4CAF50).withOpacity(0.1),
                                  blurRadius: 80,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/rdx_logo.png',
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4CAF50),
                                        Color(0xFF45A049),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF4CAF50).withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'EXCHANGE',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 60),
                  
                  // Animated tagline
                  AnimatedBuilder(
                    animation: controller.textSlideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, controller.textSlideAnimation.value),
                        child: Opacity(
                          opacity: controller.textOpacityAnimation.value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'BUY & SELL',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [
                                            Color(0xFF4CAF50),
                                            Color(0xFF45A049),
                                            Color(0xFF66BB6A),
                                          ],
                                        ).createShader(bounds),
                                        child: Text(
                                          'CRYPTO INSTANTLY',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                    ),
                                  ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  // child: Column(
                                  //   children: [
                                  //     Text(
                                  //       'BUY & SELL',
                                  //       style: TextStyle(
                                  //         fontSize: 22,
                                  //         fontWeight: FontWeight.bold,
                                  //         color: Colors.white,
                                  //         letterSpacing: 1.5,
                                  //       ),
                                  //     ),
                                  //     SizedBox(height: 4),
                                  //     ShaderMask(
                                  //       shaderCallback: (bounds) => LinearGradient(
                                  //         colors: [
                                  //           Color(0xFF4CAF50),
                                  //           Color(0xFF45A049),
                                  //           Color(0xFF66BB6A),
                                  //         ],
                                  //       ).createShader(bounds),
                                  //       child: Text(
                                  //         'CRYPTO INSTANTLY',
                                  //         style: TextStyle(
                                  //           fontSize: 22,
                                  //           fontWeight: FontWeight.bold,
                                  //           color: Colors.white,
                                  //           letterSpacing: 1.5,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Secure • Fast • Reliable',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 80),
                  
                  // Enhanced loading indicator
                  AnimatedBuilder(
                    animation: controller.rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: controller.rotationAnimation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF4CAF50),
                                Color(0xFF45A049),
                                Colors.transparent,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.5, 0.5, 1.0],
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Loading text
                  AnimatedBuilder(
                    animation: controller._rotationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.5 + 0.5 * math.sin(controller._rotationController.value * 2 * math.pi),
                        child: Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = 2.0 + random.nextDouble() * 4.0;
    final left = random.nextDouble() * 400;
    final top = random.nextDouble() * 800;
    final duration = 3 + random.nextInt(4);
    
    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder(
        duration: Duration(seconds: duration),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(value * 2 * math.pi) * 20,
              -value * 100,
            ),
            child: Opacity(
              opacity: (1 - value) * 0.6,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4CAF50).withOpacity(0.8),
                      Color(0xFF45A049).withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        onEnd: () {
          // Restart animation
          Future.delayed(Duration(milliseconds: random.nextInt(2000)), () {
            if (controller._rotationController.isAnimating) {
              // Trigger rebuild to restart animation
            }
          });
        },
      ),
    );
  }
}