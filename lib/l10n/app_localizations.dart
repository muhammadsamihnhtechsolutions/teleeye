import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @byTappingContinueYouAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'By tapping continue, you  agree to '**
  String get byTappingContinueYouAgreeTo;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions '**
  String get termsAndConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy '**
  String get privacyPolicy;

  /// No description provided for @ofBangladeshEyeHospital.
  ///
  /// In en, this message translates to:
  /// **'of Bangladesh Eye Hospital '**
  String get ofBangladeshEyeHospital;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @enterYourMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Mobile Number'**
  String get enterYourMobileNumber;

  /// No description provided for @continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueNext;

  /// No description provided for @imtiaz.
  ///
  /// In en, this message translates to:
  /// **'English '**
  String get imtiaz;

  /// No description provided for @video_consultation.
  ///
  /// In en, this message translates to:
  /// **'Video Consultation'**
  String get video_consultation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @eye_test.
  ///
  /// In en, this message translates to:
  /// **'Eye Test'**
  String get eye_test;

  /// No description provided for @get_remind_in_your_medication_time.
  ///
  /// In en, this message translates to:
  /// **'Get remind in your\nmedication time'**
  String get get_remind_in_your_medication_time;

  /// No description provided for @medication_tracker.
  ///
  /// In en, this message translates to:
  /// **'Medication Tracker'**
  String get medication_tracker;

  /// No description provided for @doctors_are_online.
  ///
  /// In en, this message translates to:
  /// **'140 Ophthalmologists online'**
  String get doctors_are_online;

  /// No description provided for @eye_test_in_your_hand.
  ///
  /// In en, this message translates to:
  /// **'6 Eye test in your hand'**
  String get eye_test_in_your_hand;

  /// No description provided for @nearest_eye_hospital.
  ///
  /// In en, this message translates to:
  /// **'Nearest Eye Hospital'**
  String get nearest_eye_hospital;

  /// No description provided for @all_prescriptions.
  ///
  /// In en, this message translates to:
  /// **'All Prescriptions'**
  String get all_prescriptions;

  /// No description provided for @my_records.
  ///
  /// In en, this message translates to:
  /// **'My Records'**
  String get my_records;

  /// No description provided for @test_results.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get test_results;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @favourite_doctors.
  ///
  /// In en, this message translates to:
  /// **'Favourite Doctors'**
  String get favourite_doctors;

  /// No description provided for @transactions_history.
  ///
  /// In en, this message translates to:
  /// **'Transactions History'**
  String get transactions_history;

  /// No description provided for @promos.
  ///
  /// In en, this message translates to:
  /// **'Promos'**
  String get promos;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @change_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Change Mobile Number'**
  String get change_mobile_number;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_and_conditions;

  /// No description provided for @privacy_and_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Policy'**
  String get privacy_and_policy;

  /// No description provided for @payment_terms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get payment_terms;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @emergency_call.
  ///
  /// In en, this message translates to:
  /// **'Emergency Call'**
  String get emergency_call;

  /// No description provided for @live_support.
  ///
  /// In en, this message translates to:
  /// **'Live Support'**
  String get live_support;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get log_out;

  /// No description provided for @right_eye.
  ///
  /// In en, this message translates to:
  /// **'Right Eye'**
  String get right_eye;

  /// No description provided for @left_eye.
  ///
  /// In en, this message translates to:
  /// **'Left Eye'**
  String get left_eye;

  /// No description provided for @visual_acuity.
  ///
  /// In en, this message translates to:
  /// **'Visual Acuity'**
  String get visual_acuity;

  /// No description provided for @near_vision.
  ///
  /// In en, this message translates to:
  /// **'Near Vision'**
  String get near_vision;

  /// No description provided for @color_vision.
  ///
  /// In en, this message translates to:
  /// **'Color Vision'**
  String get color_vision;

  /// No description provided for @amd.
  ///
  /// In en, this message translates to:
  /// **'AMD'**
  String get amd;

  /// No description provided for @app_test.
  ///
  /// In en, this message translates to:
  /// **'App Test'**
  String get app_test;

  /// No description provided for @clinical_results.
  ///
  /// In en, this message translates to:
  /// **'Clinical Results'**
  String get clinical_results;

  /// No description provided for @add_new_prescription.
  ///
  /// In en, this message translates to:
  /// **'Add New Prescription'**
  String get add_new_prescription;

  /// No description provided for @remove_from_favourites.
  ///
  /// In en, this message translates to:
  /// **'Remove From Favourites'**
  String get remove_from_favourites;

  /// No description provided for @book_now.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get book_now;

  /// No description provided for @current_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Current Mobile Number'**
  String get current_mobile_number;

  /// No description provided for @new_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'New Mobile Number'**
  String get new_mobile_number;

  /// No description provided for @confirm_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Confirm Mobile Number'**
  String get confirm_mobile_number;

  /// No description provided for @enter_new_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Enter new mobile number'**
  String get enter_new_mobile_number;

  /// No description provided for @confirm_new_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Confirm new mobile number'**
  String get confirm_new_mobile_number;

  /// No description provided for @add_promo_code.
  ///
  /// In en, this message translates to:
  /// **'Add Promo Code'**
  String get add_promo_code;

  /// No description provided for @promo_code.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promo_code;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createPatientProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Patient Profile'**
  String get createPatientProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @proceedNext.
  ///
  /// In en, this message translates to:
  /// **'Proceed Next'**
  String get proceedNext;

  /// No description provided for @doctorList.
  ///
  /// In en, this message translates to:
  /// **'Doctor List'**
  String get doctorList;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @seeDoctorNow.
  ///
  /// In en, this message translates to:
  /// **'See Doctor Now'**
  String get seeDoctorNow;

  /// No description provided for @consultationFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation Fee'**
  String get consultationFee;

  /// No description provided for @selectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select Patient'**
  String get selectPatient;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @followup.
  ///
  /// In en, this message translates to:
  /// **'Followup'**
  String get followup;

  /// No description provided for @create_new_medication.
  ///
  /// In en, this message translates to:
  /// **'Create New Medication'**
  String get create_new_medication;

  /// No description provided for @create_medication.
  ///
  /// In en, this message translates to:
  /// **'Create Medication'**
  String get create_medication;

  /// No description provided for @medication_title.
  ///
  /// In en, this message translates to:
  /// **'Medication title'**
  String get medication_title;

  /// No description provided for @medication_description.
  ///
  /// In en, this message translates to:
  /// **'Medication Description'**
  String get medication_description;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @add_new_time.
  ///
  /// In en, this message translates to:
  /// **'Add New Time'**
  String get add_new_time;

  /// No description provided for @add_medication_time_schedule.
  ///
  /// In en, this message translates to:
  /// **'Add Medication Time Schedule'**
  String get add_medication_time_schedule;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @every_day.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get every_day;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @choose_day.
  ///
  /// In en, this message translates to:
  /// **'Choose Day'**
  String get choose_day;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @add_to_favorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get add_to_favorites;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @total_ratings.
  ///
  /// In en, this message translates to:
  /// **'Total Ratings'**
  String get total_ratings;

  /// No description provided for @experience_in.
  ///
  /// In en, this message translates to:
  /// **'Experience in'**
  String get experience_in;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @consultation_fee.
  ///
  /// In en, this message translates to:
  /// **'Consultation Fee'**
  String get consultation_fee;

  /// No description provided for @followup_fee.
  ///
  /// In en, this message translates to:
  /// **'Followup Fee'**
  String get followup_fee;

  /// No description provided for @total_patients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get total_patients;

  /// No description provided for @average_consultancy_time.
  ///
  /// In en, this message translates to:
  /// **'Average consultancy time'**
  String get average_consultancy_time;

  /// No description provided for @about_doctor.
  ///
  /// In en, this message translates to:
  /// **'About Doctor'**
  String get about_doctor;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get date_of_birth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @go_to_appointment.
  ///
  /// In en, this message translates to:
  /// **'Go to appointment'**
  String get go_to_appointment;

  /// No description provided for @book_again.
  ///
  /// In en, this message translates to:
  /// **'Book Again'**
  String get book_again;

  /// No description provided for @notify_me.
  ///
  /// In en, this message translates to:
  /// **'Notify Me'**
  String get notify_me;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @search_doctor.
  ///
  /// In en, this message translates to:
  /// **'Search Doctor'**
  String get search_doctor;

  /// No description provided for @add_new_test_result.
  ///
  /// In en, this message translates to:
  /// **'Add New Test Result'**
  String get add_new_test_result;

  /// No description provided for @prescription_title.
  ///
  /// In en, this message translates to:
  /// **'Prescription Title'**
  String get prescription_title;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @doctor_is_offline_try_again_later.
  ///
  /// In en, this message translates to:
  /// **'Doctor is offline at this moment! Please try again later!'**
  String get doctor_is_offline_try_again_later;

  /// No description provided for @reason_for_visit.
  ///
  /// In en, this message translates to:
  /// **'Reason for Visit'**
  String get reason_for_visit;

  /// No description provided for @dont_turn_off_your_internet_doctor_will_call.
  ///
  /// In en, this message translates to:
  /// **'Don’t turn off your internet. Make sure you have a good internet connection. Otherwise, it may have to buffer while you’re on a video call with the doctor'**
  String get dont_turn_off_your_internet_doctor_will_call;

  /// No description provided for @will_call_you_soon.
  ///
  /// In en, this message translates to:
  /// **' will call you very soon.'**
  String get will_call_you_soon;

  /// No description provided for @congrats.
  ///
  /// In en, this message translates to:
  /// **'Congrats!'**
  String get congrats;

  /// No description provided for @estimated_wait_time.
  ///
  /// In en, this message translates to:
  /// **'Estimated wait time'**
  String get estimated_wait_time;

  /// No description provided for @patients_before_you.
  ///
  /// In en, this message translates to:
  /// **'Patients before you'**
  String get patients_before_you;

  /// No description provided for @waiting_for_doctor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Doctor'**
  String get waiting_for_doctor;

  /// No description provided for @appointment_id.
  ///
  /// In en, this message translates to:
  /// **'Appointment ID'**
  String get appointment_id;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @myself.
  ///
  /// In en, this message translates to:
  /// **'My Self'**
  String get myself;

  /// No description provided for @appointment_booked_successfully.
  ///
  /// In en, this message translates to:
  /// **'Appointment booked successfully.'**
  String get appointment_booked_successfully;

  /// No description provided for @live_chat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get live_chat;

  /// No description provided for @rate_now.
  ///
  /// In en, this message translates to:
  /// **'Rate now'**
  String get rate_now;

  /// No description provided for @please_enter_a_phone_number_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number and try again!'**
  String get please_enter_a_phone_number_and_try_again;

  /// No description provided for @an_SMS_with_OTP_has_been_sent_to.
  ///
  /// In en, this message translates to:
  /// **'An SMS with OTP has been sent to'**
  String get an_SMS_with_OTP_has_been_sent_to;

  /// No description provided for @verify_it_s_you.
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you'**
  String get verify_it_s_you;

  /// No description provided for @resend_OTP.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP?'**
  String get resend_OTP;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend?'**
  String get resend;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verify;

  /// No description provided for @please_give_your_otp.
  ///
  /// In en, this message translates to:
  /// **'Please give your otp'**
  String get please_give_your_otp;

  /// No description provided for @please_enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get please_enter_otp;

  /// No description provided for @please_enter_complete_6_digit_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete 6-digit OTP'**
  String get please_enter_complete_6_digit_otp;

  /// No description provided for @quick_access.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quick_access;

  /// No description provided for @check_your_vision_now.
  ///
  /// In en, this message translates to:
  /// **'Check Your Vision Now'**
  String get check_your_vision_now;

  /// No description provided for @never_miss_a_dose.
  ///
  /// In en, this message translates to:
  /// **'Never Miss a Dose.'**
  String get never_miss_a_dose;

  /// No description provided for @set_reminders.
  ///
  /// In en, this message translates to:
  /// **'Set Reminders'**
  String get set_reminders;

  /// No description provided for @your_prescriptions_all_in_one_place.
  ///
  /// In en, this message translates to:
  /// **'Your Prescription, All in One Place'**
  String get your_prescriptions_all_in_one_place;

  /// No description provided for @you_dont_have_any_upcoming_appointments.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any upcoming appointments'**
  String get you_dont_have_any_upcoming_appointments;

  /// No description provided for @you_dont_have_any_clinical_results.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any clinical results'**
  String get you_dont_have_any_clinical_results;

  /// No description provided for @you_dont_have_any_app_test_results.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any app test results'**
  String get you_dont_have_any_app_test_results;

  /// No description provided for @paid_to.
  ///
  /// In en, this message translates to:
  /// **'Paid to'**
  String get paid_to;

  /// No description provided for @minimum_amount.
  ///
  /// In en, this message translates to:
  /// **'Minimum Amount'**
  String get minimum_amount;

  /// No description provided for @valid_till.
  ///
  /// In en, this message translates to:
  /// **'Valid Till'**
  String get valid_till;

  /// No description provided for @up_to.
  ///
  /// In en, this message translates to:
  /// **'Up to'**
  String get up_to;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp'**
  String get whatsapp;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @type_your_message.
  ///
  /// In en, this message translates to:
  /// **'Type your message'**
  String get type_your_message;

  /// No description provided for @you_dont_have_any_follow_up_appointments.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any followup appointments'**
  String get you_dont_have_any_follow_up_appointments;

  /// No description provided for @you_dont_have_any_past_appointments.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any past appointments'**
  String get you_dont_have_any_past_appointments;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @how_was_the_doctor.
  ///
  /// In en, this message translates to:
  /// **'How was the Doctor?'**
  String get how_was_the_doctor;

  /// No description provided for @leave_a_comment.
  ///
  /// In en, this message translates to:
  /// **'Leave a comment'**
  String get leave_a_comment;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @review_can_not_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Review cannot be empty'**
  String get review_can_not_be_empty;

  /// No description provided for @you_dont_have_any_prescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any prescription'**
  String get you_dont_have_any_prescription;

  /// No description provided for @view_prescription.
  ///
  /// In en, this message translates to:
  /// **'View Prescription'**
  String get view_prescription;

  /// No description provided for @upload_reports_and_previous_prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Upload reports & previous prescriptions'**
  String get upload_reports_and_previous_prescriptions;

  /// No description provided for @format_will_be_jpg_png_pdf.
  ///
  /// In en, this message translates to:
  /// **'Format will be JPG, PNG, PDF'**
  String get format_will_be_jpg_png_pdf;

  /// No description provided for @max_attachments.
  ///
  /// In en, this message translates to:
  /// **'Max Attachments'**
  String get max_attachments;

  /// No description provided for @select_your_patient.
  ///
  /// In en, this message translates to:
  /// **'Select your patient'**
  String get select_your_patient;

  /// No description provided for @capture_image.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get capture_image;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get select_image;

  /// No description provided for @please_give_title.
  ///
  /// In en, this message translates to:
  /// **'Please give title'**
  String get please_give_title;

  /// No description provided for @please_select_a_prescription.
  ///
  /// In en, this message translates to:
  /// **'Please select a prescription'**
  String get please_select_a_prescription;

  /// No description provided for @please_select_your_patient.
  ///
  /// In en, this message translates to:
  /// **'Please select your patient'**
  String get please_select_your_patient;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @you_dont_have_any_notification.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any notification'**
  String get you_dont_have_any_notification;

  /// No description provided for @add_photo.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get add_photo;

  /// No description provided for @patient_name.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patient_name;

  /// No description provided for @enter_patient_name.
  ///
  /// In en, this message translates to:
  /// **'Enter patient name'**
  String get enter_patient_name;

  /// No description provided for @select_date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get select_date_of_birth;

  /// No description provided for @enter_weight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enter_weight;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @relation_with_you_optional.
  ///
  /// In en, this message translates to:
  /// **'Relation with you (Optional)'**
  String get relation_with_you_optional;

  /// No description provided for @relation_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Son, Daughter, Spouse'**
  String get relation_hint;

  /// No description provided for @save_patient_profile.
  ///
  /// In en, this message translates to:
  /// **'Save Patient Profile'**
  String get save_patient_profile;

  /// No description provided for @please_enter_your_information.
  ///
  /// In en, this message translates to:
  /// **'Please enter\nyour information'**
  String get please_enter_your_information;

  /// No description provided for @save_continue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get save_continue;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @proceed_next.
  ///
  /// In en, this message translates to:
  /// **'Proceed Next'**
  String get proceed_next;

  /// No description provided for @invalid_appointment_data.
  ///
  /// In en, this message translates to:
  /// **'Invalid appointment data. Please start the booking flow again.'**
  String get invalid_appointment_data;

  /// No description provided for @do_you_have_any_promo_code.
  ///
  /// In en, this message translates to:
  /// **'Do you have any promo code?'**
  String get do_you_have_any_promo_code;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @pay_now.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get pay_now;

  /// No description provided for @payment_gateway.
  ///
  /// In en, this message translates to:
  /// **'Payment Gateway'**
  String get payment_gateway;

  /// No description provided for @doctor_info.
  ///
  /// In en, this message translates to:
  /// **'Doctor info'**
  String get doctor_info;

  /// No description provided for @patient_info.
  ///
  /// In en, this message translates to:
  /// **'Patient info'**
  String get patient_info;

  /// No description provided for @payment_details.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get payment_details;

  /// No description provided for @vat_five_percent.
  ///
  /// In en, this message translates to:
  /// **'Vat (5%)'**
  String get vat_five_percent;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @appointment_reason_optional.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reason (Optional)'**
  String get appointment_reason_optional;

  /// No description provided for @describe_the_problem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get describe_the_problem;

  /// No description provided for @describe_problem_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem you\'re facing...'**
  String get describe_problem_hint;

  /// No description provided for @attach_reports_previous_prescriptions_optional.
  ///
  /// In en, this message translates to:
  /// **'Attach reports & previous Prescriptions (Optional)'**
  String get attach_reports_previous_prescriptions_optional;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @please_enter_age_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please enter the age and try again!'**
  String get please_enter_age_try_again;

  /// No description provided for @please_enter_weight_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please enter the weight and try again!'**
  String get please_enter_weight_try_again;

  /// No description provided for @please_enter_problem_description_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please enter the problem description and try again!'**
  String get please_enter_problem_description_try_again;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @profile_data_not_available.
  ///
  /// In en, this message translates to:
  /// **'Profile data not available'**
  String get profile_data_not_available;

  /// No description provided for @please_complete_the_form_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please complete the form and try again!'**
  String get please_complete_the_form_and_try_again;

  /// No description provided for @given_phone_numbers_are_not_the_same.
  ///
  /// In en, this message translates to:
  /// **'Given phone numbers are not the same.'**
  String get given_phone_numbers_are_not_the_same;

  /// No description provided for @we_will_verify_the_new_mobile_number_shortly.
  ///
  /// In en, this message translates to:
  /// **'We will verify the new mobile number shortly.'**
  String get we_will_verify_the_new_mobile_number_shortly;

  /// No description provided for @english_language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english_language;

  /// No description provided for @bangla_language.
  ///
  /// In en, this message translates to:
  /// **'Bangla'**
  String get bangla_language;

  /// No description provided for @english_language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english_language_subtitle;

  /// No description provided for @bangla_language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla_language_subtitle;

  /// No description provided for @payment_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get payment_terms_title;

  /// No description provided for @payment_terms_heading.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms & Conditions'**
  String get payment_terms_heading;

  /// No description provided for @payment_terms_last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: December 2024'**
  String get payment_terms_last_updated;

  /// No description provided for @payment_terms_section_1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Payment Methods'**
  String get payment_terms_section_1_title;

  /// No description provided for @payment_terms_section_1_body.
  ///
  /// In en, this message translates to:
  /// **'• Credit/Debit Cards (Visa, MasterCard, American Express)\n• Digital Wallets (Apple Pay, Google Pay)\n• Bank Transfers\n• Insurance Payments\n• Payment Plans'**
  String get payment_terms_section_1_body;

  /// No description provided for @payment_terms_section_2_title.
  ///
  /// In en, this message translates to:
  /// **'2. Consultation Fees'**
  String get payment_terms_section_2_title;

  /// No description provided for @payment_terms_section_2_body.
  ///
  /// In en, this message translates to:
  /// **'• Initial Consultation: \$50-\$150\n• Follow-up Consultation: \$30-\$100\n• Emergency Consultation: \$100-\$300\n• Video Consultation: \$40-\$120\n• In-Person Consultation: \$60-\$200'**
  String get payment_terms_section_2_body;

  /// No description provided for @payment_terms_section_3_title.
  ///
  /// In en, this message translates to:
  /// **'3. Payment Timing'**
  String get payment_terms_section_3_title;

  /// No description provided for @payment_terms_section_3_body.
  ///
  /// In en, this message translates to:
  /// **'• Payment required before consultation start\n• Pre-authorization for estimated costs\n• Final settlement within 24 hours\n• Automatic billing for completed services'**
  String get payment_terms_section_3_body;

  /// No description provided for @payment_terms_section_4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Refund Policy'**
  String get payment_terms_section_4_title;

  /// No description provided for @payment_terms_section_4_body.
  ///
  /// In en, this message translates to:
  /// **'• Full refund for cancellations 24+ hours before\n• 50% refund for cancellations 2-24 hours before\n• No refund for cancellations less than 2 hours before\n• Full refund for service provider cancellations'**
  String get payment_terms_section_4_body;

  /// No description provided for @payment_terms_section_5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Insurance Coverage'**
  String get payment_terms_section_5_title;

  /// No description provided for @payment_terms_section_5_body.
  ///
  /// In en, this message translates to:
  /// **'• We accept most major insurance plans\n• Pre-authorization available\n• Co-pays and deductibles apply\n• Direct billing to insurance companies\n• Out-of-network options available'**
  String get payment_terms_section_5_body;

  /// No description provided for @payment_terms_section_6_title.
  ///
  /// In en, this message translates to:
  /// **'6. Payment Security'**
  String get payment_terms_section_6_title;

  /// No description provided for @payment_terms_section_6_body.
  ///
  /// In en, this message translates to:
  /// **'• PCI-DSS compliant payment processing\n• Encrypted transactions\n• Secure data storage\n• Fraud detection systems\n• Regular security audits'**
  String get payment_terms_section_6_body;

  /// No description provided for @payment_terms_section_7_title.
  ///
  /// In en, this message translates to:
  /// **'7. Disputed Charges'**
  String get payment_terms_section_7_title;

  /// No description provided for @payment_terms_section_7_body.
  ///
  /// In en, this message translates to:
  /// **'• Contact support within 30 days\n• Provide detailed dispute information\n• Investigation within 5-7 business days\n• Resolution within 14 days\n• Temporary credit during investigation'**
  String get payment_terms_section_7_body;

  /// No description provided for @payment_terms_section_8_title.
  ///
  /// In en, this message translates to:
  /// **'8. Late Payment Fees'**
  String get payment_terms_section_8_title;

  /// No description provided for @payment_terms_section_8_body.
  ///
  /// In en, this message translates to:
  /// **'• 2% monthly interest on overdue amounts\n• \$25 late payment fee after 30 days\n• Service suspension for accounts 60+ days overdue\n• Collection agency referral after 90 days'**
  String get payment_terms_section_8_body;

  /// No description provided for @payment_terms_section_9_title.
  ///
  /// In en, this message translates to:
  /// **'9. Currency and Taxes'**
  String get payment_terms_section_9_title;

  /// No description provided for @payment_terms_section_9_body.
  ///
  /// In en, this message translates to:
  /// **'• All prices in USD\n• Applicable taxes added at checkout\n• Currency conversion fees may apply\n• Local tax regulations followed'**
  String get payment_terms_section_9_body;

  /// No description provided for @payment_terms_section_10_title.
  ///
  /// In en, this message translates to:
  /// **'10. Contact Information'**
  String get payment_terms_section_10_title;

  /// No description provided for @payment_terms_section_10_body.
  ///
  /// In en, this message translates to:
  /// **'For payment-related questions:\nEmail: billing@eyebuddy.app\nPhone: +1-800-BILL-EYE\nHours: Monday-Friday, 9AM-6PM EST'**
  String get payment_terms_section_10_body;

  /// No description provided for @terms_conditions_title.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_conditions_title;

  /// No description provided for @terms_conditions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'BEH Teleophthalmology'**
  String get terms_conditions_subtitle;

  /// No description provided for @terms_conditions_effective_date.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: 17 August 2025'**
  String get terms_conditions_effective_date;

  /// No description provided for @terms_conditions_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions - BEH Teleophthalmology'**
  String get terms_conditions_intro_title;

  /// No description provided for @terms_conditions_intro_body.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: 17 August 2025\n\nThese Terms & Conditions (\"Terms\") govern your use of the BEH Teleophthalmology mobile applications, including the BEH Patient App and BEH Doctor App (together, the \"Apps\"). By accessing or using our Apps, you agree to these Terms. If you do not agree, please do not use the Apps.'**
  String get terms_conditions_intro_body;

  /// No description provided for @terms_conditions_section_1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Definitions'**
  String get terms_conditions_section_1_title;

  /// No description provided for @terms_conditions_section_1_body.
  ///
  /// In en, this message translates to:
  /// **'Patient - a registered user of the BEH Patient App who books consultations.\nDoctor - a registered and licensed medical professional using the BEH Doctor App to provide consultations.\nServices - tele-consultations, prescription generation, and related features offered through the Apps.\nBEH - Bangladesh Eye Hospital & Institute, operator of the BEH Teleophthalmology platform.'**
  String get terms_conditions_section_1_body;

  /// No description provided for @terms_conditions_section_2_title.
  ///
  /// In en, this message translates to:
  /// **'2. Eligibility'**
  String get terms_conditions_section_2_title;

  /// No description provided for @terms_conditions_section_2_body.
  ///
  /// In en, this message translates to:
  /// **'Patients must be at least 18 years old or have parental/guardian supervision.\nDoctors must be licensed ophthalmologists or qualified specialists with verified credentials.\nBy using the Apps, you confirm that you meet these eligibility criteria.'**
  String get terms_conditions_section_2_body;

  /// No description provided for @terms_conditions_section_3_title.
  ///
  /// In en, this message translates to:
  /// **'3. Use of Services'**
  String get terms_conditions_section_3_title;

  /// No description provided for @terms_conditions_section_3_body.
  ///
  /// In en, this message translates to:
  /// **'For Patients:\n- You may select a doctor, upload eye images and medical details, pay consultation fees, and receive prescriptions.\n- You are responsible for ensuring the accuracy of medical information provided.\n\nFor Doctors:\n- You may review patient data, conduct consultations, and issue prescriptions.\n- You are responsible for the accuracy of diagnoses, treatment advice, and prescriptions provided.\n- You may add bank account details to receive earnings securely.'**
  String get terms_conditions_section_3_body;

  /// No description provided for @terms_conditions_section_4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Payments'**
  String get terms_conditions_section_4_title;

  /// No description provided for @terms_conditions_section_4_body.
  ///
  /// In en, this message translates to:
  /// **'Patients agree to pay consultation fees as displayed in the App.\nPayments are processed via secure third-party payment providers.\nBEH deducts applicable platform/processing fees before disbursing payments to doctors.\nDoctors are responsible for any tax obligations arising from earnings.'**
  String get terms_conditions_section_4_body;

  /// No description provided for @terms_conditions_section_5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Medical Disclaimer'**
  String get terms_conditions_section_5_title;

  /// No description provided for @terms_conditions_section_5_body.
  ///
  /// In en, this message translates to:
  /// **'BEH Teleophthalmology provides a digital platform only and is not a medical provider itself.\nDoctors are independent professionals responsible for the advice and prescriptions they provide.\nTele-consultations may not replace physical examinations. Patients should seek in-person care if symptoms worsen or in case of emergencies.'**
  String get terms_conditions_section_5_body;

  /// No description provided for @terms_conditions_section_6_title.
  ///
  /// In en, this message translates to:
  /// **'6. User Responsibilities'**
  String get terms_conditions_section_6_title;

  /// No description provided for @terms_conditions_section_6_body.
  ///
  /// In en, this message translates to:
  /// **'Users must keep login credentials secure and confidential.\nUsers must not misuse the Apps for unlawful or fraudulent activity.\nDoctors must provide care consistent with professional medical standards.\nPatients must follow prescribed treatments responsibly and inform doctors of all relevant health history.'**
  String get terms_conditions_section_6_body;

  /// No description provided for @terms_conditions_section_7_title.
  ///
  /// In en, this message translates to:
  /// **'7. Data Privacy'**
  String get terms_conditions_section_7_title;

  /// No description provided for @terms_conditions_section_7_body.
  ///
  /// In en, this message translates to:
  /// **'All data use is governed by our Privacy Policy (last updated 17 August 2025).\nPatients consent to share medical data with selected doctors for consultation purposes.\nDoctors consent to provide professional details for verification and payment.'**
  String get terms_conditions_section_7_body;

  /// No description provided for @terms_conditions_section_8_title.
  ///
  /// In en, this message translates to:
  /// **'8. Limitations of Liability'**
  String get terms_conditions_section_8_title;

  /// No description provided for @terms_conditions_section_8_body.
  ///
  /// In en, this message translates to:
  /// **'BEH is not liable for medical outcomes, treatment errors, or misdiagnosis by doctors.\nBEH is not liable for payment disputes between patients and doctors beyond transaction facilitation.\nBEH is not responsible for technical failures caused by internet providers, mobile devices, or external services.'**
  String get terms_conditions_section_8_body;

  /// No description provided for @terms_conditions_section_9_title.
  ///
  /// In en, this message translates to:
  /// **'9. Termination of Accounts'**
  String get terms_conditions_section_9_title;

  /// No description provided for @terms_conditions_section_9_body.
  ///
  /// In en, this message translates to:
  /// **'BEH may suspend or terminate accounts that violate these Terms, including fraudulent activity, misuse, or unprofessional conduct.\nUsers may request account closure at any time (subject to legal/medical record retention requirements).'**
  String get terms_conditions_section_9_body;

  /// No description provided for @terms_conditions_section_10_title.
  ///
  /// In en, this message translates to:
  /// **'10. Modifications to Services'**
  String get terms_conditions_section_10_title;

  /// No description provided for @terms_conditions_section_10_body.
  ///
  /// In en, this message translates to:
  /// **'BEH reserves the right to update, suspend, or discontinue features or services without prior notice.'**
  String get terms_conditions_section_10_body;

  /// No description provided for @terms_conditions_section_11_title.
  ///
  /// In en, this message translates to:
  /// **'11. Governing Law & Disputes'**
  String get terms_conditions_section_11_title;

  /// No description provided for @terms_conditions_section_11_body.
  ///
  /// In en, this message translates to:
  /// **'These Terms are governed by the laws of Bangladesh.\nAny disputes shall be subject to the jurisdiction of courts in Dhaka, Bangladesh.'**
  String get terms_conditions_section_11_body;

  /// No description provided for @terms_conditions_section_12_title.
  ///
  /// In en, this message translates to:
  /// **'12. Contact Us'**
  String get terms_conditions_section_12_title;

  /// No description provided for @terms_conditions_section_12_body.
  ///
  /// In en, this message translates to:
  /// **'For questions about these Terms, please contact:\nBEH Teleophthalmology - Legal Office\n78, Satmasjid Road (West of Road 27), Dhanmondi, Dhaka-1209\nPhone: 10620, 09666787878\nEmail: info@bdeyehospital.com\nWeb: dhanmondi.bdeyehospital.com'**
  String get terms_conditions_section_12_body;

  /// No description provided for @beh_support_hours.
  ///
  /// In en, this message translates to:
  /// **'BEH Support (7 am to 10 pm)'**
  String get beh_support_hours;

  /// No description provided for @beh_support_about.
  ///
  /// In en, this message translates to:
  /// **'Bangladesh Eye Hospital & Institute Ltd. has now become the trendsetter for the eye care sector in the country. Our aim is to serve the community with outstanding patient care and the latest in medical advancements. We have always felt a responsibility to offer healthcare consumers the latest in advanced eye care at an affordable cost with a focus on superior customer service.'**
  String get beh_support_about;

  /// No description provided for @cant_make_a_call_now.
  ///
  /// In en, this message translates to:
  /// **'Can\'t make a call now'**
  String get cant_make_a_call_now;

  /// No description provided for @whatsapp_not_installed.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed on the device'**
  String get whatsapp_not_installed;

  /// No description provided for @whatsapp_default_message.
  ///
  /// In en, this message translates to:
  /// **'Hi, I need some help'**
  String get whatsapp_default_message;

  /// No description provided for @privacy_policy_subtitle.
  ///
  /// In en, this message translates to:
  /// **'BEH Teleophthalmology'**
  String get privacy_policy_subtitle;

  /// No description provided for @privacy_policy_effective_date.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: 17 August 2025'**
  String get privacy_policy_effective_date;

  /// No description provided for @privacy_policy_last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: 17 August 2025'**
  String get privacy_policy_last_updated;

  /// No description provided for @privacy_policy_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy - BEH Teleophthalmology'**
  String get privacy_policy_intro_title;

  /// No description provided for @privacy_policy_intro_body.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: 17 August 2025\nLast Updated: 17 August 2025\n\nBEH Teleophthalmology (\"BEH\", \"we,\" \"our,\" or \"us\") operates two applications:\nBEH Patient App - for patients to book tele-consultations, upload eye images, share health information, and receive prescriptions.\nBEH Doctor App - for licensed ophthalmologists to provide tele-consultations, review patient information, and receive payments for services.\n\nWe are committed to protecting the privacy and security of your personal, medical, and financial information. This Privacy Policy explains how we collect, use, disclose, and safeguard your data when you use our services.'**
  String get privacy_policy_intro_body;

  /// No description provided for @privacy_policy_section_1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacy_policy_section_1_title;

  /// No description provided for @privacy_policy_section_1_body.
  ///
  /// In en, this message translates to:
  /// **'From Patients (via BEH Patient App):\n- Personal Identification: Name, phone number, email, gender, age, and contact details.\n- Medical Information: Eye images, diagnostic results, consultation history, prescriptions, and symptoms you provide.\n- Payment Information: Transaction details when you pay for tele-consultations (processed by secure third-party payment providers).\n\nFrom Doctors (via BEH Doctor App):\n- Professional Information: Name, registration number, specialty, qualifications, and contact details.\n- Consultation Data: Prescriptions created, consultation notes, and reviews of patient information.\n- Financial Information: Bank account details for secure withdrawal of consultation earnings.\n\nAutomatically Collected Data:\n- Device type, operating system, IP address.\n- App usage logs, crash reports, session activity.\n- Cookies or tracking tools (for performance and security).'**
  String get privacy_policy_section_1_body;

  /// No description provided for @privacy_policy_section_2_title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacy_policy_section_2_title;

  /// No description provided for @privacy_policy_section_2_body.
  ///
  /// In en, this message translates to:
  /// **'We use information for:\n- Enabling patients to choose doctors, upload images, and receive tele-consultations.\n- Allowing doctors to review patient data, provide consultations, and issue prescriptions.\n- Processing payments and withdrawals securely.\n- Maintaining medical records for continuity of care.\n- Meeting legal, ethical, and regulatory obligations.\n- Improving our apps\' functionality, safety, and user experience.'**
  String get privacy_policy_section_2_body;

  /// No description provided for @privacy_policy_section_3_title.
  ///
  /// In en, this message translates to:
  /// **'3. How We Store and Protect Data'**
  String get privacy_policy_section_3_title;

  /// No description provided for @privacy_policy_section_3_body.
  ///
  /// In en, this message translates to:
  /// **'All sensitive data is encrypted in transit and at rest.\nMedical records are securely stored in compliance with healthcare data standards.\nPayment processing is handled by trusted third-party providers; BEH never stores full payment card details.\nDoctor bank account details are encrypted and used only for payouts.\nAccess to sensitive data is strictly limited to authorized personnel.'**
  String get privacy_policy_section_3_body;

  /// No description provided for @privacy_policy_section_4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Sharing of Information'**
  String get privacy_policy_section_4_title;

  /// No description provided for @privacy_policy_section_4_body.
  ///
  /// In en, this message translates to:
  /// **'We never sell or rent your data. Information may only be shared:\n- With your consent (e.g., when patients choose to share data with a doctor).\n- With secure service providers (e.g., cloud hosting, payment gateways) under confidentiality agreements.\n- To comply with laws, court orders, or government requests.\n- To protect safety, prevent fraud, or ensure secure operation of the Apps.'**
  String get privacy_policy_section_4_body;

  /// No description provided for @privacy_policy_section_5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Data Retention'**
  String get privacy_policy_section_5_title;

  /// No description provided for @privacy_policy_section_5_body.
  ///
  /// In en, this message translates to:
  /// **'Patient records are retained for as long as required by medical regulations.\nDoctor payout and transaction records are retained for financial compliance.\nUsers may request deletion of accounts (subject to retention laws).'**
  String get privacy_policy_section_5_body;

  /// No description provided for @privacy_policy_section_6_title.
  ///
  /// In en, this message translates to:
  /// **'6. Your Rights'**
  String get privacy_policy_section_6_title;

  /// No description provided for @privacy_policy_section_6_body.
  ///
  /// In en, this message translates to:
  /// **'You may have rights under applicable data protection laws, including:\n- Accessing your data.\n- Correcting inaccurate information.\n- Requesting deletion of personal data.\n- Withdrawing consent to processing (where applicable).\n- Filing a complaint with your local data authority.'**
  String get privacy_policy_section_6_body;

  /// No description provided for @privacy_policy_section_7_title.
  ///
  /// In en, this message translates to:
  /// **'7. Children\'s Privacy'**
  String get privacy_policy_section_7_title;

  /// No description provided for @privacy_policy_section_7_body.
  ///
  /// In en, this message translates to:
  /// **'BEH Patient is intended for adults (18+) or minors under parental/guardian supervision. We do not knowingly collect data from children without consent.'**
  String get privacy_policy_section_7_body;

  /// No description provided for @privacy_policy_section_8_title.
  ///
  /// In en, this message translates to:
  /// **'8. Security Commitment'**
  String get privacy_policy_section_8_title;

  /// No description provided for @privacy_policy_section_8_body.
  ///
  /// In en, this message translates to:
  /// **'We apply strict technical, administrative, and physical safeguards to protect your data. However, no system is completely secure. Users are advised to keep login credentials confidential.'**
  String get privacy_policy_section_8_body;

  /// No description provided for @privacy_policy_section_9_title.
  ///
  /// In en, this message translates to:
  /// **'9. Updates to this Privacy Policy'**
  String get privacy_policy_section_9_title;

  /// No description provided for @privacy_policy_section_9_body.
  ///
  /// In en, this message translates to:
  /// **'We may update this Privacy Policy from time to time. Updates will be reflected in the Apps with the revised date. Continued use of the Apps after updates means you accept the new terms.'**
  String get privacy_policy_section_9_body;

  /// No description provided for @privacy_policy_section_10_title.
  ///
  /// In en, this message translates to:
  /// **'10. Contact Us'**
  String get privacy_policy_section_10_title;

  /// No description provided for @privacy_policy_section_10_body.
  ///
  /// In en, this message translates to:
  /// **'For questions, concerns, or data requests, please contact:\nBEH Teleophthalmology - Privacy Office\n78, Satmasjid Road (West of Road 27), Dhanmondi, Dhaka-1209\nPhone: 10620, 09666787878\nEmail: info@bdeyehospital.com\nWeb: dhanmondi.bdeyehospital.com'**
  String get privacy_policy_section_10_body;

  /// No description provided for @weight_max_999.
  ///
  /// In en, this message translates to:
  /// **'Weight must be 999 or less'**
  String get weight_max_999;

  /// No description provided for @you_dont_have_any_promo.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any promo'**
  String get you_dont_have_any_promo;

  /// No description provided for @apply_code.
  ///
  /// In en, this message translates to:
  /// **'Apply code'**
  String get apply_code;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @promo_applied.
  ///
  /// In en, this message translates to:
  /// **'Promo applied'**
  String get promo_applied;

  /// No description provided for @promo_removed.
  ///
  /// In en, this message translates to:
  /// **'Promo removed'**
  String get promo_removed;

  /// No description provided for @you_dont_have_any_transactions_history.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any transactions history'**
  String get you_dont_have_any_transactions_history;

  /// No description provided for @general_support.
  ///
  /// In en, this message translates to:
  /// **'General support'**
  String get general_support;

  /// No description provided for @emergency_hotline.
  ///
  /// In en, this message translates to:
  /// **'Emergency hotline'**
  String get emergency_hotline;

  /// No description provided for @type_a_message_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Type a message to continue'**
  String get type_a_message_to_continue;

  /// No description provided for @thanks_for_reaching_out.
  ///
  /// In en, this message translates to:
  /// **'Thanks for reaching out. We will connect you to a specialist shortly.'**
  String get thanks_for_reaching_out;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get mins;

  /// No description provided for @unknown_doctor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Doctor'**
  String get unknown_doctor;

  /// No description provided for @invalid_promo.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo'**
  String get invalid_promo;

  /// No description provided for @invalid_appointment_context.
  ///
  /// In en, this message translates to:
  /// **'Missing appointment context'**
  String get invalid_appointment_context;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @speciality.
  ///
  /// In en, this message translates to:
  /// **'Speciality'**
  String get speciality;

  /// No description provided for @clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// No description provided for @select_a_type.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get select_a_type;

  /// No description provided for @up_to_4.
  ///
  /// In en, this message translates to:
  /// **'Up to 4'**
  String get up_to_4;

  /// No description provided for @up_to_4_5.
  ///
  /// In en, this message translates to:
  /// **'Up to 4.5'**
  String get up_to_4_5;

  /// No description provided for @no_patient_found.
  ///
  /// In en, this message translates to:
  /// **'No patient found'**
  String get no_patient_found;

  /// No description provided for @given_phone_numbers_not_valid.
  ///
  /// In en, this message translates to:
  /// **'Given phone numbers are not valid.'**
  String get given_phone_numbers_not_valid;

  /// No description provided for @missing_trace_id.
  ///
  /// In en, this message translates to:
  /// **'Missing traceId'**
  String get missing_trace_id;

  /// No description provided for @otp_resent.
  ///
  /// In en, this message translates to:
  /// **'OTP resent'**
  String get otp_resent;

  /// No description provided for @failed_to_resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP'**
  String get failed_to_resend_otp;

  /// No description provided for @please_enter_patient_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter patient name'**
  String get please_enter_patient_name;

  /// No description provided for @please_enter_date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Please enter date of birth'**
  String get please_enter_date_of_birth;

  /// No description provided for @please_enter_weight.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight'**
  String get please_enter_weight;

  /// No description provided for @please_select_gender.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get please_select_gender;

  /// No description provided for @please_enter_relation.
  ///
  /// In en, this message translates to:
  /// **'Please enter relation'**
  String get please_enter_relation;

  /// No description provided for @patient_added.
  ///
  /// In en, this message translates to:
  /// **'Patient added!'**
  String get patient_added;

  /// No description provided for @failed_to_save_patient_profile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save patient profile'**
  String get failed_to_save_patient_profile;

  /// No description provided for @update_medication.
  ///
  /// In en, this message translates to:
  /// **'Update Medication'**
  String get update_medication;

  /// No description provided for @please_enter_title.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get please_enter_title;

  /// No description provided for @please_add_time.
  ///
  /// In en, this message translates to:
  /// **'Please add time'**
  String get please_add_time;

  /// No description provided for @please_add_day.
  ///
  /// In en, this message translates to:
  /// **'Please add day'**
  String get please_add_day;

  /// No description provided for @medication_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Medication updated successfully'**
  String get medication_updated_successfully;

  /// No description provided for @medication_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Medication created successfully'**
  String get medication_created_successfully;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @waiting_for_prescription.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Prescription'**
  String get waiting_for_prescription;

  /// No description provided for @please_wait_doctor_will_send_prescription.
  ///
  /// In en, this message translates to:
  /// **'Please wait! Doctor will send the prescription very soon'**
  String get please_wait_doctor_will_send_prescription;

  /// No description provided for @you_can_leave_prescription_will_show_under_all_prescriptions.
  ///
  /// In en, this message translates to:
  /// **'You can leave from this screen. Prescription will show Under All Prescriptions. Thanks for being with us. We wish for your good health.'**
  String get you_can_leave_prescription_will_show_under_all_prescriptions;

  /// No description provided for @go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get go_back;

  /// No description provided for @send_results_to_doctor.
  ///
  /// In en, this message translates to:
  /// **'Send Results to Doctor'**
  String get send_results_to_doctor;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @send_results.
  ///
  /// In en, this message translates to:
  /// **'Send Results'**
  String get send_results;

  /// No description provided for @patient_profile_not_found.
  ///
  /// In en, this message translates to:
  /// **'Patient profile not found.'**
  String get patient_profile_not_found;

  /// No description provided for @doctor_not_found.
  ///
  /// In en, this message translates to:
  /// **'Doctor not found.'**
  String get doctor_not_found;

  /// No description provided for @please_review_my_recent_eye_test_results.
  ///
  /// In en, this message translates to:
  /// **'Please review my recent eye test results.'**
  String get please_review_my_recent_eye_test_results;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @your_results_have_been_sent_to.
  ///
  /// In en, this message translates to:
  /// **'Your results have been sent to {doctorName}.'**
  String your_results_have_been_sent_to(Object doctorName);

  /// No description provided for @the_doctor.
  ///
  /// In en, this message translates to:
  /// **'the doctor'**
  String get the_doctor;

  /// No description provided for @failed_to_send_results_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Failed to send results. Please try again.'**
  String get failed_to_send_results_please_try_again;

  /// No description provided for @enter_all_fields_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'Enter all fields and try again!'**
  String get enter_all_fields_and_try_again;

  /// No description provided for @failed_to_save_profile_data.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile data'**
  String get failed_to_save_profile_data;

  /// No description provided for @review_cannot_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Review cannot be empty'**
  String get review_cannot_be_empty;

  /// No description provided for @an_error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get an_error_occurred;

  /// No description provided for @login_successful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_successful;

  /// No description provided for @phone_number_successfully_changed.
  ///
  /// In en, this message translates to:
  /// **'Phone number successfully changed'**
  String get phone_number_successfully_changed;

  /// No description provided for @invalid_otp_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalid_otp_please_try_again;

  /// No description provided for @server_error_occurred_please_try_again_later.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get server_error_occurred_please_try_again_later;

  /// No description provided for @something_went_wrong_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get something_went_wrong_please_try_again;

  /// No description provided for @no_internet_connection_please_check_your_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get no_internet_connection_please_check_your_network;

  /// No description provided for @request_timeout_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get request_timeout_please_try_again;

  /// No description provided for @payment_successful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get payment_successful;

  /// No description provided for @copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to Clipboard'**
  String get copied_to_clipboard;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
