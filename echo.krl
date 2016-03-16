ruleset echo{
	meta{
	  name "Echo Server"
	  description <<A simple echo server>>
	  author "Winston Hurst"
	  logging on
	  sharing on
	  provides echo, hello
	}

	rule hello_world is active {
	  select when echo hello
	  send_directive("say") with
	  something = "Hello World";
	}

	rule echo is active {
	  select when echo message input "(.*)" setting(m)
	  send_directive("say") with
	    something = m;
	}


}