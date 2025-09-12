import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/services/user_service.dart';
import 'core/services/emergency_request_service.dart';
import 'core/services/professional_service.dart';
import 'core/services/ambulance_location_service.dart';
import 'core/services/maps_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/comprehensive_notification_service.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/user_login_screen.dart';
import 'features/auth/user_signup_screen.dart';
import 'features/auth/professional_login_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'scripts/debug_emergency_requests.dart';
import 'features/patient/patient_registration_screen.dart';
import 'features/patient/user_dashboard_screen.dart';
import 'features/patient/service_history_screen.dart';
import 'features/patient/emergency_contacts_screen.dart';
import 'features/patient/user_profile_screen.dart';
import 'features/patient/interactive_map_screen.dart';
import 'features/patient/emergency_request_screen.dart';
import 'features/patient/ambulance_tracking_screen.dart';
import 'features/driver/driver_dashboard_screen.dart';
import 'features/driver/emergency_request_details_screen.dart';
import 'features/driver/driver_navigation_screen.dart';
import 'features/driver/driver_profile_screen.dart';
import 'features/driver/driver_trips_screen.dart';
import 'features/police/traffic_police_dashboard_screen.dart';
import 'features/police/route_clearance_screen.dart';
import 'features/police/live_tracking_screen.dart';
import 'features/police/activity_log_screen.dart';
import 'features/police/traffic_police_profile_screen.dart';
import 'features/police/traffic_police_analytics_screen.dart';
import 'features/hospital/hospital_dashboard_screen.dart';
import 'features/hospital/hospital_live_tracking_screen.dart';
import 'features/hospital/patient_live_tracking_screen.dart';
import 'features/hospital/emergency_alert_creation_screen.dart';
import 'features/hospital/ambulance_assignment_screen.dart';
import 'features/hospital/hospital_reports_screen.dart';
import 'features/hospital/hospital_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize GetX services - Order matters for dependencies
  Get.put(NotificationService());
  Get.put(UserService());
  Get.put(EmergencyRequestService());
  Get.put(ProfessionalService());
  Get.put(AmbulanceLocationService());
  Get.put(MapsService());
  
  // Initialize comprehensive notification service after core services
  Get.put(ComprehensiveNotificationService());
  
  runApp(const ResQRouteApp());
}

class ResQRouteApp extends StatelessWidget {
  const ResQRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ResQRoute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/user-login', page: () => const UserLoginScreen()),
        GetPage(name: '/user-signup', page: () => const UserSignupScreen()),
        GetPage(name: '/patient-registration', page: () => const PatientRegistrationScreen()),
        GetPage(name: '/professional-login', page: () => const ProfessionalLoginScreen()),
        GetPage(name: '/user-dashboard', page: () => const UserDashboardScreen()),
        GetPage(name: '/service-history', page: () => const ServiceHistoryScreen()),
        GetPage(name: '/emergency-contacts', page: () => const EmergencyContactsScreen()),
        GetPage(name: '/user-profile', page: () => const UserProfileScreen()),
        GetPage(name: '/interactive-map', page: () => const InteractiveMapScreen()),
        GetPage(name: '/emergency-request', page: () => const EmergencyRequestScreen()),
        GetPage(name: '/ambulance-tracking', page: () => const AmbulanceTrackingScreen()),
        GetPage(name: '/driver-dashboard', page: () => const DriverDashboardScreen()),
        GetPage(name: '/emergency-request-details', page: () => const EmergencyRequestDetailsScreen()),
        GetPage(name: '/driver-navigation', page: () => const DriverNavigationScreen()),
        GetPage(name: '/driver-profile', page: () => const DriverProfileScreen()),
        GetPage(name: '/driver-trips', page: () => const DriverTripsScreen()),
        GetPage(name: '/traffic-police-dashboard', page: () => const TrafficPoliceDashboardScreen()),
        GetPage(name: '/route-clearance', page: () => const RouteClearanceScreen()),
        GetPage(name: '/live-tracking', page: () => const LiveTrackingScreen()),
        GetPage(name: '/activity-log', page: () => const ActivityLogScreen()),
        GetPage(name: '/traffic-police-profile', page: () => const TrafficPoliceProfileScreen()),
        GetPage(name: '/traffic-police-analytics', page: () => const TrafficPoliceAnalyticsScreen()),
        GetPage(name: '/hospital-dashboard', page: () => const HospitalDashboardScreen()),
        GetPage(name: '/hospital-live-tracking', page: () => const HospitalLiveTrackingScreen()),
        GetPage(name: '/patient-live-tracking', page: () => const PatientLiveTrackingScreen()),
        GetPage(name: '/emergency-alert-creation', page: () => const EmergencyAlertCreationScreen()),
        GetPage(name: '/ambulance-assignment', page: () => const AmbulanceAssignmentScreen()),
        GetPage(name: '/hospital-reports', page: () => const HospitalReportsScreen()),
        GetPage(name: '/hospital-profile', page: () => const HospitalProfileScreen()),
        GetPage(name: '/WelcomeScreen', page: () => const WelcomeScreen()),
        GetPage(name: '/debug-emergency', page: () => DebugEmergencyRequests()),
      ],
    );
  }
}
