import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/financials_provider.dart';
import '../../models/service_model.dart';      // Correct Import
import '../../models/schedule_model.dart';
import '../../models/transaction_model.dart';  // Correct Import
import '../../utils/app_theme.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/animated_list_item.dart';

// Removed the local duplicate definitions of BarberService and Transaction models

class BarberDashboard extends StatefulWidget {
  @override
  _BarberDashboardState createState() => _BarberDashboardState();
}

class _BarberDashboardState extends State<BarberDashboard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isLoading = true;
  bool _isInitialLoad = true;

  // State for the toggles
  bool _isBookingOnline = true;
  bool _isBusyMode = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this)
      ..forward();

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _fetchInitialData();
      _isInitialLoad = false;
    }
  }

  void _fetchInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      Provider.of<ServicesProvider>(context, listen: false).fetchServices(),
      Provider.of<BookingProvider>(context, listen: false).fetchBarberBookings(),
      Provider.of<ScheduleProvider>(context, listen: false).fetchSchedule(),
      Provider.of<FinancialsProvider>(context, listen: false).fetchTransactions(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showAddServiceDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _durationController = TextEditingController();
    final _priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add New Service', style: Theme.of(context).textTheme.headlineMedium),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: _nameController, label: 'Service Name', prefixIcon: Icons.content_cut, validator: (value) => value!.isEmpty ? 'Please enter a name' : null),
                SizedBox(height: 16),
                CustomTextField(controller: _durationController, label: 'Duration (minutes)', prefixIcon: Icons.timer, keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Please enter a duration' : null),
                SizedBox(height: 16),
                CustomTextField(controller: _priceController, label: 'Price (\$)', prefixIcon: Icons.attach_money, keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Please enter a price' : null),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondaryColor)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Add Service'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newService = BarberService(
                  name: _nameController.text,
                  duration: int.parse(_durationController.text),
                  price: double.parse(_priceController.text),
                );
                Provider.of<ServicesProvider>(context, listen: false).addService(newService);
                Navigator.of(ctx).pop();
              }
            },
          )
        ],
      ),
    );
  }

  void _showEditScheduleDialog(String day, DaySchedule currentSchedule) {
    final _formKey = GlobalKey<FormState>();
    final _startTimeController = TextEditingController(text: currentSchedule.startTime);
    final _endTimeController = TextEditingController(text: currentSchedule.endTime);
    bool _isDayOff = currentSchedule.isDayOff;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Edit $day Schedule', style: Theme.of(context).textTheme.headlineMedium),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: Text("Day Off", style: Theme.of(context).textTheme.bodyLarge),
                        value: _isDayOff,
                        onChanged: (val) {
                          setDialogState(() {
                            _isDayOff = val;
                          });
                        },
                        activeColor: AppTheme.accentColor,
                      ),
                      SizedBox(height: 16),
                      if (!_isDayOff) ...[
                        CustomTextField(controller: _startTimeController, label: 'Start Time (e.g., 09:00)', prefixIcon: Icons.timer_outlined, validator: (value) => value!.isEmpty ? 'Cannot be empty' : null),
                        SizedBox(height: 16),
                        CustomTextField(controller: _endTimeController, label: 'End Time (e.g., 17:00)', prefixIcon: Icons.timer_off_outlined, validator: (value) => value!.isEmpty ? 'Cannot be empty' : null),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondaryColor)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  child: Text('Save Changes'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newSchedule = DaySchedule(
                        startTime: _isDayOff ? '' : _startTimeController.text,
                        endTime: _isDayOff ? '' : _endTimeController.text,
                        isDayOff: _isDayOff,
                      );
                      Provider.of<ScheduleProvider>(context, listen: false).updateDaySchedule(day, newSchedule);
                      Navigator.of(ctx).pop();
                    }
                  },
                )
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: [
                    _buildDashboardTab(),
                    _buildScheduleTab(),
                    _buildServicesTab(),
                    _buildFinancialsTab(),
                    _buildProfileTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, auth, child) => Text(
                    'Welcome, ${auth.currentUser?.name ?? "Barber"}!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Here is your summary.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              ],
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: AppTheme.textSecondaryColor, size: 28),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryColor, width: 1.5)
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOperationalControls(),
            const SizedBox(height: 24),
            _buildAddWalkInButton(),
            const SizedBox(height: 24),
            Text("Today's Appointments", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildTodaysAppointmentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildToggleRow(
              title: 'Online Booking',
              value: _isBookingOnline,
              onChanged: (val) => setState(() => _isBookingOnline = val),
              activeColor: Colors.green,
            ),
            Divider(color: AppTheme.primaryColor),
            _buildToggleRow(
              title: 'Busy Mode',
              subtitle: 'Temporarily block new bookings',
              value: _isBusyMode,
              onChanged: (val) => setState(() => _isBusyMode = val),
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor
  }) {
    return SwitchListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: subtitle != null ? Text(subtitle, style: Theme.of(context).textTheme.bodyMedium) : null,
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      inactiveThumbColor: AppTheme.textSecondaryColor,
      inactiveTrackColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAddWalkInButton() {
    return AnimatedButton(
      onPressed: () {
        // TODO: Implement Add Walk-in flow
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.accentColor, Colors.pinkAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              )
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, color: AppTheme.textColor),
            SizedBox(width: 12),
            Text(
              'Add Walk-in Appointment',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysAppointmentsList() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(Duration(days: 1));

        final todaysBookings = bookingProvider.myBarberBookings.where((booking) {
          return booking.appointmentTime.isAfter(todayStart) && booking.appointmentTime.isBefore(todayEnd);
        }).toList();

        if (todaysBookings.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text("You have no appointments today.", style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: todaysBookings.length,
            itemBuilder: (context, index) {
              final booking = todaysBookings[index];
              bool isCompleted = booking.status == 'completed';
              return AnimatedListItem(
                index: index,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isCompleted ? AppTheme.surfaceColor.withOpacity(0.5) : AppTheme.surfaceColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_filled, color: AppTheme.accentColor, size: 18),
                            SizedBox(width: 8),
                            Text(
                              DateFormat.jm().format(booking.appointmentTime),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accentColor),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(booking.customerName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                                  Text(booking.serviceNames.join(', '), style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis,),
                                ],
                              ),
                            )
                          ],
                        ),
                        Divider(height: 24, color: AppTheme.primaryColor),
                        if (!isCompleted)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(icon: Icons.check_circle, label: 'Check-in', color: Colors.green, onPressed: () {
                                Provider.of<BookingProvider>(context, listen: false).updateBookingStatus(booking.id, 'confirmed');
                              }),
                              _buildActionButton(icon: Icons.cancel, label: 'No-Show', color: Colors.orange, onPressed: () {
                                Provider.of<BookingProvider>(context, listen: false).updateBookingStatus(booking.id, 'canceled');
                              }),
                              _buildActionButton(icon: Icons.done_all, label: 'Complete', color: AppTheme.accentColor, onPressed: () {
                                Provider.of<BookingProvider>(context, listen: false).updateBookingStatus(booking.id, 'completed');
                              }),
                            ],
                          )
                        else
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.accentColor),
                                SizedBox(width: 8),
                                Text('Completed', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return TextButton.icon(
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildScheduleTab() {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        if (scheduleProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Schedule', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                child: AnimationLimiter(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: weekDays.length,
                    itemBuilder: (context, index) {
                      final day = weekDays[index];
                      final daySchedule = scheduleProvider.schedule[day] ?? DaySchedule(startTime: '09:00', endTime: '17:00');
                      final hours = daySchedule.isDayOff ? 'Closed' : '${daySchedule.startTime} - ${daySchedule.endTime}';

                      return AnimatedListItem(
                        index: index,
                        child: ListTile(
                          title: Text(day, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              hours,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: hours == 'Closed' ? Colors.orange : AppTheme.textSecondaryColor
                              )
                          ),
                          trailing: Icon(Icons.edit, color: AppTheme.accentColor, size: 20),
                          onTap: () => _showEditScheduleDialog(day, daySchedule),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: AppTheme.primaryColor,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return Consumer<ServicesProvider>(
      builder: (context, servicesProvider, child) {
        if (_isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Manage Services', style: Theme.of(context).textTheme.headlineSmall),
                  AnimatedButton(
                    onPressed: () => _showAddServiceDialog(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: AppTheme.textColor, size: 20),
                          SizedBox(width: 8),
                          Text("Add New", style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              if (servicesProvider.myServices.isEmpty)
                Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No services found. Tap "Add New" to get started.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                )
              else
                AnimationLimiter(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: servicesProvider.myServices.length,
                    itemBuilder: (context, index) {
                      final service = servicesProvider.myServices[index];
                      return AnimatedListItem(
                        index: index,
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                              child: Icon(Icons.content_cut, color: AppTheme.accentColor),
                            ),
                            title: Text(service.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('${service.duration} min • \$${service.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
                            trailing: TextButton(
                              onPressed: () {
                                // TODO: Implement Edit Service Dialog/Screen
                              },
                              child: Text('Edit', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialsTab() {
    return Consumer<FinancialsProvider>(
        builder: (context, financialsProvider, child) {
          if (financialsProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Financial Overview', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                _buildFinancialSummaryCard(
                    financialsProvider.totalEarnings,
                    financialsProvider.totalSpendings,
                    financialsProvider.netProfit
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
                    TextButton(
                      onPressed: () {},
                      child: Text('View All', style: TextStyle(color: AppTheme.accentColor)),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _buildTransactionsList(financialsProvider.transactions),
              ],
            ),
          );
        }
    );
  }

  Widget _buildFinancialSummaryCard(double earnings, double spendings, double profit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFinancialMetric('Earnings', '\$${earnings.toStringAsFixed(2)}', Colors.green),
                _buildFinancialMetric('Spendings', '\$${spendings.toStringAsFixed(2)}', Colors.orange),
                _buildFinancialMetric('Net Profit', '\$${profit.toStringAsFixed(2)}', AppTheme.accentColor),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 100,
              decoration: BoxDecoration(
                  color: AppTheme.backgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentColor.withOpacity(0.1))
              ),
              child: Center(
                child: Text('Profit Chart Placeholder', style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialMetric(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(child: Text("No transactions found.", style: Theme.of(context).textTheme.bodyLarge)),
        ),
      );
    }
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final color = transaction.isExpense ? Colors.orange : Colors.green;
          final icon = transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward;
          return AnimatedListItem(
            index: index,
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color, size: 20),
                ),
                title: Text(transaction.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(transaction.category, style: Theme.of(context).textTheme.bodyMedium),
                trailing: Text(
                  '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildProfileTab() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.accentColor.withOpacity(0.2),
              child: Icon(Icons.store, size: 50, color: AppTheme.accentColor),
            ),
            SizedBox(height: 20),
            Consumer<AuthProvider>(builder: (context, auth, child) {
              return Text(auth.currentUser?.name ?? 'Barber Name', style: Theme.of(context).textTheme.headlineMedium);
            }),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: AnimatedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
