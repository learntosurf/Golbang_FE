import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golbang/global_config.dart';
import 'package:golbang/models/bookmark.dart';
import 'package:golbang/models/event.dart';
import 'package:golbang/models/group.dart';
import 'package:golbang/models/user_account.dart';
import 'package:golbang/models/get_statistics_overall.dart';
import 'package:golbang/services/event_service.dart';
import 'package:golbang/widgets/sections/bookmark_section.dart';
import 'package:golbang/widgets/sections/groups_section.dart';
import 'package:golbang/widgets/common/section_with_scroll.dart';
import 'package:golbang/widgets/sections/upcoming_events.dart';
import 'package:golbang/pages/event/event_main.dart';
import 'package:golbang/pages/group/group_main.dart';
import 'package:golbang/pages/profile/profile_screen.dart';
import 'package:golbang/services/group_service.dart';
import 'package:golbang/services/user_service.dart';
import 'package:golbang/services/statistics_service.dart';
import '../../repoisitory/secure_storage.dart';

import 'package:golbang/pages/notification/notification_history_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    EventPage(),
    GroupMainPage(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'GOLBANG',
          style: TextStyle(color: Colors.green, fontSize: 25),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationHistoryPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note),
              label: '일정',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded),
              label: '모임',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: '내 정보',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetching services
    final storage = ref.watch(secureStorageProvider);
    final UserService userService = UserService(storage);
    final GroupService groupService = GroupService(storage);
    final EventService eventService = EventService(storage);
    final StatisticsService statisticsService = StatisticsService(storage);

    DateTime _focusedDay = DateTime.now();
    String date = '${_focusedDay.year}-${_focusedDay.month.toString().padLeft(2, '0')}-01';

    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          userService.getUserInfo(), // Fetch user info
          eventService.getEventsForMonth(date: date), // Fetch events for the month
          groupService.getUserGroups(), // Fetch user groups
          statisticsService.fetchOverallStatistics(), // Fetch overall statistics
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Retrieve data from snapshot
            UserAccount userAccount = snapshot.data![0];
            List<Event> events = snapshot.data![1];
            List<Group> groups = snapshot.data![2];
            OverallStatistics overallStatistics = snapshot.data![3];

            return Column(
              children: <Widget>[
                SizedBox(
                  height: 140,
                  child: SectionWithScroll(
                    title: '즐겨찾기',
                    child: BookmarkSection(
                      userAccount: userAccount,
                      overallStatistics: overallStatistics, // Pass overall statistics
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SectionWithScroll(
                    title: '다가오는 일정 ${events.length}',
                    child: UpcomingEvents(events: events),
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: SectionWithScroll(
                    title: '내 모임 ${groups.length}',
                    child: GroupsSection(groups: groups),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
