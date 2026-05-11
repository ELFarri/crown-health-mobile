import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fitness_app/app_theme.dart';
import '../models/tabIcon_data.dart';

class BottomBarView extends StatefulWidget {
  final Function(int) changeIndex;
  final VoidCallback? addClick;
  final List<TabIconData> tabIconsList;

  const BottomBarView({
    Key? key,
    required this.tabIconsList,
    required this.changeIndex,
    this.addClick,
  }) : super(key: key);

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setRemoveAllSelection(TabIconData tabIconData) {
    if (!mounted) return;
    setState(() {
      widget.tabIconsList.forEach((TabIconData tab) {
        tab.isSelected = tab.index == tabIconData.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Main Bottom Bar
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return PhysicalShape(
              color: AppTheme.white,
              elevation: 16,
              clipper: TabClipper(
                radius: Tween<double>(begin: 0, end: 1)
                    .animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.fastOutSlowIn,
                    ))
                    .value * 38.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 62,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: Row(
                        children: [
                          _buildTabIcon(0),
                          _buildTabIcon(1),
                          SizedBox(
                            width: Tween<double>(begin: 0, end: 1)
                                .animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.fastOutSlowIn,
                                ))
                                .value * 64,
                          ),
                          _buildTabIcon(2),
                          _buildTabIcon(3),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        ),
        
        // Floating Add Button
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: SizedBox(
            width: 76,
            height: 100,
            child: Container(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 76,
                height: 76,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.nearlyDarkBlue,
                            const Color(0xFF6A88E5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.nearlyDarkBlue.withOpacity(0.4),
                            offset: const Offset(8, 16),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.1),
                          onTap: widget.addClick,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabIcon(int index) {
    return Expanded(
      child: TabIcons(
        tabIconData: widget.tabIconsList[index],
        removeAllSelect: () {
          setRemoveAllSelection(widget.tabIconsList[index]);
          widget.changeIndex(index);
        },
      ),
    );
  }
}

class TabIcons extends StatefulWidget {
  final TabIconData tabIconData;
  final VoidCallback removeAllSelect;

  const TabIcons({
    Key? key,
    required this.tabIconData,
    required this.removeAllSelect,
  }) : super(key: key);

  @override
  _TabIconsState createState() => _TabIconsState();
}

class _TabIconsState extends State<TabIcons> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.tabIconData.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          widget.removeAllSelect();
          widget.tabIconData.animationController!.reverse();
        }
      });
  }

  @override
  void dispose() {
    widget.tabIconData.animationController?.dispose();
    super.dispose();
  }

  void setAnimation() {
    widget.tabIconData.animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: InkWell(
          splashColor: Colors.transparent,
          onTap: widget.tabIconData.isSelected ? null : setAnimation,
          child: IgnorePointer(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main Icon
                ScaleTransition(
                  scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                    CurvedAnimation(
                      parent: widget.tabIconData.animationController!,
                      curve: const Interval(0.1, 1.0, curve: Curves.fastOutSlowIn),
                    ),
                  ),
                  child: Image.asset(
                    widget.tabIconData.isSelected
                        ? widget.tabIconData.selectedImage
                        : widget.tabIconData.image,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.home_outlined,
                      size: 24,
                      color: widget.tabIconData.isSelected 
                          ? AppTheme.nearlyDarkBlue 
                          : AppTheme.gray,
                    ),
                  ),
                ),
                
                // Selection Indicators
                if (widget.tabIconData.isSelected) ...[
                  Positioned(
                    top: 4,
                    left: 6,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: widget.tabIconData.animationController!,
                          curve: const Interval(0.2, 1.0, curve: Curves.fastOutSlowIn),
                        ),
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyDarkBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 6,
                    bottom: 8,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: widget.tabIconData.animationController!,
                          curve: const Interval(0.5, 0.8, curve: Curves.fastOutSlowIn),
                        ),
                      ),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyDarkBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 8,
                    bottom: 0,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: widget.tabIconData.animationController!,
                          curve: const Interval(0.5, 0.6, curve: Curves.fastOutSlowIn),
                        ),
                      ),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyDarkBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabClipper extends CustomClipper<Path> {
  final double radius;
  const TabClipper({this.radius = 38});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double v = radius * 2;

    path.lineTo(0, 0);
    path.arcTo(
      Rect.fromLTWH(0, 0, radius, radius),
      math.pi,
      math.pi / 2,
      false,
    );
    path.arcTo(
      Rect.fromLTWH(
        (size.width / 2 - v / 2) - radius + v * 0.04,
        0,
        radius,
        radius,
      ),
      3 * math.pi / 2,
      math.pi * 7 / 18,
      false,
    );
    path.arcTo(
      Rect.fromLTWH(size.width / 2 - v / 2, -v / 2, v, v),
      16 * math.pi / 18,
      -12 * math.pi / 9,
      false,
    );
    path.arcTo(
      Rect.fromLTWH(
        size.width - (size.width / 2 - v / 2) - v * 0.04,
        0,
        radius,
        radius,
      ),
      7 * math.pi / 5,
      math.pi * 7 / 18,
      false,
    );
    path.arcTo(
      Rect.fromLTWH(size.width - radius, 0, radius, radius),
      3 * math.pi / 2,
      math.pi / 2,
      false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TabClipper oldClipper) => true;
}
