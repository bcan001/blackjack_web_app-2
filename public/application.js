$(document).ready(function() {

	//$('#player_color').click(function() {
	//	$('#player_area').css('background-color','red')
	//	return false;
	//});

	//$('#hit_form input').click(function() {
		//alert('hit button clicked!');

	// makes player hit button ajaxified
	$(document).on('click','#hit_form input'), function() {
		$.ajax({
			type: 'POST',
			url: '/game/player/hit'
			//data: {}
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});

	// makes player stay button ajaxified
	$(document).on('click','#stay_form input'), function() {
		$.ajax({
			type: 'POST',
			url: '/game/player/stay'
			//data: {}
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});

	// make dealer actions ajaxified
	$(document).on('click','#hit_dealer_form input'), function() {
		$.ajax({
			type: 'POST',
			url: '/game/dealer/hit'
			//data: {}
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});

	$(document).on('click','#hit_dealer_form input'), function() {
		$.ajax({
			type: 'GET',
			url: '/game/dealer/hit'
			//data: {}
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});

	$(document).on('click','#hit_dealer_form input'), function() {
		$.ajax({
			type: 'GET',
			url: '/game/dealerwins'
			//data: {}
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});

});


