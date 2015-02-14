// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
	$($(".generated-tweet")).focus(function(e) {
		$(this).blur();
	});
});

// cannot use e.preventDefault() because focus event is not cancelable (e.cancelable = false)
// http://help.dottoro.com/ljwolcsp.php