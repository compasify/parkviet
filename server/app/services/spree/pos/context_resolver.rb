# frozen_string_literal: true

module Spree
  module Pos
    class ContextResolver
      def initialize(store:, staff:)
        @store = store
        @policy = AccessPolicy.new(store: store, staff: staff)
      end

      def call(branch_id: nil, register_id: nil)
        branch = resolve_branch(branch_id)
        register = resolve_register(branch, register_id)
        shift = if register
                  Shift.for_store(store).open_now.find_by(register_id: register.id)
                elsif branch
                  Shift.for_store(store).open_now.find_by(branch_id: branch.id, register_id: nil, owner_id: policy.staff.id)
                end
        branches = policy.visible_branches.order(:name, :id).limit(100).to_a
        branches << branch if branch && branches.none? { |item| item.id == branch.id }
        registers = registers_for(branch).to_a
        registers << register if register && registers.none? { |item| item.id == register.id }
        {
          capabilities: capabilities_for(branch),
          branches: branches.map(&:to_pos),
          registers: registers.map(&:to_pos),
          shift: shift&.to_pos,
          selection: {
            branch_id: branch&.prefixed_id,
            register_id: register&.prefixed_id
          }
        }
      end

      private

      attr_reader :store, :policy

      def resolve_branch(branch_id)
        return if branch_id.blank?

        branch = Branch.locate(policy.visible_branches, branch_id)
        raise ActiveRecord::RecordNotFound if branch.nil?

        branch
      end

      def resolve_register(branch, register_id)
        return if register_id.blank?
        raise CanCan::AccessDenied if branch.nil?

        register = Register.locate(Register.for_store(store).where(branch_id: branch.id), register_id)
        raise ActiveRecord::RecordNotFound if register.nil?

        register
      end

      def registers_for(branch)
        return Register.none if branch.nil?

        Register.for_store(store).where(branch_id: branch.id).order(:name).limit(100)
      end

      def capabilities_for(branch)
        granted = []
        if branch && !branch.disabled?
          membership = policy.membership_for(branch)
          granted = Capabilities::ASSIGNABLE.select { |capability| membership&.allows?(capability) }
          granted.delete(Capabilities::RECOVER)
        end
        granted << Capabilities::RECOVER if branch && policy.can_recover?(branch)
        if policy.permission?('read_pos_topology') || policy.permission?('write_pos_topology')
          granted << 'pos.topology.read'
        end
        granted << Capabilities::MANAGE if policy.permission?('write_pos_topology')
        granted.uniq
      end
    end
  end
end
