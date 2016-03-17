ruleset trip_store{
	meta{
	  name "Trip Store Ruleset"
	  description <<A neat ruleset for part 3 of the lab>>
	  author "Winston HUrst"
	  logging on
	  sharing on
	  provides trips, long_trips, short_trips
	}

	global{
       trips = function(){
         ent:trips;
       }

       long_trips = function(){
         ent:long_trips;
       }

       short_trips = function() {
         long = ent:long_trips;
         all = ent:trips;
         short = all.filter(function(x){
         	long.none(function(y){ y eq x  });
         });
         short;
       }
	}

	rule collect_trips{
	  select when explicit trip_processed
	  pre{
	    mileage = event:attr("mileage");
	    trip_info = "" + mileage + time:now();
	  }
	  fired {
	    set ent:trips ent:trips.append(trip_info);
	    log(trip_info)
	  }
	}

	rule collect_long_trips{
	  select when explicit found_long_trip
	  pre{
 	    mileage = event:attr("mileage");
	    trip_info = "" + mileage + time:now();
	    
	  }
	  fired{
	    set ent:long_trips ent:long_trips.append(trip_info);
	    log(trip_info)
	  }
	}

	rule clear_trips{
	  select when car trip_reset
	  fired{
	    set ent:trips [];
	    set ent:long_trips [];
	    log "Cleared trips!"
	  }
	}
}