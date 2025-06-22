import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_button.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late UserModel barber;
  late List<BarberService> selectedServices;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;

  List<TimeOfDay> _availableSlots = [];
  bool _isLoadingSlots = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      barber = arguments['barber'];
      selectedServices = arguments['services'];
      _fetchScheduleData();
    }
    _isInit = false;
  }

  Future<void> _fetchScheduleData() async {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    await Future.wait([
      scheduleProvider.fetchScheduleForBarber(barber.id),
      scheduleProvider.fetchUnavailableDatesForBarber(barber.id),
    ]);
  }

  Future<void> _updateAvailableSlots(DateTime day) async {
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
      _selectedTime = null;
    });

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final schedule = scheduleProvider.getViewedSchedule(barber.id);
    final dayOfWeek = DateFormat('EEEE').format(day);
    final daySchedule = schedule[dayOfWeek];

    if (daySchedule == null || daySchedule.isDayOff) {
      setState(() => _isLoadingSlots = false);
      return; // Barber does not work on this day
    }

    final bookedSlots = await bookingProvider.fetchBookedSlots(barber.id, day);

    List<TimeOfDay> potentialSlots = [];
    final startTimeParts = daySchedule.startTime.split(':');
    final endTimeParts = daySchedule.endTime.split(':');
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);
    final endHour = int.parse(endTimeParts[0]);
    final endMinute = int.parse(endTimeParts[1]);

    TimeOfDay currentTime = TimeOfDay(hour: startHour, minute: startMinute);
    final endTime = TimeOfDay(hour: endHour, minute: endMinute);

    while (currentTime.hour < endTime.hour || (currentTime.hour == endTime.hour && currentTime.minute < endTime.minute)) {
      potentialSlots.add(currentTime);
      // Increment by 30 minutes for each slot
      final newMinutes = currentTime.minute + 30;
      currentTime = TimeOfDay(hour: currentTime.hour + newMinutes ~/ 60, minute: newMinutes % 60);
    }

    _availableSlots = potentialSlots.where((slot) {
      final slotDateTime = DateTime(day.year, day.month, day.day, slot.hour, slot.minute);
      return !bookedSlots.any((booked) => booked.isAtSameMomentAs(slotDateTime));
    }).toList();

    setState(() => _isLoadingSlots = false);
  }

  void _onConfirmBooking() {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    final newBooking = BookingModel(
      id: '', // Firestore will generate this
      barberId: barber.id,
      barberName: barber.name,
      customerId: '', // Provider will fill this
      customerName: '', // Provider will fill this
      serviceNames: selectedServices.map((s) => s.name).toList(),
      totalPrice: selectedServices.fold(0.0, (sum, item) => sum + item.price),
      totalDuration: selectedServices.fold(0, (sum, item) => sum + item.duration),
      appointmentTime: DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ),
    );

    bookingProvider.createBooking(newBooking).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking confirmed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil(ModalRoute.withName('/customer-dashboard'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book with ${barber.name}'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface],
          ),
        ),
        child: Column(
          children: [
            _buildCalendar(),
            _buildTimeSlots(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildCalendar() {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        final unavailableDates = scheduleProvider.getViewedUnavailableDates(barber.id);
        final schedule = scheduleProvider.getViewedSchedule(barber.id);

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 60)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            enabledDayPredicate: (day) {
              // Check if the date is in the unavailable list
              final isUnavailable = unavailableDates.any((d) => isSameDay(d, day));
              if (isUnavailable) return false;

              // Check if the day of the week is a day off
              final dayOfWeek = DateFormat('EEEE').format(day);
              final daySchedule = schedule[dayOfWeek];
              if (daySchedule == null || daySchedule.isDayOff) return false;

              return true;
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _updateAvailableSlots(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              disabledTextStyle: TextStyle(color: Theme.of(context).disabledColor.withOpacity(0.5)), // Or Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
            ),
            headerStyle: HeaderStyle(
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20.0),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white), // Assuming primary color contrasts with white
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedDay == null) {
      return Expanded(
        child: Center(child: Text("Select a date to see available times.", style: Theme.of(context).textTheme.bodyLarge)),
      );
    }
    if (_isLoadingSlots) {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (_availableSlots.isEmpty) {
      return Expanded(
        child: Center(child: Text("No available slots for this day.", style: Theme.of(context).textTheme.bodyLarge)),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _availableSlots.length,
        itemBuilder: (ctx, index) {
          final slot = _availableSlots[index];
          final isSelected = _selectedTime == slot;
          return AnimatedButton(
            onPressed: () => setState(() => _selectedTime = slot),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
              ),
              child: Center(
                child: Text(
                  slot.format(context),
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingButton() {
    if (_selectedDay == null || _selectedTime == null) {
      return SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // For the bottom bar area
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) => AnimatedButton(
          onPressed: bookingProvider.isLoading ? null : _onConfirmBooking,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary, // For the button itself
                borderRadius: BorderRadius.circular(25)
            ),
            child: Center(
              child: bookingProvider.isLoading
                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : Text('Confirm Booking', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
