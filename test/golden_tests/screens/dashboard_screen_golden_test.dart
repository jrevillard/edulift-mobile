// EduLift - Dashboard Screen Golden Tests
// Comprehensive visual regression tests for dashboard and home screens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/groups/presentation/widgets/group_card.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/group_data_factory.dart';
import '../../support/factories/family_data_factory.dart';
import '../../support/factories/schedule_data_factory.dart';
import '../../support/factories/test_data_factory.dart';

void main() {
  // Reset factories before tests
  setUpAll(() {
    GroupDataFactory.resetCounters();
    FamilyDataFactory.resetCounters();
    ScheduleDataFactory.resetCounters();
    TestDataFactory.resetSeed();
  });

  group('Dashboard Screen - Golden Tests', () {
    testWidgets('Dashboard - with groups and schedules', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 5);
      final schedules = ScheduleDataFactory.createLargeScheduleSlotList(
        count: 10,
      );

      final screen = Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User welcome section
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.blue.shade50,
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      child: Icon(Icons.person, size: 32),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Günther Beaumont',
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Groups',
                        value: groups.length.toString(),
                        icon: Icons.groups,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Schedules',
                        value: schedules.length.toString(),
                        icon: Icons.calendar_today,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Groups section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'My Groups',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: groups.take(3).length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GroupCard(
                      group: group,
                      onSelect: () {},
                      onManage: () {},
                    ),
                  );
                },
              ),

              // Upcoming schedules section
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Upcoming Schedules',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: schedules.take(5).length,
                itemBuilder: (context, index) {
                  final slot = schedules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        '${slot.dayOfWeek.fullName} - ${slot.timeOfDay.toApiFormat()}',
                      ),
                      subtitle: Text('Week ${slot.week}'),
                      trailing: Text(
                        '${slot.vehicleAssignments.length} vehicles',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Groups'),
            BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom),
              label: 'Family',
            ),
          ],
        ),
      );

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: screen,
        testName: 'dashboard_with_data',
        devices: DeviceConfigurations.defaultSet,
        themes: ThemeConfigurations.basic,
      );
    });

    testWidgets('Dashboard - empty state', (tester) async {
      final screen = Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.dashboard_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to EduLift!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get started by creating a group or joining one',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Create Group'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.group_add),
                label: const Text('Join Group'),
              ),
            ],
          ),
        ),
      );

      await GoldenTestWrapper.testEmptyState(
        tester: tester,
        widget: screen,
        testName: 'dashboard',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('Dashboard - dark theme', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 3);

      final screen = Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Groups',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...groups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GroupCard(
                    group: group,
                    onSelect: () {},
                    onManage: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: screen,
        testName: 'dashboard_dark',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.dark],
      );
    });

    testWidgets('Dashboard - tablet layout', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 6);

      final screen = Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4, // Decreased to give more vertical space
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return GroupCard(group: group, onSelect: () {}, onManage: () {});
            },
          ),
        ),
      );

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: screen,
        testName: 'dashboard_tablet',
        devices: [DeviceConfigurations.iPadPro],
        themes: [ThemeConfigurations.light],
      );
    });
  });
}

// Helper widget for stat cards
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
