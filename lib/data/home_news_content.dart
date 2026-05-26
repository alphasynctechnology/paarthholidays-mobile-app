import '../models/news_model.dart';

class HomeNewsContent {
  HomeNewsContent._();

  static final List<NewsModel> defaults = [
    NewsModel(
      id: '1',
      title: 'Sikkim Group Tour — April Departures Open',
      summary:
          '7 nights / 8 days group tour with Buddha Point, Nathula & local sightseeing. Starting from ₹55,555.',
      body: '''
<p>Book your seat for our popular <strong>Sikkim Group Tour</strong> departing in April.</p>
<ul>
  <li>Duration: 7 nights / 8 days</li>
  <li>Departures: 3 & 23 April</li>
  <li>Starting from ₹55,555 per person</li>
  <li>Includes accommodation, meals & sightseeing</li>
</ul>
<p>Contact us at <strong>+91 86050 70600</strong> or visit www.paarthholidays.com to reserve your spot.</p>
''',
      image: 'https://macha.tours/assets/images/offers/sikkim.jpeg',
      publishedAt: '20 May 2026',
    ),
    NewsModel(
      id: '2',
      title: 'Shimla Summer Special — Limited Seats',
      summary:
          'Beat the heat with a refreshing Shimla getaway. Special summer fares available for group bookings.',
      body: '''
<p>Escape to the hills this summer with our <strong>Shimla Special Package</strong>.</p>
<p>Enjoy scenic drives, Mall Road walks, Kufri excursions and comfortable stays at handpicked hotels.</p>
<p>Group discounts available for 4 or more travellers. Enquire now through the app or call our team.</p>
''',
      image: 'https://macha.tours/assets/images/offers/shimla.jpeg',
      publishedAt: '15 May 2026',
    ),
    NewsModel(
      id: '3',
      title: 'Bali International Tour — New Batch Announced',
      summary:
          'Explore beaches, temples & culture in Bali. All-inclusive international group departure now open.',
      body: '''
<p>Discover the beauty of <strong>Bali, Indonesia</strong> with Paarth Holidays.</p>
<ul>
  <li>Ubud rice terraces & monkey forest</li>
  <li>Beach leisure at Kuta / Seminyak</li>
  <li>Temple visits & cultural experiences</li>
  <li>Guided group tour with experienced tour manager</li>
</ul>
<p>Visit the Enquiry tab in the app or reach us at info@paarthholidays.com for full itinerary and pricing.</p>
''',
      image: 'https://macha.tours/assets/images/offers/bali.jpeg',
      publishedAt: '10 May 2026',
    ),
    NewsModel(
      id: '4',
      title: 'Refer Friends & Earn Wallet Points',
      summary:
          'Share Paarth Holidays with friends and family. Earn reward points on every successful referral booking.',
      body: '''
<p>Our <strong>Refer & Earn</strong> program is now active for all registered users.</p>
<p>When someone you refer completes a booking through Paarth Holidays, you earn wallet points that can be redeemed on future tours.</p>
<p>Check your wallet balance anytime from the wallet icon on the home screen.</p>
''',
      image: '',
      publishedAt: '1 May 2026',
    ),
    NewsModel(
      id: '5',
      title: 'Monsoon Travel Tips from Paarth Holidays',
      summary:
          'Planning a trip during monsoon? Here are packing and safety tips from our travel experts.',
      body: '''
<p>Travelling in the monsoon can be beautiful if you are well prepared. Keep these tips in mind:</p>
<ul>
  <li>Carry a light raincoat and waterproof footwear</li>
  <li>Pack medicines for common travel ailments</li>
  <li>Keep digital copies of ID and booking vouchers</li>
  <li>Check road and weather updates before hill-station trips</li>
</ul>
<p>Need help planning? Our enquiry team is happy to assist you with the best routes and packages.</p>
''',
      image: '',
      publishedAt: '28 Apr 2026',
    ),
  ];
}
