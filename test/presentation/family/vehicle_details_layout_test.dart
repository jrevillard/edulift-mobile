import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/test_screen_sizes.dart';

/// Simple layout tests to verify responsive design patterns
/// Tests focus on constraint handling and widget sizing
void main() {
  group('Vehicle Details Layout Patterns', () {
    testWidgets('ConstrainedBox should handle mobile screen constraints', (
      tester,
    ) async {
      // Test responsive layout on iPhone SE (small mobile device)
      await TestScreenSizes.setScreenSize(tester, TestScreenSizes.testMobile);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight - 120,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(
                              isSmallScreen ? 12.0 : 16.0,
                            ),
                            child: const Text('Test Content'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Content'), findsOneWidget);

      // Reset screen size after mobile layout test
      await TestScreenSizes.resetScreenSize(tester);
    });

    testWidgets('Column with mainAxisSize.min should not cause overflow', (
      tester,
    ) async {
      // Test overflow handling on smallest iPhone screen size
      await TestScreenSizes.setScreenSize(tester, TestScreenSizes.iphoneSE);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 10; i++)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Item $i'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 9'), findsOneWidget);

      // Reset screen size after overflow test
      await TestScreenSizes.resetScreenSize(tester);
    });

    testWidgets(
      'CustomScrollView with SliverToBoxAdapter should handle content properly',
      (tester) async {
        // Test CustomScrollView on larger mobile devices
        await TestScreenSizes.setScreenSize(tester, TestScreenSizes.iphone14);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text('Card 1')),
                            ),
                          ),
                          SizedBox(height: 16),
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text('Card 2')),
                            ),
                          ),
                          SizedBox(height: 16),
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text('Card 3')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Card 1'), findsOneWidget);
        expect(find.text('Card 2'), findsOneWidget);
        expect(find.text('Card 3'), findsOneWidget);

        // Reset screen size after CustomScrollView test
        await TestScreenSizes.resetScreenSize(tester);
      },
    );

    testWidgets('SafeArea with RefreshIndicator should work properly', (
      tester,
    ) async {
      // Test SafeArea behavior on iPhone with notch
      await TestScreenSizes.setScreenSize(tester, TestScreenSizes.iphone12Mini);
      var refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshCalled = true;
                },
                child: const CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height:
                            800, // Make it taller than screen to be scrollable
                        child: Column(
                          children: [
                            Center(child: Text('Refreshable Content')),
                            SizedBox(height: 100),
                            Text('More content to make it scrollable'),
                            SizedBox(height: 100),
                            Text('Even more content'),
                            SizedBox(height: 100),
                            Text('Bottom content'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Refreshable Content'), findsOneWidget);

      // Test pull-to-refresh (drag down from top to trigger refresh)
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, 300), // Drag down 300 pixels from top
      );
      await tester.pumpAndSettle(); // Let refresh indicator complete
      expect(refreshCalled, isTrue);

      // Reset screen size after SafeArea/RefreshIndicator test
      await TestScreenSizes.resetScreenSize(tester);
    });
  });
}
