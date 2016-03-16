ruleset track_trips{
	meta {
	  name "Trip Tracker"
	  description <<Ruleset for the second part of the first part of this lab>>
	  author "Winston Hurst"
	  logging on 
	  sharing on
	}

	rule process_trip is active {
	  select when echo message
	  pre {
	     mileage = event:attr("mileage");
	  }
	  {
	  	send_directive("trip") with
	  	  trip_length = mileage;
	  }
	}
}