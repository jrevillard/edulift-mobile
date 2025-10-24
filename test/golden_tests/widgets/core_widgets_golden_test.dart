// EduLift - Core Design System Widgets Golden Tests
// Tests for core adaptive widgets and design system components

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/presentation/widgets/adaptive_widgets.dart';
import 'package:edulift/features/groups/presentation/widgets/group_card.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/group_data_factory.dart';

void main() {
  group('Core Design System Widgets - Golden Tests', () {
    testWidgets('AdaptiveButton - all variants', (tester) async {
      final widget = Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Filled button
              AdaptiveButton(
                onPressed: () {},
                child: const Text('Filled Button'),
              ),
              const SizedBox(height: 16),

              // Outlined button
              AdaptiveButton(
                onPressed: () {},
                style: AdaptiveButtonStyle.outlined,
                child: const Text('Outlined Button'),
              ),
              const SizedBox(height: 16),

              // Text button
              AdaptiveButton(
                onPressed: () {},
                style: AdaptiveButtonStyle.text,
                child: const Text('Text Button'),
              ),
              const SizedBox(height: 16),

              // Disabled button
              const AdaptiveButton(
                onPressed: null,
                child: Text('Disabled Button'),
              ),
            ],
          ),
        ),
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: widget,
        testName: 'adaptive_buttons',
        devices: [DeviceConfigurations.iphone13],
        themes: ThemeConfigurations.basic,
      );
    });

    testWidgets('AdaptiveScaffold - standard layout', (tester) async {
      final widget = AdaptiveScaffold(
        title: 'Adaptive Scaffold',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Adaptive Scaffold Content',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      );

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: widget,
        testName: 'adaptive_scaffold',
        devices: [DeviceConfigurations.iphone13],
        themes: ThemeConfigurations.basic,
      );
    });

    testWidgets('Card - with content', (tester) async {
      const widget = Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Information Card',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This is a card component that adjusts to different screen sizes and themes.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Elevated card
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elevated Card',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'With higher elevation',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: widget,
        testName: 'standard_cards',
        devices: [DeviceConfigurations.iphone13],
        themes: ThemeConfigurations.basic,
      );
    });

    testWidgets('GroupCard - single card', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 1);
      final group = groups[0];

      final widget = Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GroupCard(
            group: group,
            onSelect: () {},
            onManage: () {},
          ),
        ),
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: widget,
        testName: 'group_card_single',
        devices: [DeviceConfigurations.iphone13],
        themes: ThemeConfigurations.basic,
      );
    });

    testWidgets('GroupCard - multiple cards list', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 3);

      final widget = Scaffold(
        appBar: AppBar(title: const Text('Group Cards')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GroupCard(
                group: groups[index],
                onSelect: () {},
                onManage: () {},
              ),
            );
          },
        ),
      );

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: widget,
        testName: 'group_cards_list',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });
  });
}
