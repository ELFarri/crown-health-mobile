import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../widgets/title_view.dart';
import '../widgets/water_view.dart';
import '../widgets/mediterranean_diet_view.dart';
import '../widgets/meals_list_view.dart';
import '../screens/nutrition/food_search_screen.dart';

class MyDiaryScreen extends StatefulWidget {
  final AnimationController? animationController;
  const MyDiaryScreen({Key? key, this.animationController}) : super(key: key);

  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen> {
  List<Widget> _listViews = [];
  double _topBarOpacity = 0.0;
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _addAllListData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset >= 24) {
      if (_topBarOpacity != 1.0) setState(() => _topBarOpacity = 1.0);
    } else if (_scrollController.offset <= 24 && _scrollController.offset >= 0) {
      if (_topBarOpacity != _scrollController.offset / 24)
        setState(() => _topBarOpacity = _scrollController.offset / 24);
    } else if (_scrollController.offset <= 0) {
      if (_topBarOpacity != 0.0) setState(() => _topBarOpacity = 0.0);
    }
  }

  void _addAllListData() {
    if (widget.animationController == null) return;

    _listViews.add(
      TitleView(
        titleText: 'Your Summary',
        subText: 'Details',
        animationController: widget.animationController!,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / 9) * 0, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );
    
    _listViews.add(
      MediterraneanDietView(
        animationController: widget.animationController!,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / 9) * 1, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        targetCalories: 2000,
      ),
    );

    _listViews.add(
      TitleView(
        titleText: 'Today\'s Meals',
        subText: 'Customize',
        animationController: widget.animationController!,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / 9) * 2, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );

    _listViews.add(
      MealsListView(
        animationController: widget.animationController!,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / 9) * 3, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );

    _listViews.add(
      WaterView(
        animationController: widget.animationController!,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / 9) * 3, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );
  }

  void _dataPicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) setState(() => _selectedDate = pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Custom AppBar
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(_topBarOpacity),
                boxShadow: [
                  if (_topBarOpacity > 0.1)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05 * _topBarOpacity),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'My Diary',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: _dataPicker,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: AppTheme.nearlyDarkBlue),
                              SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd').format(_selectedDate),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.nearlyDarkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(0, 8, 0, 80),
                itemCount: _listViews.length,
                itemBuilder: (context, index) => _listViews[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
