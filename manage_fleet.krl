ruleset manage_fleet{
	meta{
		name "Manage Fleet"
		description <<Rules for managing a fleet of cars>>
		author "Winston Hurst"
		logging on
		sharing on
		use module b507199x5 alias wranglerOS
		provides vehicles, subs, trip_reports, five_latest
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
			s_list = subscriptions{"subscribed"};
			s_list;
		}

		trip_reports = function(){
			chiles = vehicles();
			all_trips = chiles.map(function(chile){
				cloud_url = "https://cs.kobj.net/sky/cloud/";
        		eci = chile[0];
        		mod = "b507777x4.prod";
        		func = "trips";
        		params = {};
	            response = http:get("#{cloud_url}#{mod}/#{func}", (params || {}).put(["_eci"], eci));
	 
	 
	            status = response{"status_code"};
	 
	 
	            error_info = {
	                "error": "sky cloud request was unsuccesful.",
	                "httpStatus": {
	                    "code": status,
	                    "message": response{"status_line"}
	                }
	            };
	 
	 
	            response_content = response{"content"}.decode();
	            response_error = (response_content.typeof() eq "hash" && response_content{"error"}) => response_content{"error"} | 0;
	            response_error_str = (response_content.typeof() eq "hash" && response_content{"error_str"}) => response_content{"error_str"} | 0;
	            error = error_info.put({"skyCloudError": response_error, "skyCloudErrorMsg": response_error_str, "skyCloudReturnValue": response_content});
	            is_bad_response = (response_content.isnull() || response_content eq "null" || response_error || response_error_str);
	 
	 
	            // if HTTP status was OK & the response was not null and there were no errors...
	            (status eq "200" && not is_bad_response) => response_content | error
			});
			all_trips;
		}

		five_latest = function() {
			p_r = ent:reports.filter(function(x){
				i = ent:reports.reverse().index(x);
				i < 6;
			});
			p_r;
		}

	}

	rule reset_reporting is active {
		select when car reset_reporting
		always{
			set ent:reports [];
			set ent:cid_list [];	
		}
	}



	rule create_vehicle is active {
		select when car new_vehicle

		 pre{
      		child_name = event:attr("name");
      		attr = {}
                              .put(["Prototype_rids"],"b507777x0.prod;b507777x2.prod;b507777x4.prod") // ; separated rulesets the child needs installed at creation. this is the track_trips (2) ruleset
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
    	}
	}

	rule delete_vehicle is active {
		select when car unneeded_vehicle
		pre{
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

  	rule request_new_report {
  		select when car new_report
  		pre{
  			chiles = vehicles();
  			correlation_id = random:uuid();
  			attrs = {}
  						.put(["cid"], correlation_id);
  		}
  		{
  			noop();
  		}
  		always{
  			set ent:cid_list ent:cid_list.append(correlation_id);
  			set ent:reports ent:reports.append([]);
  			raise car event report_requested
  			attributes attrs;
  		}
  	}

  	rule gather_reports {
  		select when car report_requested
  		pre{
  			cid = event:attr("cid");
  			report_index = ent:cid_list.index(cid);
  			report = event:attr("report");
		}
		fired{
			log("Report index is " + report_index);
  			log("CID is " + cid);
  			log("Reports are loking like " + ent:reports);
			set ent:reports ent:reports[report_index].append(report);
		}
  	}
}