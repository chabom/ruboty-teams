# Ruboty::Teams

Microsoft Teams adapter for [Ruboty](https://github.com/r7kamura/ruboty).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruboty-teams'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruboty-teams

## Usage

1. Creating an outgoing webhook (https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/outgoingwebhook)
2. Get Security Token

## ENV

```
TEAMS_SECURITY_TOKEN     - Teams Security Token
TEAMS_SERVER_IP_ADDRESS  - Teams Webhook Server Bind Address (optional, default: 0.0.0.0)
TEAMS_SERVER_PORT        - Teams Webhook Server Port Number (optional, default: 443)
TEAMS_SERVER_CERT        - Teams Webhook Server Certificate
TEAMS_SERVER_KEY         - Teams Webhook Server Private Key
TEAMS_SERVER_CHAIN_CERT  - Teams Webhook Server Chain Certificate  (optional)
TEAMS_SERVER_ENDPOINT    - Teams Webhook Server Endpoint (optional, default: /webhooks)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruboty::Teams project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chabom/ruboty-teams/blob/master/CODE_OF_CONDUCT.md).
