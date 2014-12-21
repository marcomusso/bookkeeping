function initPage() {
  console.log( "initPage called" );
  // idem per il dropdown del tema
  $("#tema").click(function () {
    console.log("Selected Option:"+$(this).val());
    mySessionData['theme']=$(this).val();
    setSessionData();
  });
}

function refreshPage() {
  console.log( "refreshPage called" );
}