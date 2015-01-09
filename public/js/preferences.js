function initPage() {
  console.log( "initPage called" );

  // TODO: localize date format...
  $('#startdate').datetimepicker({
    format: 'dd/mm/yyyy'
  });
  $('#enddate').datetimepicker({
    format: 'dd/mm/yyyy'
  });

  // user changes preferences: save session and call refreshPage()
    $( "#settings_container .form-control" ).change(function() {
      var tmpEpoch;
      var dateParts;
      var now=new Date();
      console.log("form changed: "+$(this).attr('id')+" = "+ $(this).val());
      switch($(this).attr('id')) {
        // case on DOM obj id
        case 'startdate': dateParts = $(this).val().match(/(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2})/);
                          tmpEpoch=Date.UTC(+dateParts[3], dateParts[2]-1, +dateParts[1], +dateParts[4], +dateParts[5])/1000.0;
                          mySessionData['startepoch']=tmpEpoch;
                          mySessionData['startlocale']=$(this).val();
                          $("#timerange").val(0); mySessionData['timerange']=0;
                          // TODO: connstrain startDate of enddate
                          break;
        case 'enddate': dateParts = $(this).val().match(/(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2})/);
                        tmpEpoch=Date.UTC(+dateParts[3], dateParts[2]-1, +dateParts[1], +dateParts[4], +dateParts[5])/1000.0;
                        mySessionData['endepoch']=tmpEpoch;
                        mySessionData['endlocale']=$(this).val();
                        $("#timerange").val(0); mySessionData['timerange']=0;
                        // #@TODO: constrain endDate of startdate
                        break;
        case 'theme': mySessionData['theme']=$(this).val();
                     break;
        case 'timerange': if ($(this).val() !== '') { // custom range
                            mySessionData['timerange']=$(this).val();
                            // let's handle presets
                            switch ($(this).val()) {
                              case "0": console.log('current year');
                                         endepoch=now.getTime()/1000.0;
                                         startepoch=new Date(now.getFullYear(),0,1)/1000.0; // Jan, 1st
                                         break;
                              case "-1": console.log('previous year');
                                         endepoch=new Date(now.getFullYear()-1,11,31)/1000.0; // Dec, 31st
                                         startepoch=new Date(now.getFullYear()-1,0,1)/1000.0; // Jan, 1st
                                         break;
                              default: break;
                            }
                            mySessionData['startepoch']=startepoch;
                            mySessionData['endepoch']=endepoch;
                            // set date widgets to the correct values
                            var tmpDate=new Date(mySessionData['startepoch']*1000);
                            $('#startdate').datetimepicker('update', tmpDate);
                            tmpDate=new Date(mySessionData['endepoch']*1000);
                            $('#enddate').datetimepicker('update', tmpDate);
                          }
                        break;
        default: break;
      }
      // a quick notification to the user: preferences were saved!
        $("#saved").fadeIn(750);
        $("#saved").fadeOut(1750);
      setSession();
    });

 for (var key in mySessionData) {
    // update DOM id for every session key (if needed)
    switch(key) {
      case 'startepoch': tmpDate=new Date(mySessionData['startepoch']*1000);
                         if ($('#startdate').length) { $('#startdate').datetimepicker('update', tmpDate); }
                         break;
      case 'endepoch': tmpDate=new Date(mySessionData['endepoch']*1000);
                       if ($('#enddate').length) { $('#enddate').datetimepicker('update', tmpDate); }
                       break;
      case 'timerange': if ($('#timerange').length) { $("#timerange").val(mySessionData[key]); }
                       break;
      case 'theme': if ($('#theme').length) { $("#theme").val(mySessionData[key]); }
                   break;
      default: break;
    }
  }
}

function refreshPage() {
  console.log( "refreshPage called" );
}