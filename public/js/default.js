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
    "default"  : "/bootstrap-3.2.0/css/bootstrap-theme.css",
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
      alert( "Impossibile salvare le informazioni della sessione. Contattare gli sviluppatori." );
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
      console.log('alertThis chiamata senza il parametro message!');
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
  // settings: load session and start page-related housekeeping via initPage()
    $.getJSON("/api/getSession.json", function( data ) {
      $.each( data, function( key, val ) {
        mySessionData[key]=val; // metto i valori di sessione in un obj
        // console.log("getSessionData: "+key+' = '+val);
        for (key in mySessionData) {
          // per ogni valore di key se esiste il val settare l'apposito oggetto
          switch(key) {
            // nel case c'e' la chiave (indice dei parametri), da mappare sugli oggetti del DOM (a destra)
            case 'theme': if ($('#tema').length) { $("#tema").val(mySessionData[key]); }
                         break;
            default: break;
          }
        }
      });
    }).done(function() {
        initPage();
    }).fail(function() {
      alertThis('Impossibile recuperare le informazioni di sessione.','danger');
    });
  // IMPOSTAZIONI: gestione parametri, cambio valori di sessione, salvataggio (setSession) e richiamo refreshPage()
    $( "#settings_container .form-control" ).change(function() {
      var tmpEpoch;
      var dateParts;
      console.log("form changed: "+$(this).attr('id')+" = "+ $(this).val());
      switch($(this).attr('id')) {
        // nel case c'e' l'id dell'oggetto DOM
        case 'startdate': dateParts = $(this).val().match(/(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2})/);
                          tmpEpoch=Date.UTC(+dateParts[3], dateParts[2]-1, +dateParts[1], +dateParts[4], +dateParts[5])/1000.0;
                          mySessionData['startepoch']=tmpEpoch;
                          mySessionData['startlocale']=$(this).val();
                          // il periodo diventa personalizzato
                          $("#periodo").val(0); mySessionData['timerange']=0;
                          // TODO: settare la startDate di enddate
                          break;
        case 'enddate': dateParts = $(this).val().match(/(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2})/);
                        tmpEpoch=Date.UTC(+dateParts[3], dateParts[2]-1, +dateParts[1], +dateParts[4], +dateParts[5])/1000.0;
                        mySessionData['endepoch']=tmpEpoch;
                        mySessionData['endlocale']=$(this).val();
                        // il periodo diventa personalizzato
                        $("#periodo").val(0); mySessionData['timerange']=0;
                        // TODO: settare la endDate di startdate
                        break;
        case 'unita': mySessionData['units']=$(this).val();
                      break;
        case 'tema': mySessionData['theme']=$(this).val();
                     break;
        case 'ambiente': mySessionData['env_code']=$(this).val();
                         mySessionData['env_display']=myEnvLookup[$(this).val()]['visualizzazione'];
                         break;
        case 'periodo': if ($(this).val() !== 0) { // intervallo personalizzato
                          mySessionData['timerange']=$(this).val();
                          var d=new Date();
                          var today_epoch=Math.floor(d.getTime()/1000);
                          var yesterday_epoch=today_epoch-24*60*60;
                          mySessionData['startepoch']=today_epoch-(60*60*$(this).val()); // $(this).val() e' in ore
                          mySessionData['endepoch']=today_epoch;
                          // settare i widget di start/end al valore corretto rispetto a today_epoch
                          var tmpDate=new Date(mySessionData['startepoch']*1000);
                          $('#startdate').datetimepicker('update', tmpDate);
                          tmpDate=new Date(mySessionData['endepoch']*1000);
                          $('#enddate').datetimepicker('update', tmpDate);
                        }
                        break;
        default: break;
      }
      // IMPOSTAZIONI: notifica salvataggio
        $("#saved").fadeIn(750);
        $("#saved").fadeOut(1750);
      setSession();
      refreshPage();
    });
});