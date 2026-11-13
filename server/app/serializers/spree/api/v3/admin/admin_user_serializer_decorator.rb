# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        # Marks the default store among the stores a user holds a role on,
        # so a client that is not told which store to open falls back to it
        # only when the user may work there.
        module AdminUserSerializerDecorator
          def self.prepended(base)
            base.typelize({ id: :string, name: :string, code: :string, default: :boolean }, multi: true)
            base.attribute :stores do |user|
              stores = user.spree_roles.filter_map { |role| role.resource if role.resource.is_a?(Spree::Store) }

              stores.uniq.sort_by(&:name).map do |store|
                { id: store.prefixed_id, name: store.name, code: store.code, default: store.default }
              end
            end
          end
        end
      end
    end
  end
end

Spree::Api::V3::Admin::AdminUserSerializer.prepend(Spree::Api::V3::Admin::AdminUserSerializerDecorator)
