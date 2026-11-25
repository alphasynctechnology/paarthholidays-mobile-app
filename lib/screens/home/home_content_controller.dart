import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/booking_model.dart';
import '../../../models/enquiry_details_model.dart';
import '../../../models/news_model.dart';
import '../../../models/offer_model.dart';
import '../../../models/today_itinerary_model.dart';
import '../../../models/tour_model.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../data/home_news_content.dart';
import 'home_controller.dart';

class HomeContentController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<OfferModel> offers = <OfferModel>[].obs;
  final RxList<TourModel> previousTours = <TourModel>[].obs;
  final RxList<TourModel> groupTours = <TourModel>[].obs;
  final RxList<NewsModel> news = <NewsModel>[].obs;
  final Rxn<TodayItineraryModel> todayItinerary = Rxn<TodayItineraryModel>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final results = await Future.wait([
        _apiService.fetchOffers(),
        _fetchBookings(),
        _apiService.fetchGroupTours(),
        _apiService.fetchNews(),
      ]);

      offers.value = results[0] as List<OfferModel>;
      final bookings = results[1] as List<BookingModel>;
      final userTours = _splitBookings(bookings);
      final apiGroupTours = results[2] as List<TourModel>;
      final apiNews = results[3] as List<NewsModel>;
      news.value = apiNews.isNotEmpty ? apiNews : HomeNewsContent.defaults;

      previousTours.value = userTours.previous;
      groupTours.value = _resolveGroupTours(apiGroupTours, offers);
      await _loadTodayItinerary(bookings);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<BookingModel>> _fetchBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!StorageService(prefs).isLoggedIn) return [];
      return await _apiService.fetchBookings();
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadTodayItinerary(List<BookingModel> bookings) async {
    todayItinerary.value = null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final candidates = bookings.where((booking) {
      if (booking.isBookingDone == '2') return false;
      final departure = _parseDate(booking.departureDate);
      return departure != null && !departure.isAfter(today);
    }).toList();

    candidates.sort((a, b) {
      final dateA = _parseDate(a.departureDate);
      final dateB = _parseDate(b.departureDate);
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    for (final booking in candidates) {
      try {
        final details = await _apiService.fetchEnquiryDetails(booking.enquiryId);
        final departure = _parseDate(booking.departureDate);
        if (departure == null || details.activities.isEmpty) continue;

        final tripDay = today.difference(departure).inDays + 1;
        if (tripDay < 1 || tripDay > details.activities.length) continue;

        final activity = _activityForDay(details.activities, tripDay);
        final hotel = _hotelForToday(details.hotels, today);

        todayItinerary.value = TodayItineraryModel(
          enquiryId: booking.enquiryId,
          planName: booking.planName,
          imageUrl: booking.img,
          tripDay: tripDay,
          totalDays: details.activities.length,
          activity: activity,
          hotelName: hotel?.hotelName,
          hotelCity: hotel?.city,
        );
        return;
      } catch (_) {}
    }
  }

  Activity _activityForDay(List<Activity> activities, int tripDay) {
    for (final activity in activities) {
      final dayNumber = int.tryParse(activity.day.trim());
      if (dayNumber == tripDay) return activity;
    }
    return activities[tripDay - 1];
  }

  Hotel? _hotelForToday(List<Hotel> hotels, DateTime today) {
    for (final hotel in hotels) {
      final checkIn = _parseDate(hotel.checkIn);
      final checkOut = _parseDate(hotel.checkOut);
      if (checkIn == null || checkOut == null) continue;
      if (!today.isBefore(checkIn) && !today.isAfter(checkOut)) {
        return hotel;
      }
    }
    return null;
  }

  _UserTours _splitBookings(List<BookingModel> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final previous = <TourModel>[];

    for (final booking in bookings) {
      final tour = _bookingToTour(booking);
      final departure = _parseDate(booking.departureDate);

      if (departure != null) {
        if (departure.isBefore(today)) {
          previous.add(tour);
        }
      } else if (booking.isBookingDone == '4') {
        previous.add(tour);
      }
    }

    previous.sort((a, b) {
      final dateA = _parseDate(a.departureDate);
      final dateB = _parseDate(b.departureDate);
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    return _UserTours(previous: previous);
  }

  List<TourModel> _resolveGroupTours(
    List<TourModel> apiTours,
    List<OfferModel> offerList,
  ) {
    if (apiTours.isNotEmpty) return apiTours;

    return offerList
        .map(
          (offer) => TourModel(
            id: offer.name,
            name: offer.name,
            image: offer.image,
            url: offer.url,
          ),
        )
        .toList();
  }

  TourModel _bookingToTour(BookingModel booking) {
    return TourModel(
      id: booking.enquiryId,
      name: booking.planName,
      image: booking.img,
      departureDate: booking.departureDate,
    );
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;

    final formats = [
      'd MMMM yyyy',
      'dd MMMM yyyy',
      'd MMM yyyy',
      'dd MMM yyyy',
      'd, dd MMMM yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
    ];

    for (final pattern in formats) {
      try {
        return DateFormat(pattern).parse(value);
      } catch (_) {}
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  void goToBookings() {
    final homeController = Get.find<HomeController>();
    homeController.changeTabIndex(1);
  }

  void goToEnquiry() {
    final homeController = Get.find<HomeController>();
    homeController.changeTabIndex(2);
  }
}

class _UserTours {
  final List<TourModel> previous;

  const _UserTours({required this.previous});
}
