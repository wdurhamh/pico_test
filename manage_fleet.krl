ruleset manage_fleet{
	meta{
		name "Manage Fleet"
		description <<Rules for managing a fleet of cars>>
		author "Winston Hurst"
		logging on
		sharing on
		use module b507199x5 alias wranglerOS
		provides vehicles, subs
	}

	global{
		vehicles = function(){
			results = wranglerOS:children();
			children = results{"children"};
			children;
		}

		subs = function() {
			results = wranglerOS:subscriptions();
			subscriptions = results{"subscriptions"};
			subscriptions;
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
            children = vehicles();
    	}
    	{
      		noop();
    	}
    	always{
      		raise wrangler event "child_creation"
      		attributes attr.klog("attributes: ");
      		log("create child for " + child_name);
      		log("Current subscriptions are" + subs());
      		log(children);
    	}
	}

	rule delete_vehicle is active {
		select when car unneeded_vehicle
		pre{
			name = event:attr("name");
			children = pci:list_children();

			eci = event:attr("eci");
			attr1 = {}
						.put(["deletionTarget"],eci);
			channel = event:attr("channel");//need a better way of deleting a channel
			attr2 = {}
						.put(["channel_name"], channel);
		}
		{
			noop();
		}
		always {
			raise wrangler event subscription_cancellation
			attributes attr2.klog("attributes: ");
			log("Deleting subscription with channel " + channel);
			log(subs());
			log(children[0]);
			raise wrangler event "child_deletion"
			attributes attr1.klog("attributes: ");
			log("Deleted vehilce with eci " + eci);
		}
	}

	rule autoAccept {
    	select when wrangler inbound_pending_subscription_added 
    	pre{
      		attributes = event:attrs().klog("subscription :");
     	 }
      	{
      		noop();
      	}
    	always{
      		raise wrangler event 'pending_subscription_approval'
          	attributes attributes;        
          	log("auto accepted subscription.");
    	}
  	}
}