const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const cheerio = require('cheerio');

admin.initializeApp();
const db = admin.firestore();

const GYM_SOURCES = [
  {
    gymId: 'rsf-weight-room',
    gymName: 'RSF Weight Rooms',
    facilityName: 'Recreational Sports Facility (RSF)',
    url: 'https://recwell.berkeley.edu/facilities/recreational-sports-facility-rsf/rsf-weight-room-crowd-meter/'
  },
  {
    gymId: 'cms-fitness',
    gymName: 'CMS Fitness Center',
    facilityName: 'Cal Memorial Stadium Fitness Center',
    url: 'https://recwell.berkeley.edu/facilities/caledonia-memorial-fitness-center-cmf/cmf-weight-room-crowd-meter/'
  }
];

const COLLECTION_NAME = 'Gym Occupancy Meters';

function normalizeDayLabel(rawDay) {
  const day = rawDay.toLowerCase();
  if (day.startsWith('mon')) return 'Monday';
  if (day.startsWith('tue')) return 'Tuesday';
  if (day.startsWith('wed')) return 'Wednesday';
  if (day.startsWith('thu')) return 'Thursday';
  if (day.startsWith('fri')) return 'Friday';
  if (day.startsWith('sat')) return 'Saturday';
  if (day.startsWith('sun')) return 'Sunday';
  return rawDay.trim();
}

function parsePhone(text) {
  const match = text.match(/(?:\+?1[-.\s]*)?\(?([0-9]{3})\)?[-.\s]*([0-9]{3})[-.\s]*([0-9]{4})/);
  if (!match) return null;
  return `(${match[1]}) ${match[2]}-${match[3]}`;
}

function parseOccupancyFromText(text) {
  const percentMatch = text.match(/(\d{1,3})\s*%/);
  if (percentMatch) {
    return parseInt(percentMatch[1], 10);
  }

  const peopleMatch = text.match(/(\d{1,3})\s*(?:people|members|students|users|capacity)/i);
  if (peopleMatch) {
    return parseInt(peopleMatch[1], 10);
  }

  return null;
}

function extractHoursFromTable($, hoursTarget) {
  const rows = [];
  $('table').each((_, table) => {
    $(table).find('tr').each((_, tr) => {
      const cells = $(tr).find('th, td');
      if (cells.length < 2) return;

      const dayText = $(cells[0]).text().trim();
      const timeText = $(cells.slice(1).map((_, cell) => $(cell).text().trim()).get().join(' ')).trim();
      if (/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/i.test(dayText) && timeText.length > 0) {
        hoursTarget[normalizeDayLabel(dayText)] = timeText;
      }
    });
  });
}

function extractHoursFromList($, hoursTarget) {
  $('li').each((_, li) => {
    const text = $(li).text().trim();
    const parts = text.split(/[:\-–—]/).map(part => part.trim());
    if (parts.length < 2) return;

    const dayText = parts[0];
    if (/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/i.test(dayText)) {
      hoursTarget[normalizeDayLabel(dayText)] = parts.slice(1).join(' - ').trim();
    }
  });
}

function extractLabelValues(text, labelPatterns) {
  for (const pattern of labelPatterns) {
    const regex = new RegExp(`${pattern}[:\\s]*([^\\n\\r]+)`, 'i');
    const match = text.match(regex);
    if (match) {
      return match[1].trim();
    }
  }
  return null;
}

async function fetchGymPage(url) {
  const response = await axios.get(url, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; BerkeleyGymScraper/1.0; +https://github.com/asuc-octo/berkeley-mobile-ios)'
    },
    timeout: 20000
  });
  return cheerio.load(response.data);
}

async function scrapeGym(source) {
  const $ = await fetchGymPage(source.url);
  const pageText = $('body').text().replace(/\s+/g, ' ').trim();

  const gymName = $('meta[property="og:title"]').attr('content')?.trim()
    || $('h1').first().text().trim()
    || source.gymName;

  const description = $('meta[name="description"]').attr('content')
    || $('p').first().text().trim()
    || null;

  const phoneNumber = parsePhone(pageText);
  const location = extractLabelValues(pageText, ['Address', 'Location', 'Facility']) || null;

  const hours = {};
  extractHoursFromTable($, hours);
  extractHoursFromList($, hours);

  const occupancySelectors = [
    '[id*=crowd]',
    '[class*=crowd]',
    '[id*=occupancy]',
    '[class*=occupancy]',
    '[id*=meter]',
    '[class*=meter]'
  ];

  let occupancy = null;
  for (const selector of occupancySelectors) {
    const candidate = $(selector).first().text().trim();
    if (candidate) {
      occupancy = parseOccupancyFromText(candidate);
      if (occupancy !== null) break;
    }
  }

  if (occupancy === null) {
    occupancy = parseOccupancyFromText(pageText);
  }

  const additionalInfo = $('.facility-content, .description, .details, .info').first().text().trim() || null;

  return {
    gymId: source.gymId,
    gymName,
    facilityName: source.facilityName,
    location,
    phoneNumber,
    hours: Object.keys(hours).length ? hours : null,
    description,
    additionalInfo,
    occupancyPercentage: occupancy,
    sourcePageUrl: source.url,
    scrapedAt: admin.firestore.FieldValue.serverTimestamp()
  };
}

async function scrapeAndSaveGyms() {
  const results = [];
  for (const source of GYM_SOURCES) {
    try {
      const scraped = await scrapeGym(source);
      const docRef = db.collection(COLLECTION_NAME).doc(source.gymId);
      await docRef.set(scraped, { merge: true });
      results.push({ gymId: source.gymId, success: true, occupancy: scraped.occupancyPercentage });
    } catch (error) {
      results.push({ gymId: source.gymId, success: false, error: error.message });
    }
  }
  return results;
}

exports.scrapeGymOccupancyHttp = functions.https.onRequest(async (req, res) => {
  try {
    const result = await scrapeAndSaveGyms();
    res.status(200).json({ success: true, result });
  } catch (error) {
    console.error('Failed to scrape gyms:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

exports.scrapeGymOccupancySchedule = functions.pubsub.schedule('every 15 minutes').onRun(async () => {
  const result = await scrapeAndSaveGyms();
  console.log('Gym occupancy scrape result:', result);
  return null;
});
