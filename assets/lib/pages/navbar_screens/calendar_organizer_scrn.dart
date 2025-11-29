import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/bills/bills_display.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/services/bills_services.dart';
import 'package:assets/services/AI_recom_services.dart';

class CalendarOrganizerScrn extends StatefulWidget {
  const CalendarOrganizerScrn({super.key});

  @override
  State<CalendarOrganizerScrn> createState() => _CalendarOrganizerScrnState();
}

class _CalendarOrganizerScrnState extends State<CalendarOrganizerScrn> {
  final BillsService _billsService = BillsService();
  final AIRecommendationService _aiService = AIRecommendationService();
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<Bill>> _billsByDate = {};
  Map<String, String> _billDescriptions = {};
  Map<String, bool> _billLoadingStates = {};
  String? _expandedBillKey; 
  bool _isLoadingBills = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadBillsForCalendar();
  }

  Future<void> _loadBillsForCalendar() async { 
    if (!mounted) return;
    setState(() => _isLoadingBills = true);

    try {
      final bills = await _billsService.fetchRecentBills(limit: 30); 
      
      final Map<DateTime, List<Bill>> groupedBills = {};
      for (final bill in bills) {
        if (bill.date != null) {
          final date = DateTime(bill.date!.year, bill.date!.month, bill.date!.day);
          groupedBills[date] = [...groupedBills[date] ?? [], bill];
        }
      }
      
      if (mounted) {
        setState(() {
          _billsByDate = groupedBills;
          _isLoadingBills = false;
        });
      }
    } catch (e) {
      print('Error loading bills for calendar: $e');
      if (mounted) {
        setState(() => _isLoadingBills = false);
      }
    }
  }

  Future<void> _loadAIDescriptionForBill(Bill bill) async {
    final billKey = '${bill.displayTitle}-${bill.date}';
    
    if (_billLoadingStates[billKey] == true || _billDescriptions[billKey] != null) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _billLoadingStates[billKey] = true;
    });

    try {
      final description = await _generateAIBillDescription(bill);
      
      if (mounted) {
        setState(() {
          _billDescriptions[billKey] = description;
          _billLoadingStates[billKey] = false;
        });
      }
    } catch (e) {
      print('Error generating AI description for bill: $e');
      if (mounted) {
        setState(() {
          _billDescriptions[billKey] = 'Unable to generate description at this time.';
          _billLoadingStates[billKey] = false;
        });
      }
    }
  }

  Future<String> _generateAIBillDescription(Bill bill) async {
    String prompt = """
    Provide a brief, informative description of this legislative bill in 1-2 sentences.
    
    Bill Information:
    - Title: ${bill.displayTitle}
    - Status: ${bill.status}
    ${bill.date != null ? '- Date: ${bill.date}' : ''}
    
    Requirements:
    - Keep it concise and factual
    - Focus on what the bill aims to accomplish
    - Use simple, clear language
    - Maximum 2 sentences
    - No markdown formatting
    
    If you don't have enough information, provide a general description about legislative processes.
    """;

    final response = await _aiService.replyToUser(prompt);
    return response;
  }

  void _toggleBillExpansion(Bill bill) {
    final billKey = '${bill.displayTitle}-${bill.date}';
    
    setState(() {
      if (_expandedBillKey == billKey) {
        _expandedBillKey = null;
      } else {
        _expandedBillKey = billKey;
        if (_billDescriptions[billKey] == null && _billLoadingStates[billKey] != true) {
          _loadAIDescriptionForBill(bill);
        }
      }
    });
  }

  List<Bill> _getBillsForDay(DateTime day) {
    return _billsByDate[DateTime(day.year, day.month, day.day)] ?? []; 
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenSize(context) == 'mobile';
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 600,
              minWidth: 200,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 25 : 10.0),
              child: Card(
                elevation: 0,
                color: primaryColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomNormalText(
                            text: 'Legislative Calendar',
                            fontSize: 18,
                            color: proffessionalBlack.withAlpha(150), 
                            fontWeight: FontWeight.w500,
                          ),
                          const Spacer(),
                          if (_isLoadingBills)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: _loadBillsForCalendar,
                              tooltip: 'Refresh bills',
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TableCalendar(
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _expandedBillKey = null; 
                          });
                        },
                        eventLoader: _getBillsForDay,
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: tertiaryColor,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration( 
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: tertiaryColor,
                            shape: BoxShape.circle,
                          ),
                          markerSize: 6,
                          holidayTextStyle: const TextStyle(color: Colors.red), 
                        ),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        firstDay: DateTime.now().subtract(const Duration(days: 365)), 
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: proffessionalBlack,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: proffessionalBlack.withAlpha(200),
                            fontWeight: FontWeight.w500,
                          ),
                          weekendStyle: TextStyle(
                            color: proffessionalBlack.withAlpha(200),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_selectedDay != null && _getBillsForDay(_selectedDay!).isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomNormalText(
                            text: 'Bills on ${_selectedDay!.month}/${_selectedDay!.day}/${_selectedDay!.year}',
                            fontSize: 16,
                            color: proffessionalBlack.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tertiaryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${_getBillsForDay(_selectedDay!).length} bill${_getBillsForDay(_selectedDay!).length > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: tertiaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._getBillsForDay(_selectedDay!).map((bill) => 
                        _buildBillTile(bill)
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBillTile(Bill bill) {
    final billKey = '${bill.displayTitle}-${bill.date}';
    final isExpanded = _expandedBillKey == billKey;
    final isLoading = _billLoadingStates[billKey] == true;
    final aiDescription = _billDescriptions[billKey];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleBillExpansion(bill),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(bill.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomNormalText(
                          text: bill.displayTitle,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 4),
                        CustomNormalText(
                          text: bill.status,
                          fontSize: 12,
                          color: _getStatusColor(bill.status),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          if (isExpanded) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: tertiaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isLoading
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(tertiaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Generating AI description...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            aiDescription ?? 'Click to generate description',
                            style: TextStyle(
                              fontSize: 12,
                              color: proffessionalBlack.withAlpha(180),
                              height: 1.4,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
}