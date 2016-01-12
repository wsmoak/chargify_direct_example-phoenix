# ChargifyDirectExamples

Chargify Direct in Elixir and Phoenix

To start the Phoenix project:

1. Set environment variables for `CHARGIFY_DIRECT_API_ID`, `CHARGIFY_DIRCT_API_SECRET` and `CHARGIFY_DIRECT_PASSWORD`

2. Install dependencies with `mix deps.get` and `npm install`

Note that both the Phoenix Framework and the Chargify V2 dependencies are pointed at the master branch of their respective git repos.  This means things may break!  If so, try editing mix.exs to point at the latest release or an earlier commit.

3. Start the Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser to create a subscription.

Or visit http://localhost:4000/update?sub=12345 with an existing subscription id to update the payment profile information.

See the 'util' directory for a Ruby script to generate the Braintree client token until there is an Elixir library to do it on the server side.

## References

  * https://docs.chargify.com/chargify-direct-introduction
  * http://stackoverflow.com/questions/27082396/how-does-one-generate-an-hmac-string-in-elixir
  * http://www.erlang.org/doc/man/crypto.html
  * http://essenciary.com/elixir-current-unix-timestamp/
  * http://elixir-lang.org/getting-started/basic-operators.html
  * http://elixir-lang.org/docs/v1.0/elixir/Integer.html#to_string/1
  * https://github.com/zyro/elixir-uuid
  * https://developers.braintreepayments.com/javascript+ruby/start/hello-client
  * https://developers.braintreepayments.com/javascript+ruby/start/hello-server
  * https://developers.braintreepayments.com/javascript+ruby/guides/paypal/client-side
