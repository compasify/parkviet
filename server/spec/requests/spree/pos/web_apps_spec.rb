# frozen_string_literal: true

require 'tmpdir'

# The production image builds apps/pos into POS_WEB_DIST_PATH and
# apps/pos-dashboard into POS_ADMIN_DIST_PATH. Rails serves both same-origin,
# with deep links falling back to index.html.
RSpec.describe 'POS web apps', type: :request do
  around do |example|
    Dir.mktmpdir do |dir|
      @dist = {}
      { 'POS_WEB_DIST_PATH' => 'pos', 'POS_ADMIN_DIST_PATH' => 'pos-admin' }.each do |variable, name|
        root = File.join(dir, name)
        FileUtils.mkdir_p(File.join(root, 'assets'))
        File.write(File.join(root, 'index.html'), "<html>#{name}</html>")
        File.write(File.join(root, 'assets', 'app-abc123.js'), "console.log('#{name}')")
        @dist[variable] = root
      end
      example.run
    end
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    @dist.each { |variable, root| allow(ENV).to receive(:fetch).with(variable, nil).and_return(root) }
  end

  it 'serves the counter app at /pos with SPA fallback for deep links' do
    get '/pos'
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq('<html>pos</html>')

    get '/pos/shifts'
    expect(response.body).to eq('<html>pos</html>')
    expect(response.headers['Cache-Control']).to eq('no-cache')

    get '/pos/display'
    expect(response.body).to eq('<html>pos</html>')
  end

  it 'serves hashed assets with long caching and keeps their extension' do
    get '/pos/assets/app-abc123.js'
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("console.log('pos')")
    expect(response.headers['Cache-Control']).to include('immutable')
  end

  it 'serves POS administration at /pos-admin, separately from /pos' do
    get '/pos-admin/store_1/settings/system'
    expect(response.body).to eq('<html>pos-admin</html>')

    get '/pos-admin/assets/app-abc123.js'
    expect(response.body).to eq("console.log('pos-admin')")
  end

  it 'refuses paths outside the bundle' do
    get '/pos/..%2F..%2Fetc%2Fpasswd'
    expect(response.body).to eq('<html>pos</html>')
  end

  it 'leaves the API and the device channel to their own routes' do
    expect(Rails.application.routes.recognize_path('/api/v3/pos_device/me', method: :get)).
      to include(controller: 'spree/pos/device_api/me')
    expect(Rails.application.routes.recognize_path('/api/v3/admin/pos/system_status', method: :get)).
      to include(controller: 'spree/api/v3/admin/pos/system_status')
    expect(Rails.application.routes.recognize_path('/pos/receipts/42', method: :get)).
      to include(controller: 'spree/pos/selling_app', path: 'receipts/42')
  end

  it 'answers 404 when the image carries no bundle' do
    allow(ENV).to receive(:fetch).with('POS_WEB_DIST_PATH', nil).and_return(nil)

    get '/pos/shifts'
    expect(response).to have_http_status(:not_found)
  end
end
