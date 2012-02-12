/*

 TODO: pull links from Facebook activity streams
 TODO: pull links from Tweets

 */


CRATER = {
  'musicProviders' : [ 'SPOTIFY', 'TURNTABLE', 'RHAPSODY' ],
  'scannerInterval' : null,
  'facebookActivityFeedTimestamp' : 0,
  'twitterFeedMaxId' : 0
}

CRATER.log = function(m) {
  console.log('CRATER: ' + m);
}

CRATER.init = function() {
  this.log('Scanning!');
  jQuery.noConflict();

  // figure out what page we're on
  var scanner = false;
  var hostname = window.location.hostname;

  CRATER.log("Hostname: " + hostname);

  if ( hostname.match(/\.facebook\.com/i) ) {
    scanner = "CRATER.facebookActivityStreamScanner()";
  }

  if ( hostname.match(/twitter\.com/i) ) {
    scanner = "CRATER.twitterStreamScanner()";
  }

  if ( scanner ) {
    CRATER.log("Starting " + scanner);
    this.scannerInterval = setInterval(scanner, 10000); // 10 seconds
  } else {
    this.log("Couldn't find a scanner for " + hostname);
  }
}

CRATER.halt = function() {
  clearInterval( this.scannerInterval );
}

CRATER.twitterStreamScanner = function() {
  var set_max = 0; // the maximum timestamp for the current set of activity stream messages
  jQuery.each( jQuery('.tweet'), function( idx, ele ) {
    var id = parseInt( jQuery(ele).attr('data-tweet-id') );

    if (id > set_max) { set_max = id; }

    if (id <= CRATER.twitterFeedMaxId) { return; }

    CRATER.log('New Feed Message: ' + jQuery('.js-tweet-text', ele).text() );
  });

  CRATER.twitterFeedMaxId = set_max;
}

CRATER.facebookActivityStreamScanner = function() {
  var set_max = 0 // the maximum timestamp for the current set of activity stream messages

  jQuery.each( jQuery('.fbFeedTickerStory'), function( idx, ele ) {
    // pull out the timestamp
    var ts = parseInt( jQuery(ele).attr('data-ticker-timestamp') )

    // figure out the maximum value for this set of results.
    if (ts > set_max) { set_max = ts; }

    // ignore if it was covered in one of the last runs
    if (ts <= CRATER.facebookActivityFeedTimestamp) { return; }

    // we have new data; go get the content and log it
    var targetEle = jQuery('.tickerFeedMessage', ele);
    CRATER.log('New: ' + jQuery(targetEle).text() );
    CRATER.facebookExtractTrack( targetEle );

  })

  // make sure we don't hit it again.
  CRATER.facebookActivityFeedTimestamp = set_max;
}

CRATER.facebookExtractTrack = function(ele) {
  // .passiveName will provide the name of the person
  // .token will give two results; first is track name, second is the service.

  var name = jQuery('.passiveName', ele).text();
  var tokens = jQuery('.token', ele);

  switch( tokens.length ) {
    case 2:
      var track = jQuery(tokens[0]).text();
      var artist = "";
      var provider = jQuery(tokens[1]).text();
      break;

    case 3:
      var track = jQuery(tokens[0]).text();
      var artist = jQuery(tokens[1]).text();
      var provider = jQuery(tokens[2]).text();
      break;

    default:
      return;
  }

  if (jQuery.inArray( provider.toUpperCase(), CRATER.musicProviders ) > -1) {
    CRATER.recordHit( name, track, artist, provider )
  }

}

CRATER.recordHit = function( user, track, artist, provider ) {
  CRATER.log("FOUND - User:" + user + " Track:" + track + " Artist:" + artist + " Provider:" + provider );
  jQuery.get("http://peat.org/mhd.html", { 'user' : user, 'track' : track, 'artist' : artist, 'provider' : provider });
}

CRATER.init();
