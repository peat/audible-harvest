AH = {
  'musicProviders' : [ 'SPOTIFY', 'TURNTABLE', 'RHAPSODY', 'RDIO', 'MOG' ],
  'scannerInterval' : null,
  'facebookActivityFeedTimestamp' : 0,
  'twitterFeedMaxId' : 0,
  'server' : 'http://falling-ice-2711.heroku.com',
  'queue' : [],
  'timeout' : null
}

AH.log = function(m) {
  console.log('AH: ' + m);
}

AH.processQueue = function() {
  if (AH.queue.length > 0) {

    // notifications
    AH.log("Queue Depth: " + AH.queue.length);
    jQuery("#audibleHarvestStatus").text(" (" + AH.queue.length + " Updates) ");

    var msg = AH.queue.shift() // off the front; opposite of pop()    
    jQuery.post( msg.url, msg.request, function(data) {
      setTimeout("AH.processQueue()", 100); // try running again  
    });
  } else {
    setTimeout("AH.processQueue()", 10000); // check in 10 seconds
    jQuery("#audibleHarvestStatus").text("");
  }
}

AH.init = function() {
  this.log('Scanning!');
  jQuery.noConflict();

  // figure out what page we're on
  var scanner = false;
  var hostname = window.location.hostname;

  AH.log("Hostname: " + hostname);

  if ( hostname.match(/\.facebook\.com/i) ) {
    scanner = "AH.facebookActivityStreamScanner()";
  }

  if ( hostname.match(/twitter\.com/i) ) {
    scanner = "AH.twitterStreamScanner()";
  }

  if ( scanner ) {
    AH.log("Starting " + scanner);
    AH.notification();
    this.scannerInterval = setInterval(scanner, 5000); // 5 seconds
    setInterval("AH.processQueue()", 10000);
  } else {
    this.log("Couldn't find a scanner for " + hostname);
  }
}

AH.halt = function() {
  clearInterval( this.scannerInterval );
}

AH.notification = function() {
  // drop a div a the top of the page with a friendly message.
  jQuery('body').prepend('<div id="audibleHarvest" style="position:absolute; top:0px; z-index:9999; font-size: 10px; padding: 3px;">&nbsp;<a href="' + AH.server + '" target="audibleHarvest">Audible Harvest</a> is Listening <span id="audibleHarvestStatus"></span>&nbsp;</div>');
  jQuery('#audibleHarvest').show();
}

AH.twitterStreamScanner = function() {
  var set_max = 0; // the maximum timestamp for the current set of activity stream messages
  jQuery.each( jQuery('.tweet'), function( idx, ele ) {
    var id = parseInt( jQuery(ele).attr('data-tweet-id') );

    if (id > set_max) { set_max = id; }

    if (id <= AH.twitterFeedMaxId) { return; }

    AH.log('New Feed Message: ' + jQuery('.js-tweet-text', ele).text() );
    AH.twitterExtractUrls(ele);
  });

  AH.twitterFeedMaxId = set_max;
}

AH.twitterExtractUrls = function(ele) {
  // look for 'a' tags within the .js-tweet-text element, and send them to the grinder.
  var as = jQuery('.js-tweet-text a', ele);

  // look for the person as .stream-item-header .username
  var person = jQuery('.stream-item-header .username', ele).text()

  jQuery.each( as, function( idx, aEle ) {
    var url = jQuery(aEle).attr('data-expanded-url');
    if (url != undefined) {
      AH.recordGrind( person, url, 'Twitter' )
    }
  })
}

AH.facebookActivityStreamScanner = function() {
  var set_max = 0 // the maximum timestamp for the current set of activity stream messages

  jQuery.each( jQuery('.fbFeedTickerStory'), function( idx, ele ) {
    // pull out the timestamp
    var ts = parseInt( jQuery(ele).attr('data-ticker-timestamp') )

    // figure out the maximum value for this set of results.
    if (ts > set_max) { set_max = ts; }

    // ignore if it was covered in one of the last runs
    if (ts <= AH.facebookActivityFeedTimestamp) { return; }

    // we have new data; go get the content and log it
    var targetEle = jQuery('.tickerFeedMessage', ele);
    AH.log('New: ' + jQuery(targetEle).text() );
    AH.facebookExtractTrack( targetEle );

  })

  // make sure we don't hit it again.
  AH.facebookActivityFeedTimestamp = set_max;
}

AH.facebookExtractTrack = function(ele) {
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

  if (jQuery.inArray( provider.toUpperCase(), AH.musicProviders ) > -1) {
    AH.recordSnarf( name, track, artist, provider, 'Facebook' )
  }

}

AH.recordSnarf = function( person, track, artist, provider, origin ) {
  AH.log("FOUND - Person:" + person + " Track:" + track + " Artist:" + artist + " Provider:" + provider );
  var url = AH.server + "/snarf" 
  AH.queue.push( { 'url':url, 'request':{ 'person' : person, 'track' : track, 'artist' : artist, 'provider' : provider, 'origin' : origin } } );
}

AH.recordGrind = function( person, url, origin ) {
  AH.log("FOUND - Person:" + person + " URL:" + url + " Origin:" + origin );
  var grind_url = AH.server + "/grind" 
  AH.queue.push( { 'url':grind_url, 'request': { 'person' : person, 'url' : url, 'origin' : origin } } );
}

AH.init();
