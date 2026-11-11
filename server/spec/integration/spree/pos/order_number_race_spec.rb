# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_race_helpers'
require_relative '../../../support/pos_credit_helpers'

# Fifty call numbers asked for at once over several database connections:
# the single upsert hands out 1..50, each once, with no application lock.
RSpec.describe 'POS call number race', type: :integration do
  include PosCreditHelpers

  include_context 'with committed POS race rows'

  it 'hands out consecutive numbers without a repeat' do
    branch = credit_branch(store)
    date = Date.new(2026, 11, 11)
    # Fifty requests, spread over every connection the pool can spare, all
    # released at once.
    workers = [ActiveRecord::Base.connection_pool.size - 1, 2].max
    requests = Queue.new
    50.times { requests << true }
    requests.close
    gate = Queue.new
    threads = Array.new(workers) do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          gate.pop
          taken = []
          taken << Spree::Pos::OrderNumbers.next_value!(branch.id, date) while requests.pop
          taken
        end
      end
    end
    workers.times { gate << true }
    numbers = threads.flat_map { |thread| thread.join(30).value }

    expect(numbers.sort).to eq((1..50).to_a)
    expect(Spree::Pos::OrderNumberCounter.find_by!(branch_id: branch.id, business_date: date).last_value).to eq(50)
  end
end
