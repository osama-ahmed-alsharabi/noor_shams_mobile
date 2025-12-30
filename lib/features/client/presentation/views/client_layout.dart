import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../cubit/client_home_cubit.dart';
import '../cubit/browse_channels_cubit.dart';
import '../cubit/browse_offers_cubit.dart';
import '../cubit/client_order_cubit.dart';
import 'client_home_view.dart';
import 'browse_channels_view.dart';
import 'my_orders_view.dart';
import 'client_profile_view.dart';

class ClientLayout extends StatefulWidget {
  const ClientLayout({super.key});

  @override
  State<ClientLayout> createState() => _ClientLayoutState();
}

class _ClientLayoutState extends State<ClientLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ClientHomeView(),
    const BrowseChannelsView(),
    const MyOrdersView(),
    const ClientProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ClientHomeCubit()..loadHomeData()),
        BlocProvider(create: (_) => BrowseChannelsCubit()..loadChannels()),
        BlocProvider(create: (_) => BrowseOffersCubit()..loadOffers()),
        BlocProvider(create: (_) => ClientOrderCubit()..loadOrders()),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'استكشاف',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'طلباتي',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
