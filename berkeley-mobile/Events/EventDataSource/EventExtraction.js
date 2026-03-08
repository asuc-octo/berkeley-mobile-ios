(function() {
    var results = [];

    // Strategy 1: LiveWhale lw_cal_event format (JS-rendered content)
    var lwEvents = document.querySelectorAll('.lw_cal_event');
    for (var i = 0; i < lwEvents.length; i++) {
        var el = lwEvents[i];
        var elClasses = el.className;
        if (elClasses.indexOf('lw_cal_event_list') !== -1 || elClasses.indexOf('lw_cal_event_info') !== -1) {
            continue;
        }

        var titleEl = el.querySelector('.lw_events_title');
        var title = titleEl ? titleEl.textContent.trim() : '';
        if (!title) continue;

        var linkEl = el.querySelector('.lw_events_title a') || el.querySelector('a');
        var href = linkEl ? linkEl.getAttribute('href') : '';

        var timeEl = el.querySelector('.lw_events_time');
        var time = timeEl ? timeEl.textContent.trim() : '';

        var locationEl = el.querySelector('.lw_events_location');
        var location = locationEl ? locationEl.textContent.trim() : '';

        var summaryEl = el.querySelector('.lw_events_summary');
        var summary = summaryEl ? summaryEl.textContent.trim() : '';

        var imgEl = el.querySelector('img');
        var imgSrc = imgEl ? imgEl.getAttribute('src') : '';

        // Walk previous siblings to find the nearest h3 date header
        var dateText = '';
        var sibling = el.previousElementSibling;
        while (sibling) {
            if (sibling.tagName === 'H3') {
                dateText = sibling.textContent.trim();
                break;
            }
            sibling = sibling.previousElementSibling;
        }

        results.push({
            title: title,
            href: href || '',
            time: time,
            location: location,
            summary: summary,
            imgSrc: imgSrc || '',
            dateText: dateText,
            source: 'lw'
        });
    }

    // Strategy 2: Card-based format (server-rendered featured events)
    if (results.length === 0) {
        var cards = document.querySelectorAll('.featured-event .card');
        for (var j = 0; j < cards.length; j++) {
            var card = cards[j];
            var titleEl2 = card.querySelector('.card-title a') || card.querySelector('.card-title');
            var title2 = titleEl2 ? titleEl2.textContent.trim() : '';
            if (!title2) continue;

            var linkEl2 = card.querySelector('.card-title a') || card.querySelector('a');
            var href2 = linkEl2 ? linkEl2.getAttribute('href') : '';

            var timeEl2 = card.querySelector('.card-text');
            var time2 = timeEl2 ? timeEl2.textContent.trim() : '';

            var monthEl = card.querySelector('.cal_date .month');
            var dayEl = card.querySelector('.cal_date .day');
            var month = monthEl ? monthEl.textContent.trim() : '';
            var day = dayEl ? dayEl.textContent.trim() : '';
            var dateText2 = month && day ? month + ' ' + day : '';

            var imgEl2 = card.querySelector('img');
            var imgSrc2 = imgEl2 ? imgEl2.getAttribute('src') : '';

            results.push({
                title: title2,
                href: href2 || '',
                time: time2,
                location: '',
                summary: '',
                imgSrc: imgSrc2 || '',
                dateText: dateText2,
                source: 'card'
            });
        }
    }

    return JSON.stringify({ count: results.length, events: results });
})();
