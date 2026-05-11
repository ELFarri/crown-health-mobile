import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../app_theme.dart';
import '../../services/nutrition_service.dart';

class FoodSearchScreen extends StatefulWidget {
  final String mealName;

  const FoodSearchScreen({Key? key, required this.mealName}) : super(key: key);

  @override
  _FoodSearchScreenState createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock food database
  final List<Map<String, dynamic>> _allFoods = [
    {'name': 'Greek Yogurt', 'kcal': 150, 'protein': 15, 'carbs': 5, 'fat': 2},
    {'name': 'Chicken Breast (100g)', 'kcal': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6},
    {'name': 'Oatmeal (50g)', 'kcal': 190, 'protein': 7, 'carbs': 33, 'fat': 3},
    {'name': 'Banana', 'kcal': 105, 'protein': 1.3, 'carbs': 27, 'fat': 0.3},
    {'name': 'Avocado (Half)', 'kcal': 160, 'protein': 2, 'carbs': 8, 'fat': 15},
    {'name': 'Egg (Large)', 'kcal': 70, 'protein': 6, 'carbs': 0.6, 'fat': 5},
    {'name': 'Rice (Cooked 150g)', 'kcal': 195, 'protein': 4, 'carbs': 42, 'fat': 0.4},
    {'name': 'Protein Shake', 'kcal': 120, 'protein': 24, 'carbs': 3, 'fat': 1.5},
  ];

  List<Map<String, dynamic>> _filteredFoods = [];
  bool _isLoading = false;

  void _filterFoods(String query) async {
    if (query.length < 3) {
      setState(() => _filteredFoods = []);
      return;
    }

    setState(() => _isLoading = true);
    final results = await NutritionService.searchByName(query);
    setState(() {
      _filteredFoods = results;
      _isLoading = false;
    });
  }

  Future<void> _openScanner() async {
    final String? barcode = await showDialog<String>(
      context: context,
      builder: (context) => _BarcodeScannerDialog(),
    );

    if (barcode != null) {
      setState(() => _isLoading = true);
      final product = await NutritionService.searchByBarcode(barcode);
      setState(() => _isLoading = false);

      if (product != null) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(product['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Text('${product['kcal']} kcal per 100g. Add to ${widget.mealName}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), 
                child: Text('Add'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.nearlyDarkBlue),
              ),
            ],
          ),
        );
        if (confirm == true) {
          Navigator.pop(context, product);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found in database')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add to ${widget.mealName}',
          style: GoogleFonts.outfit(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.nearlyDarkBlue.withOpacity(0.05),
                    offset: Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterFoods,
                decoration: InputDecoration(
                  hintText: 'Search for food or scan barcode...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.nearlyDarkBlue),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner, color: AppTheme.nearlyDarkBlue),
                    onPressed: _openScanner,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          
          // Results
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.nearlyDarkBlue))
                : _filteredFoods.isEmpty && _searchController.text.isNotEmpty
                    ? _buildEmptyState()
                    : _filteredFoods.isEmpty
                        ? _buildQuickHistory()
                        : ListView.builder(
                            padding: EdgeInsets.all(20),
                            itemCount: _filteredFoods.length,
                            itemBuilder: (context, index) {
                              final food = _filteredFoods[index];
                              return _buildFoodItem(food);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'],
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${food['kcal']} kcal • P: ${food['protein']}g • C: ${food['carbs']}g • F: ${food['fat']}g',
                  style: GoogleFonts.outfit(color: AppTheme.grey.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: AppTheme.nearlyDarkBlue),
            onPressed: () {
              Navigator.pop(context, food);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food, size: 60, color: AppTheme.grey.withOpacity(0.2)),
          SizedBox(height: 16),
          Text('No food found', style: GoogleFonts.outfit(color: AppTheme.grey)),
        ],
      ),
    );
  }

  Widget _buildQuickHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            'Frequently Added',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              final food = _allFoods[index];
              return _buildFoodItem(food);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.nearlyDarkBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: Size(double.infinity, 56),
          elevation: 5,
          shadowColor: AppTheme.nearlyDarkBlue.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 20),
            SizedBox(width: 12),
            Text(
              'Back to Journal',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodeScannerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 400,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan Barcode',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      Navigator.pop(context, barcodes.first.rawValue);
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Center the barcode in the frame',
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
