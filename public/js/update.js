$(document).ready(function(){

	var STATUS_LABELS = {
		"On Time" 		: "label-success",
		"Now Boarding" 	: "label-primary",
		"Cancelled"		: "label-danger",
		"Delayed"		: "label-warning",
		"Arriving"		: "label-info",
		"Departed"		: "label-default",
		"Hold"			: "label-default"
	}

	function convert_to_label(label){
		var status = document.createElement("span");
		status.classList = 'label ' + STATUS_LABELS[label] + ' mbta-label';
		$(status).html(label);
		return status;
	}


	var randomize_updates = function(){
		$.ajax({
				type: "GET",
				url: "/updates",
				success: function(data){
					for (var i = 0; i < data['updates'].length; i++){
						var update = data['updates'][i];
						var trip = $(".trip[value=" + update.id + "]")[0];
						switch(update.attr){

							case "ScheduledTime":
							$(trip).children(".scheduled_time").hide().html(update.value[0]).fadeIn('slow');
							$(trip).children(".lateness").hide().html(update.value[1]).fadeIn("slow");
							$(trip).children(".status").hide().html(convert_to_label("Delayed")).fadeIn("slow");
							break;

							case "Track":
							$(trip).children(".track").hide().html(update.value).fadeIn("slow");
							break;

							case "Status":
							$(trip).children(".status").hide().html(convert_to_label(update.value)).fadeIn("slow");
							break;
						}

					}
					console.log("# Updates: " + data['updates'].length);
				},
				error:function(data){
					console.log("Something bad happened with " + data);
				}
			});	    
	    var timeoutID = window.setTimeout(randomize_updates, Math.random() * 5000);
	}

	randomize_updates(); //Starts the loop.

})