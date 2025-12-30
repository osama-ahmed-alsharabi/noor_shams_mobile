import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../cubit/channel_cubit.dart';
import '../cubit/offer_cubit.dart';
import '../cubit/order_cubit.dart';
import '../cubit/profile_cubit.dart';
import 'provider_home_view.dart';
import 'provider_profile_view.dart';
import 'my_services_view.dart';
import 'orders_view.dart';

class ServiceProviderLayout extends StatefulWidget {
  const ServiceProviderLayout({super.key});

  @override
  State<ServiceProviderLayout> createState() => _ServiceProviderLayoutState();
}

class _ServiceProviderLayoutState extends State<ServiceProviderLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChannelCubit()),
        BlocProvider(create: (context) => OfferCubit()),
        BlocProvider(create: (context) => OrderCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            ProviderHomeView(),
            OrdersView(),
            MyServicesView(),
            ProviderProfileView(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            top: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'الرئيسية',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                label: 'الطلبات',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view,
                label: 'خدماتي',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary.withOpacity(0.6),
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary.withOpacity(0.7),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
