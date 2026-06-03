import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class WaterView extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> animation;

  const WaterView({Key? key, required this.animationController, required this.animation}) : super(key: key);

  @override
  _WaterViewState createState() => _WaterViewState();
}

class _WaterViewState extends State<WaterView> {
  int _glasses = 0;
  final int _goal = 8;
  late String _dateKey;
  String? _lastEmail;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    if (_lastEmail != userProvider.email) {
      _lastEmail = userProvider.email;
      _loadGlasses();
    }
  }

  Future<void> _loadGlasses() async {
    final email = _lastEmail ?? '';
    _dateKey = 'water_glasses_${email}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _glasses = prefs.getInt(_dateKey) ?? 0;
      });
    }
  }

  Future<void> _addGlass() async {
    if (_glasses < _goal) {
      setState(() {
        _glasses++;
      });
      final email = _lastEmail ?? '';
      _dateKey = 'water_glasses_${email}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dateKey, _glasses);
    }
  }

  Future<void> _removeGlass() async {
    if (_glasses > 0) {
      setState(() {
        _glasses--;
      });
      final email = _lastEmail ?? '';
      _dateKey = 'water_glasses_${email}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dateKey, _glasses);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - widget.animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Water Animation/Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(Icons.local_drink, color: AppTheme.nearlyDarkBlue, size: 30),
                          CircularProgressIndicator(
                            value: _glasses / _goal,
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.nearlyDarkBlue),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Water Intake',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Goal: $_goal glasses',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppTheme.grey.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(_goal, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Icons.opacity,
                                    size: 14,
                                    color: index < _glasses 
                                        ? AppTheme.nearlyDarkBlue 
                                        : AppTheme.grey.withOpacity(0.2),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add / Remove Buttons Stacked Vertically
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _addGlass,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _removeGlass,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.remove, color: AppTheme.nearlyDarkBlue, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
