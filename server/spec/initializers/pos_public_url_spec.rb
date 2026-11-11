# frozen_string_literal: true

require 'ipaddr'

RSpec.describe Parkviet::PosPublicUrl do
  describe '.normalize' do
    it 'keeps the origin of a LAN or public address' do
      expect(described_class.normalize('http://192.168.1.10/')).to eq('http://192.168.1.10')
      expect(described_class.normalize(' http://POS.local:8080 ')).to eq('http://pos.local:8080')
      expect(described_class.normalize('http://10.0.0.5')).to eq('http://10.0.0.5')
      expect(described_class.normalize('http://172.20.1.1')).to eq('http://172.20.1.1')
      expect(described_class.normalize('https://pos.quan-a.vn')).to eq('https://pos.quan-a.vn')
      expect(described_class.normalize('https://pos.quan-a.vn:443/')).to eq('https://pos.quan-a.vn')
    end

    it 'treats a blank value as unset' do
      expect(described_class.normalize(nil)).to be_nil
      expect(described_class.normalize('  ')).to be_nil
    end

    it 'refuses plain http to a host outside the shop network, as the staff app does' do
      %w[http://example.com http://8.8.8.8 http://172.32.0.1 http://192.169.0.1 http://localhost http://local].each do |url|
        expect { described_class.normalize(url) }.to raise_error(described_class::Invalid, /private IP/), url
      end
    end

    it 'refuses what a device cannot pair with' do
      {
        'ftp://192.168.1.10' => /http/,
        'pos.local' => /http/,
        'http://a:b@192.168.1.10' => /user name/,
        'http://192.168.1.10/?x=1' => /query/,
        'http://192.168.1.10/#x' => /query/,
        'https://pos.quan-a.vn/pos' => /path/,
        'http://bad host' => /valid URL/
      }.each do |url, message|
        expect { described_class.normalize(url) }.to raise_error(described_class::Invalid, message), url
      end
    end
  end

  describe '.configuration' do
    it 'reads the address and TLS mode together' do
      config = described_class.configuration('POS_PUBLIC_BASE_URL' => 'https://pos.quan-a.vn', 'POS_TLS_MODE' => 'public')
      expect(config.base_url).to eq('https://pos.quan-a.vn')
      expect(config.tls_mode).to eq('public')
      expect(config).to be_tls
      expect(config.host_with_port).to eq('pos.quan-a.vn')
    end

    it 'keeps a non-default port in the generated-URL host' do
      config = described_class.configuration('POS_PUBLIC_BASE_URL' => 'http://192.168.1.10:8080', 'POS_TLS_MODE' => 'none')
      expect(config.host_with_port).to eq('192.168.1.10:8080')
      expect(config).not_to be_tls
    end

    it 'leaves Rails SSL settings alone when no mode is set' do
      config = described_class.configuration({})
      expect(config.base_url).to be_nil
      expect(config.tls_mode).to be_nil
    end

    it 'takes the mode from the address scheme when POS_TLS_MODE is unset' do
      expect(described_class.configuration('POS_PUBLIC_BASE_URL' => 'http://192.168.1.10').tls_mode).to eq('none')
      https = described_class.configuration('POS_PUBLIC_BASE_URL' => 'https://pos.quan-a.vn', 'POS_TLS_MODE' => ' ')
      expect(https.tls_mode).to eq('public')
      expect(https).to be_tls
    end

    it 'refuses an unknown mode and a mode that contradicts the address' do
      expect { described_class.configuration('POS_TLS_MODE' => 'letsencrypt') }.to raise_error(described_class::Invalid, /POS_TLS_MODE/)
      expect do
        described_class.configuration('POS_PUBLIC_BASE_URL' => 'https://pos.quan-a.vn', 'POS_TLS_MODE' => 'none')
      end.to raise_error(described_class::Invalid, /internal or public/)
      expect do
        described_class.configuration('POS_PUBLIC_BASE_URL' => 'http://192.168.1.10', 'POS_TLS_MODE' => 'internal')
      end.to raise_error(described_class::Invalid, /https/)
    end
  end

  describe '.allowed_hosts' do
    it 'stays off until a deployment names its address' do
      expect(described_class.allowed_hosts({})).to be_nil
    end

    it 'accepts the shop network on a LAN server' do
      hosts = described_class.allowed_hosts('POS_PUBLIC_BASE_URL' => 'http://192.168.1.10', 'POS_TLS_MODE' => 'none',
                                            'POS_EXTRA_HOSTS' => 'pay.quan-a.vn, ')
      expect(hosts).to include('192.168.1.10', 'pay.quan-a.vn')
      expect(hosts.grep(IPAddr).any? { |network| network.include?(IPAddr.new('10.1.2.3')) }).to be(true)
      expect(hosts.grep(Regexp).any? { |pattern| 'quan-a.local'.match?(/\A#{pattern}\z/) }).to be(true)
    end

    it 'accepts only its own names behind a public certificate' do
      hosts = described_class.allowed_hosts('POS_PUBLIC_BASE_URL' => 'https://pos.quan-a.vn', 'POS_TLS_MODE' => 'public',
                                            'SPREE_HOST' => 'shop.quan-a.vn:443')
      expect(hosts).to eq(%w[pos.quan-a.vn shop.quan-a.vn])
    end

    it 'does not open the shop network for an https address without a mode' do
      hosts = described_class.allowed_hosts('POS_PUBLIC_BASE_URL' => 'https://pos.quan-a.vn')
      expect(hosts).to eq(%w[pos.quan-a.vn])
    end
  end

  describe 'pairing QR', type: :request do
    it 'carries POS_PUBLIC_BASE_URL instead of the request origin' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('POS_PUBLIC_BASE_URL').and_return('http://192.168.1.10/')
      request = ActionDispatch::TestRequest.create('HTTP_HOST' => 'localhost:3000')

      expect(Spree::Pos::DeviceAuthenticator.public_base_url(request)).to eq('http://192.168.1.10')
    end

    it 'falls back to the request origin when unset' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('POS_PUBLIC_BASE_URL').and_return(nil)
      request = ActionDispatch::TestRequest.create('HTTP_HOST' => 'localhost:3000')

      expect(Spree::Pos::DeviceAuthenticator.public_base_url(request)).to eq('http://localhost:3000')
    end
  end
end
