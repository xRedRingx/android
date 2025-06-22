import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barber_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/animated_list_item.dart';

class CustomerDashboard extends StatefulWidget {
  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showRatingDialog(BookingModel booking) {
    final _commentController = TextEditingController();
    double _rating = 4.0;

    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Rate your experience', style: Theme.of(context).textTheme.headlineMedium),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('How was your appointment with ${booking.barberName}?'),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 35,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _rating = index + 1.0;
                          });
                        },
                      )),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Leave a comment (optional)',
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                ElevatedButton(
                  child: Text('Submit Review'),
                  onPressed: () {
                    Provider.of<ReviewProvider>(context, listen: false).addReview(
                      barberId: booking.barberId,
                      rating: _rating,
                      comment: _commentController.text,
                      bookingId: booking.id,
                    );
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            );
          },
        )
    );
  }

  void _showCancelConfirmationDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Appointment?'),
        content: Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Provider.of<BookingProvider>(context, listen: false).cancelBooking(bookingId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
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
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor,
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
                    _buildHomeTab(),
                    _buildBookingsTab(),
                    _buildExploreTab(),
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
      child: Container(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Text(
                        'Hello, ${authProvider.currentUser?.name ?? "User"}!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ready for your next appointment?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActionsCard(),
            SizedBox(height: 24),
            _buildUpcomingAppointmentsCard(),
            SizedBox(height: 24),
            _buildFeaturedBarbersCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.search,
                    label: 'Find Barber',
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      _pageController.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.calendar_today,
                    label: 'My Bookings',
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentsCard() {
    return StreamBuilder<List<BookingModel>>(
        stream: Provider.of<BookingProvider>(context).getMyCustomerBookingsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();

          final upcomingBookings = snapshot.data!
              .where((b) => b.appointmentTime.isAfter(DateTime.now()))
              .toList();

          if (upcomingBookings.isEmpty) return SizedBox.shrink();

          return Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming', style: Theme.of(context).textTheme.headlineSmall),
                      TextButton(
                        onPressed: () => _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                        child: Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: upcomingBookings.length > 2 ? 2 : upcomingBookings.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentItem(upcomingBookings[index]);
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildAppointmentItem(BookingModel booking) {
    Color statusColor;
    IconData statusIcon;
    bool showRateButton = false;
    bool showCancelButton = false;

    switch(booking.status) {
      case 'pending':
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        showCancelButton = booking.appointmentTime.isAfter(DateTime.now());
        break;
      case 'completed':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        showRateButton = true;
        break;
      case 'canceled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'reviewed':
        statusColor = Colors.amber;
        statusIcon = Icons.star;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(statusIcon, color: statusColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.barberName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      booking.serviceNames.join(', '),
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Theme.of(context).iconTheme.color),
                        SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy • h:mm a').format(booking.appointmentTime),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if(showRateButton)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: Text("Rate Appointment"),
              onPressed: () => _showRatingDialog(booking),
            ),
          ),
        if(showCancelButton)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: Text("Cancel Appointment", style: TextStyle(color: Colors.red)),
              onPressed: () => _showCancelConfirmationDialog(booking.id),
            ),
          )
      ],
    );
  }

  Widget _buildFeaturedBarbersCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Featured Barbers', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Container(
              height: 120,
              child: StreamBuilder<List<UserModel>>(
                stream: Provider.of<BarberProvider>(context).getBarbersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No barbers available.", style: Theme.of(context).textTheme.bodyMedium));
                  }
                  final barbers = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: barbers.length > 3 ? 3 : barbers.length,
                    itemBuilder: (context, index) {
                      return _buildBarberCard(barber: barbers[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarberCard({ required UserModel barber }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/barber-profile', arguments: barber);
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 8),
            Text(
              barber.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 12),
                SizedBox(width: 2),
                Text(
                  "4.8", // Mock rating
                  style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            ),
            Text(
              barber.specialties?.isNotEmpty ?? false ? barber.specialties!.first : 'Top Stylist',
              style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab() {
    return StreamBuilder<List<BookingModel>>(
      stream: Provider.of<BookingProvider>(context).getMyCustomerBookingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching bookings."));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month, size: 80, color: Theme.of(context).textTheme.bodyMedium?.color),
                SizedBox(height: 20),
                Text('No bookings yet.', style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 8),
                Text("Your new appointments will appear here.", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }

        final bookings = snapshot.data!;
        final upcoming = bookings.where((b) => b.appointmentTime.isAfter(DateTime.now())).toList();
        final past = bookings.where((b) => b.appointmentTime.isBefore(DateTime.now())).toList();

        return ListView(
          padding: EdgeInsets.all(24),
          children: [
            Text('Upcoming', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 16),
            if (upcoming.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text("You have no upcoming appointments.", style: Theme.of(context).textTheme.bodyMedium),
              ),
            ...upcoming.map((booking) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildAppointmentItem(booking),
            )),
            SizedBox(height: 32),
            Text('Past', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 16),
            if (past.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text("You have no past appointments.", style: Theme.of(context).textTheme.bodyMedium),
              ),
            ...past.map((booking) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildAppointmentItem(booking),
            )),
          ],
        );
      },
    );
  }

  Widget _buildExploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Find Barbers', style: Theme.of(context).textTheme.headlineMedium),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: Provider.of<BarberProvider>(context).getBarbersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text("No barbers available right now.", style: Theme.of(context).textTheme.bodyLarge),
                );
              }
              final barbers = snapshot.data!;
              return AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  itemCount: barbers.length,
                  itemBuilder: (ctx, index) {
                    final barber = barbers[index];
                    return AnimatedListItem(
                      index: index,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.primary),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(barber.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text(
                                      barber.specialties?.join(', ') ?? 'Top Stylist',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        i < 4 ? Icons.star : Icons.star_border, // Mock rating
                                        color: Colors.amber,
                                        size: 16,
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/barber-profile', arguments: barber);
                                },
                                child: Text('Book'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 24),
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            authProvider.currentUser?.name ?? 'User',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                          ),
                          SizedBox(height: 4),
                          Text(
                            authProvider.currentUser?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  _buildProfileOption(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.of(context).pushNamed('/edit-profile');
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Booking History',
                    onTap: () {
                      _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.favorite,
                    title: 'Favorite Barbers',
                    onTap: () {},
                  ),
                  Divider(),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: Text("Dark Mode", style: Theme.of(context).textTheme.bodyLarge),
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        secondary: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.primary),
                        activeColor: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                  Divider(),
                  SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return AnimatedButton(
                        onPressed: () {
                          authProvider.logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).iconTheme.color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
