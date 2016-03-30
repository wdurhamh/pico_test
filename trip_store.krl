ruleset trip_store{
	meta{
	  name "Trip Store Ruleset"
	  description <<A neat ruleset for part 3 of the lab>>
	  author "Winston HUrst"
	  logging on
	  sharing on
	  provides long_trips, short_trips, trips
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
	    now = time:now();
	    trip_info = mileage +  " " + time:strftime(now, "%F %T");
	  }
	  fired {
	    set ent:trips ent:trips.append(trip_info);
	    log(trip_info);
	    log(now)
	  }
	}

	rule collect_long_trips{
	  select when explicit found_long_trip
	  pre{
 	    mileage = event:attr("mileage");
	    now = time:now();
	    trip_info = mileage + " " + time:strftime(now, "%F %T");
	  }
	  fired{
	    set ent:long_trips ent:long_trips.append(trip_info);
	    log(trip_info);
	    log(now)
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

	rule send_report {
		select when car report_requested
		pre{
			report = trips();
			attrs = event:attr
					.put(["report"],report);
		}
		{
			noop();
		}
		always {
			//send it back. Do we need to specify chanel
			raise car event report_sent
			attributes attrs;
		}
	}
}