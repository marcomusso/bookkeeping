function initPage() {
  console.log( "initPage called" );
  // idem per il dropdown del tema
  $("#theme").click(function () {
    console.log("Selected Option:"+$(this).val());
    mySessionData['theme']=$(this).val();
    setSession();
  });
}

function refreshPage() {
  console.log( "refreshPage called" );
}