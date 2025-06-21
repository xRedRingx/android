import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/service_model.dart';
import '../../providers/services_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_button.dart';

class BarberProfileScreen extends StatefulWidget {
  @override
  _BarberProfileScreenState createState() => _BarberProfileScreenState();
}

class _BarberProfileScreenState extends State<BarberProfileScreen> {
  late UserModel barber;
  bool _isInit = true;
  bool _isLoading = true;
  List<BarberService> _selectedServices = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      barber = ModalRoute.of(context)!.settings.arguments as UserModel;
      _fetchServices();
    }
    _isInit = false;
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    await Provider.of<ServicesProvider>(context, listen: false)
        .fetchServicesForBarber(barber.id);
    setState(() => _isLoading = false);
  }

  void _toggleServiceSelection(BarberService service) {
    setState(() {
      if (_selectedServices.any((s) => s.id == service.id)) {
        _selectedServices.removeWhere((s) => s.id == service.id);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    final displayedServices = servicesProvider.getViewedBarberServices(barber.id);

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
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Select Services', style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            _isLoading
                ? SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final service = displayedServices[index];
                    final isSelected = _selectedServices.any((s) => s.id == service.id);
                    return _buildServiceItem(service, isSelected);
                  },
                  childCount: displayedServices.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: AppTheme.primaryColor,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          barber.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentColor.withOpacity(0.6), AppTheme.primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.surfaceColor.withOpacity(0.8),
                    child: Icon(Icons.person, size: 50, color: AppTheme.accentColor),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      barber.bio ?? "Expert stylist specializing in modern cuts and classic shaves.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(BarberService service, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.accentColor.withOpacity(0.2) : AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isSelected ? AppTheme.accentColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: () => _toggleServiceSelection(service),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(service.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('${service.duration} min • \$${service.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? AppTheme.accentColor : AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildBookingButton() {
    if (_selectedServices.isEmpty) {
      return SizedBox.shrink();
    }

    double totalPrice = _selectedServices.fold(0, (sum, item) => sum + item.price);
    int totalDuration = _selectedServices.fold(0, (sum, item) => sum + item.duration);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: \$${totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 4),
              Text('$totalDuration min • ${_selectedServices.length} service(s)', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/booking-screen',
                arguments: {
                  'barber': barber,
                  'services': _selectedServices,
                },
              );
            },
            child: Text('Choose Time'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
