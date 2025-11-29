import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/services/bills_services.dart';
import 'package:flutter/material.dart';

class RecentBillsWidget extends StatefulWidget {
  const RecentBillsWidget({super.key});

  @override
  State<RecentBillsWidget> createState() => _RecentBillsWidgetState();
}

class _RecentBillsWidgetState extends State<RecentBillsWidget> {
  final BillsService _billsService = BillsService();
  List<Bill> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentBills();
  }

  Future<void> _loadRecentBills() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final bills = await _billsService.fetchRecentBills(limit: 20); 
      if (mounted) {
        setState(() {
          _bills = bills;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bills: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBillCard(Bill bill) {
    return Card(
      color: secondaryColor.withAlpha(36),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bill.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bill.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                CustomNormalText(
                  text: bill.formattedDate,
                  fontSize: 12,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            CustomNormalText(
              text: bill.displayTitle,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: proffessionalBlack,
            ),
            
            const SizedBox(height: 4),
            
            if (bill.latestAction != null) ...[
              CustomNormalText(
                text: bill.latestAction!,
                fontSize: 12, 
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'enacted':
        return Colors.green;
      case 'passed house':
      case 'passed senate':
        return Colors.blue;
      case 'introduced':
        return Colors.orange;
      default:
        return tertiaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Row(
            children: [
              CustomNormalText(
                text: 'Recently Passed Bills',
                fontSize: 18,
                fontWeight: FontWeight.w400, 
                color: proffessionalBlack.withAlpha(150),
              ),
              const Spacer(), 
              IconButton(
                icon: const Icon(Icons.refresh), 
                onPressed: _loadRecentBills,
                tooltip: 'Refresh bills',
              ),
            ],
          ),
        ),

        _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _bills.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CustomNormalText(
                    text: 'No bills data available',
                    color: secondaryColor,
                  ),
                ),
              )
            : Column(
                children: _bills.map(_buildBillCard).toList(),
              ),
      ],
    );
  }
}