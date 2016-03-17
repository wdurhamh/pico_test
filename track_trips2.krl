ruleset track_trips{
	meta {
	  name "Trip Tracker2"
	  description <<Ruleset for the second part of the first part of this lab>>
	  author "Winston Hurst"
	  logging on 
	  sharing on
	}

	global {
	   long_trip = 100;
	}

	rule process_trip is active {
	  select when car new_trip
	  pre {
	     mileage = event:attr("mileage");
	  }
	  {
	  	send_directive("trip") with
	  	  trip_length = mileage;
	  }
	  fired{
	    raise explicit event trip_processed
	  	    attributes event:attrs();
	  }
	}

	rule find_long_trips is active {
	  select when explicit trip_processed
	  pre {
	    mileage = event:attr("mileage").klog("The milleage was: ");
	  }
	  fired {
	    raise explicit event found_long_trip if (mileage > long_trip)
	       attributes event:attrs();
	  }
	}

	rule process_long_trip{
	  select when explicit found_long_trip
	  log ("It was a long trip!")
	}
}