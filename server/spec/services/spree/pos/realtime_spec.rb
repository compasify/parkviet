# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_credit_helpers'
require_relative '../../../support/pos_schema_helpers'

RSpec.describe Spree::Pos::Realtime, type: :model do
  include ActionCable::TestHelper
  include PosCreditHelpers
  include PosSchemaHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:stream) { described_class.stream_name(branch) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def messages(name = stream)
    broadcasts(name).map { |raw| JSON.parse(raw) }
  end

  describe '.publish' do
    it 'carries the lease generation, which a claim changes without a new revision' do
      allow(ActionCable.server).to receive(:broadcast)
      described_class.publish(branch, 'workspace.updated', id: 'posws_abc', revision: 3, lease_generation: 2)

      expect(ActionCable.server).to have_received(:broadcast)
        .with(described_class.stream_name(branch), hash_including(revision: 3, lease_generation: 2))
    end

    it 'refuses an event without an id' do
      expect { described_class.publish(branch, 'workspace.updated', revision: 1) }.to raise_error(ArgumentError, /needs an id/)
      expect { described_class.publish(branch, 'workspace.updated', id: ' ') }.to raise_error(ArgumentError, /needs an id/)
    end

    it 'keeps EVENTS frozen and refuses an unknown event' do
      expect(described_class::EVENTS).to be_frozen
      expect { described_class.publish(branch, 'order.secret', id: 'x') }.to raise_error(ArgumentError, /order.secret/)
      expect(messages).to be_empty
    end

    it 'sends only the whitelisted fields, matching the published schema' do
      described_class.publish(branch, 'workspace.updated', id: 'posws_abc', revision: 3, total: '1000',
                                                           customer_name: 'Secret', refs: { order_id: 'or_abc' })

      message = messages.sole
      expect(message.keys).to match_array(%w[event id branch_id revision at refs])
      expect(message).to include('event' => 'workspace.updated', 'id' => 'posws_abc', 'branch_id' => branch.prefixed_id,
                                 'revision' => 3, 'refs' => { 'order_id' => 'or_abc' })
      expect(JSONSchemer.schema(pos_component_schema('RealtimeEvent')).validate(message).to_a).to eq([])
    end

    it 'keeps only record references in refs' do
      described_class.publish(branch, 'resource.updated', id: 'x', refs: { order_id: 'or_abc', customer_name: 'Secret', note_id: 'free text' })

      expect(messages.sole['refs']).to eq('order_id' => 'or_abc')
    end

    it 'waits for the commit' do
      ApplicationRecord.transaction do
        described_class.publish(branch, 'workspace.updated', id: 'posws_abc')
        expect(messages).to be_empty
      end

      expect(messages.size).to eq(1)
    end

    it 'sends nothing when the transaction rolls back' do
      ApplicationRecord.transaction do
        described_class.publish(branch, 'workspace.updated', id: 'posws_abc')
        raise ActiveRecord::Rollback
      end

      expect(messages).to be_empty
    end

    it 'logs a broadcast failure instead of raising it' do
      allow(ActionCable.server).to receive(:broadcast).and_raise(IOError, 'adapter down')
      allow(Rails.logger).to receive(:error)

      expect { described_class.publish(branch, 'workspace.updated', id: 'posws_abc') }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(/realtime workspace.updated failed: IOError/)
    end
  end

  describe '.disconnect_device' do
    let(:device) do
      Spree::Pos::Device.create!(store: store, branch: branch, name: 'KDS', mode: 'kds', platform: 'web',
                                 token_digest: Spree::Pos::Device.digest('secret'))
    end
    let(:internal_channel) { "action_cable/#{device.prefixed_id}" }

    it 'addresses the socket through its only identifier' do
      described_class.disconnect_device(device)

      expect(messages(internal_channel).sole).to include('type' => 'disconnect', 'reconnect' => true)
    end

    it 'waits for the commit and sends nothing after a rollback' do
      ApplicationRecord.transaction do
        described_class.disconnect_device(device)
        expect(messages(internal_channel)).to be_empty
        raise ActiveRecord::Rollback
      end

      expect(messages(internal_channel)).to be_empty
    end

    it 'logs a failure instead of raising it' do
      allow(ActionCable.server).to receive(:remote_connections).and_raise(IOError, 'adapter down')
      allow(Rails.logger).to receive(:error)

      expect { described_class.disconnect_device(device) }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(/realtime disconnect failed: IOError/)
    end
  end

  describe 'announcements from CommandExecutor' do
    let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
    let(:register) { open_drawer(store, branch, cashier) }
    let(:editor_id) { SecureRandom.uuid }
    let(:workspace) do
      created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                    key: SecureRandom.uuid, editor_id: editor_id)
      Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    end

    def execute(target, key: SecureRandom.uuid, command: 'test.change', &block)
      Spree::Pos::CommandExecutor.call(store: store, actor: cashier, key: key, payload: { 'command' => command },
                                       workspace: target, authorize: -> {}, &(block || -> { { 'ok' => true } }))
    end

    def workspace_updates
      messages.select { |message| message['event'] == 'workspace.updated' }
    end

    def second_workspace
      created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                    key: SecureRandom.uuid, editor_id: editor_id)
      Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    end

    it 'announces a creation, which runs with no workspace' do
      created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                    key: SecureRandom.uuid, editor_id: editor_id)

      expect(workspace_updates.map { |message| message['id'] }).to eq([created['id']])
    end

    it 'announces the committed revision, even when the workflow updated another copy of the row' do
      workspace
      expect do
        execute(workspace) { Spree::Pos::Workspace.find(workspace.id).update!(revision: 7) && { 'ok' => true } }
      end.to change { workspace_updates.size }.by(1)

      expect(workspace_updates.last).to include('id' => workspace.prefixed_id, 'revision' => 7)
    end

    it 'announces nothing for a replay' do
      key = SecureRandom.uuid
      execute(workspace, key: key)

      expect { execute(workspace, key: key) }.not_to(change { workspace_updates.size })
    end

    it 'announces nothing for a failed command' do
      workspace

      expect { execute(workspace) { raise Spree::Pos::Conflict, 'No.' } }.to raise_error(Spree::Pos::Conflict)
      expect(workspace_updates.size).to eq(1) # the creation only
    end

    it 'announces nothing for a command without a workspace' do
      expect { execute(nil) }.not_to(change { messages.size })
    end

    it 'announces nothing for a lease renewal' do
      workspace

      expect { execute(workspace, command: 'refresh_lease') }.not_to(change { workspace_updates.size })
    end

    it 'announces a workspace once when a nested command touches it too' do
      workspace

      expect do
        execute(workspace) { execute(workspace, command: 'test.nested') && { 'ok' => true } }
      end.to change { workspace_updates.size }.by(1)
    end

    it 'also announces a different workspace touched by a nested command' do
      other = second_workspace
      workspace
      before = workspace_updates.size

      execute(workspace) { execute(other, command: 'test.nested') && { 'ok' => true } }

      expect(workspace_updates.drop(before).map { |message| message['id'] }).to contain_exactly(workspace.prefixed_id, other.prefixed_id)
    end

    it 'announces nothing when the parent fails after a nested command succeeded' do
      other = second_workspace
      workspace
      before = workspace_updates.size

      expect do
        execute(workspace) do
          execute(other, command: 'test.nested')
          raise Spree::Pos::Conflict, 'No.'
        end
      end.to raise_error(Spree::Pos::Conflict)
      expect(workspace_updates.size).to eq(before)
    end

    it 'waits for a surrounding transaction and stays silent when it rolls back' do
      workspace
      before = workspace_updates.size

      ApplicationRecord.transaction do
        execute(workspace)
        expect(workspace_updates.size).to eq(before)
        raise ActiveRecord::Rollback
      end

      expect(workspace_updates.size).to eq(before)
    end

    it 'never fails the command when the broadcast fails' do
      workspace
      allow(ActionCable.server).to receive(:broadcast).and_raise(IOError, 'adapter down')

      expect(execute(workspace)).to eq('ok' => true)
    end
  end
end
