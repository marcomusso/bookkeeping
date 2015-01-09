var mySessionData={};
var myGlobalEnvLookup={};

function round(num,decimals) {
    return Math.round(num * Math.pow(10, decimals)) / Math.pow(10, decimals);
}

function sortObjectByKey(obj) {
  var keys = [];
  var sorted_obj = {};

  for(var key in obj){
      if(obj.hasOwnProperty(key)){
          keys.push(key);
      }
  }

  // sort keys
  keys.sort();

  // create new array based on Sorted Keys
  jQuery.each(keys, function(i, key){
      sorted_obj[key] = obj[key];
  });

  return sorted_obj;
}

function uniqueArray(a) {
    return a.reduce(function(p, c) {
        if (p.indexOf(c) < 0) p.push(c);
        return p;
    }, []);
}

// loading indicator
  function spinThatWheel(state) {
    // state: true/false
    if (state) {
      $("#loading").addClass('fa-spin');
      $("#loading").show();
    } else {
      $("#loading").removeClass('fa-spin');
      $("#loading").hide();
    }
  }

// available themes
  var themes = {
    "default"  : "/bootstrap-3.3.1/css/bootstrap-theme.css",
    "cosmo"    : "/css/bootstrap-themes/bootstrap-cosmo.min.css",
    "flatly"   : "/css/bootstrap-themes/bootstrap-flatly.min.css",
    "slate"    : "/css/bootstrap-themes/bootstrap-slate.min.css",
    "spacelab" : "/css/bootstrap-themes/bootstrap-spacelab.min.css",
    "yeti"     : "/css/bootstrap-themes/bootstrap-yeti.min.css"
  };

// save session
  function setSession() {
    console.log( "setSession called" );
    $.post( "/api/setSession",
      JSON.stringify(mySessionData)
    ).fail(function() {
      alert( "Unable to save session. Please contact support." );
    });
  }

// no sleep! :)
  function sleep(milliseconds) {
    // http://stackoverflow.com/questions/951021/what-do-i-do-if-i-want-a-javascript-version-of-sleep
  }

// user feeedback, the growl way
  function alertThis(message,severity,icon) {
    if (icon === undefined) {
      icon='fa fa-warning';
    }
    if (severity === undefined) {
      icon='info';
    }
    if (message === undefined) {
      console.log('alertThis called without message parameter!');
      return false;
    }
    $.growl({
      message: message,
      icon: icon
    },{
      element: 'body',
      allow_dismiss: true,
      placement: {
        from: "top",
        align: "center"
      },
      offset: 20,
      spacing: 10,
      animate: {
        enter: 'animated fadeInLeftBig',
        exit: 'animated fadeOutRightBig'
      },
      type: severity,
      delay: 3000,
      template: '<div data-growl="container" class="alert" role="alert">' +
                    '<button type="button" class="close" data-growl="dismiss">' +
                      '<span aria-hidden="true">×</span>' +
                      '<span class="sr-only">Close</span>' +
                    '</button>' +
                    '<span data-growl="icon"></span>&nbsp;' +
                    '<span data-growl="title"></span>' +
                    '<span data-growl="message"></span>' +
                    '<a href="#" data-growl="url"></a>' +
                 '</div>'
    });
  }

$("document").ready(function() {
  spinThatWheel(false);
  $("#saved").fadeOut();
  // Enable tooltips
  $("body").tooltip({ selector: '[data-toggle=tooltip]' });
  // settings: load session and start page-related housekeeping via initPage()
    $.getJSON("/api/getSession.json", function( data ) {
      $.each( data, function( key, val ) {
        mySessionData[key]=val;
        var tmpDate;
        console.log("getSessionData: "+key+' = '+val);
      });
    }).done(function() {
        initPage();
    }).fail(function() {
      alertThis('Unable to read session information.','danger');
    });
});