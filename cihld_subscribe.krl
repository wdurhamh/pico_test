ruleset child_subscribe{
	meta{
		name "Child Subscribe"
		description <<Ruleset for subscribing to parent>>
		author "Winston Hurst"
		logging on 
		sharing on
		use module  b507199x5 alias wrangler_api
	}


	rule childToParent {
    select when wrangler init_events
    pre {
       // find parant 
       // place  "use module  b507199x5 alias wrangler_api" in meta block!!
       parent_results = wrangler_api:parent();
       parent = parent_results{'parent'};
       parent_eci = parent[0]; // eci is the first element in tuple 
       attrs = {}.put(["name"],"Family")
                      .put(["name_space"],"Tutorial_Subscriptions")
                      .put(["my_role"],"Child")
                      .put(["your_role"],"Parent")
                      .put(["target_eci"],parent_eci.klog("target Eci: "))
                      .put(["channel_type"],"Pico_Tutorial")
                      .put(["attrs"],"success")
                      ;
    }
    {
     noop();
    }
    always {
      raise wrangler event "subscription"
      attributes attrs;
    }
  }
}