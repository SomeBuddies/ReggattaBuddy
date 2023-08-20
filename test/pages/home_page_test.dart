import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:regatta_buddy/pages/event_creation/event_creation.dart';
import 'package:regatta_buddy/pages/home.dart';
import 'package:regatta_buddy/pages/regatta_details.dart';
import 'package:regatta_buddy/pages/search.dart';
import 'package:regatta_buddy/pages/user_regattas.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route {}

const validRegattaCode = '12345';
const invalidRegattaCode = '0';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });
  TestWidgetsFlutterBinding.ensureInitialized();

  var mockedRoutes = {
    SearchPage.route: (_) => const Scaffold(
          body: Text("mockedSearchPage"),
        ),
    EventCreationPage.route: (_) => const Scaffold(
          body: Text("mockedCreatePage"),
        ),
    UserRegattasPage.route: (_) => const Scaffold(
          body: Text("mockedUserRegattasPage"),
        ),
    RegattaDetailsPage.route: (_) => const Scaffold(
          body: Text("mockedRegattaDetailsPage"),
        ),
  };

  testWidgets('finds all available buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Join'), findsOneWidget);
    expect(find.text('Your regattas'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets("Navigates to SearchPage on search button click", (tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
        home: const HomePage(),
        routes: mockedRoutes,
        navigatorObservers: [mockObserver]));

    expect(find.text('mockedSearchPage'), findsNothing);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any()));
    expect(find.text('mockedSearchPage'), findsOneWidget);
  });

  testWidgets("Navigates to UserRegattasPage on your regattas button click",
      (tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
        home: const HomePage(),
        routes: mockedRoutes,
        navigatorObservers: [mockObserver]));

    expect(find.text('mockedUserRegattasPage'), findsNothing);

    await tester.tap(find.text('Your regattas'));
    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any()));
    expect(find.text('mockedUserRegattasPage'), findsOneWidget);
  });

  testWidgets("Navigates to CreatePage on create button click and confirmation",
      (tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
        home: const HomePage(),
        routes: mockedRoutes,
        navigatorObservers: [mockObserver]));

    expect(find.text('mockedCreatePage'), findsNothing);

    await tester.tap(find.text('Create a new regatta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any()));
    expect(find.text('mockedCreatePage'), findsOneWidget);
  });

  testWidgets(
      "Navigates to RegattaDetailsPage after joining and using correct code",
      (tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
        home: const HomePage(),
        routes: mockedRoutes,
        navigatorObservers: [mockObserver]));

    expect(find.text('mockedRegattaDetailsPage'), findsNothing);
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), validRegattaCode);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any()));
    expect(find.text('mockedRegattaDetailsPage'), findsOneWidget);
  });

  testWidgets("Shows error message on invalid regatta code", (tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
        home: const HomePage(),
        routes: mockedRoutes,
        navigatorObservers: [mockObserver]));

    expect(find.text('mockedRegattaDetailsPage'), findsNothing);
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), invalidRegattaCode);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Please input valid regatta code.'), findsOneWidget);
  });
}
