ruleset manage_fleet{
	meta{
		name "Manage Fleet"
		description <<Rules for managing a fleet of cars>>
		author "Winston Hurst"
		logging on
		sharing on
	}

	global {
		vehicles = function(){
			results = wranglerOS:children();
			children = results{"children"};
		}
	}



	rule create_vehicle is active {
		select when car new_vehicle

		 pre{
      		child_name = event:attr("name");
      		attr = {}
                              .put(["Prototype_rids"],"b507777x0.prod;b507777x2.prod") // ; separated rulesets the child needs installed at creation. this is the track_trips (2) ruleset
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

	rule delete_vehicle is active {
		select when car unneeded_vehicle
		pre{
			eci = event:attr("eci");
			attr = {}
						.put(["deletionTarget"],eci);
		}
		{
			noop();
		}
		always {
			raise wrangler event "child_deletion"
			attributes attr.klog("attributes: ");
			log("Deleted vehilce with name " + child_name);
			//also need to delete subscription
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