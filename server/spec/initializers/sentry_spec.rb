# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sentry initializer' do
  let(:config) do
    built = nil
    allow(Sentry).to receive(:init) { |&block| built = Sentry::Configuration.new(&block) }
    stub_const('ENV', ENV.to_h.merge('SENTRY_DSN' => 'http://public@sentry.invalid/1'))
    load Rails.root.join('config/initializers/sentry.rb')
    built
  end

  let(:env) do
    {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/cable',
      'HTTP_SEC_WEBSOCKET_PROTOCOL' => 'actioncable-v1-json, pos-device.synthetic-value',
      'HTTP_ACCEPT' => 'text/plain'
    }
  end

  it 'keeps the socket subprotocol header, which can carry a device token, out of reports' do
    headers = Sentry::RequestInterface.new(
      env: env, data_collection: config.data_collection, rack_env_whitelist: config.rack_env_whitelist
    ).headers

    expect(headers['Sec-Websocket-Protocol']).to eq('[Filtered]')
    expect(headers['Accept']).to eq('text/plain')
  end
end
