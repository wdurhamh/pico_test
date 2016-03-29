ruleset manage_fleet{
	meta{
		name "Manage Fleet"
		description <<Rules for managing a fleet of cars>>
		author "Winston Hurst"
		logging on
		sharing on
	}



	rule create_vehicle is active {
		select when car new_vehicle

		 pre{
      		child_name = event:attr("name");
      		attr = {}
                              .put(["Prototype_rids"],"b507777x0.prod") // ; separated rulesets the child needs installed at creation. this is the track_trips (2) ruleset
                              .put(["name"],child_name) // name for child_name
                              .put(["parent_eci"],parent_eci) // eci for child to subscribe
                              ;
    	}
    	{
      		noop();
    	}
    	always{
      		raise wrangler event "child_creation"
      		attributes attr.klog("attributes: ");
      		log("create child for " + child);
    	}
	}

	rule autoAccept {
    	select when wrangler inbound_pending_subscription_added 
    	pre{
      		attributes = event:attrs().klog("subcription :");
     	 }
      	{
      		noop();
      	}
    	always{
      		raise wrangler event 'pending_subscription_approval'
          	attributes attributes;        
          	log("auto accepted subcription.");
    	}
  	}
}