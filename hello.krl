ruleset hello_world{
  meta{
    name "Hello World"
    description <<A first ruleset for the Quickstart>>
    author "Winston Hurst"
    logging on
    sharing on
    provides hello
  }

  global {
    hello = function(obj) {
      msg = "Hello" + obj
      msg 
    };
  }
  
  rule heloow_world {
    select when echo hello
    send_directive("say") with
      something = "Hello World";
  }	
}
