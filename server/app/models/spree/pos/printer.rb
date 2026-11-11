# frozen_string_literal: true

module Spree
  module Pos
    # One printer of a branch. Prefer disabling to deleting: a printer that has
    # print jobs cannot be deleted.
    class Printer < Record
      self.table_name = 'spree_pos_printers'
      has_prefix_id :posprinter

      STATION_CONNECTIONS = %w[escpos_lan escpos_bluetooth sunmi_builtin].freeze
      DIRECT_CONNECTIONS = %w[epson_epos star_webprnt].freeze
      CONNECTIONS = (STATION_CONNECTIONS + DIRECT_CONNECTIONS + %w[browser]).freeze
      ADDRESSED_CONNECTIONS = (DIRECT_CONNECTIONS + %w[escpos_lan]).freeze
      PAPERS = %w[58mm 80mm].freeze
      COMMAND_LANGUAGES = %w[escpos tspl].freeze
      STATUSES = %w[active disabled].freeze
      ROLES = %w[receipt prebill kitchen_ticket void_ticket cup_label checklist table_qr].freeze
      # Documents rendered as ESC/POS text; a label language cannot print them.
      ESCPOS_KINDS = %w[receipt prebill].freeze
      # Host or IPv4 with an optional port: no scheme, path or credentials.
      HOST_LABEL = /[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?/
      ADDRESS = /\A#{HOST_LABEL}(?:\.#{HOST_LABEL})*(?::(?<port>\d{1,5}))?\z/
      SETTINGS = {
        'codepage' => ->(value) { value.is_a?(String) && value.length <= 32 },
        'char_width' => ->(value) { value.is_a?(Integer) && value.between?(16, 96) },
        'cut' => ->(value) { [true, false].include?(value) },
        'drawer' => ->(value) { [true, false].include?(value) },
        'https' => ->(value) { [true, false].include?(value) }
      }.freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :print_station_device, class_name: 'Spree::Pos::Device', optional: true
      has_many :print_jobs, class_name: 'Spree::Pos::PrintJob', dependent: :restrict_with_error

      validates :name, presence: true, length: { maximum: 80 }
      validates :connection, inclusion: { in: CONNECTIONS }
      validates :paper, inclusion: { in: PAPERS }
      validates :command_language, inclusion: { in: COMMAND_LANGUAGES }
      validates :status, inclusion: { in: STATUSES }
      validates :bluetooth_id, length: { maximum: 64 }
      validate :branch_belongs_to_store
      validate :register_belongs_to_branch
      validate :roles_known
      validate :settings_known
      validate :connection_fields
      validate :one_default_per_register_role

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      def station?
        STATION_CONNECTIONS.include?(connection)
      end

      def direct?
        DIRECT_CONNECTIONS.include?(connection)
      end

      def disabled?
        status == 'disabled'
      end

      def station_live?
        print_station_device&.status == 'active'
      end

      # Something will come for its jobs: not disabled, and its station not revoked.
      def accepting_jobs?
        !disabled? && station_live?
      end

      # Whether this printer is set up for a kind of document. A test page has no role.
      def prints?(kind)
        return true unless ROLES.include?(kind)

        roles.include?(kind) && (ESCPOS_KINDS.exclude?(kind) || command_language == 'escpos')
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, name: name, connection: connection, address: address,
          bluetooth_id: bluetooth_id, paper: paper, command_language: command_language, roles: roles,
          print_station_device_id: print_station_device&.prefixed_id, register_id: register&.prefixed_id,
          status: status, settings: settings
        }
      end

      # What a print station needs to reach this printer.
      def to_station
        { id: prefixed_id, name: name, connection: connection, address: address, bluetooth_id: bluetooth_id,
          paper: paper, command_language: command_language, settings: settings }
      end

      private

      def branch_belongs_to_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
      end

      def register_belongs_to_branch
        errors.add(:register, :invalid) if register && register.branch_id != branch_id
      end

      def roles_known
        errors.add(:roles, :inclusion) unless roles.is_a?(Array) && (roles - ROLES).empty?
      end

      def settings_known
        return if settings.is_a?(Hash) && settings.all? { |key, value| SETTINGS[key]&.call(value) }

        errors.add(:settings, :invalid)
      end

      def connection_fields
        validate_station_device
        validate_address
        errors.add(:bluetooth_id, :blank) if connection == 'escpos_bluetooth' && bluetooth_id.blank?
        errors.add(:command_language, :invalid) if command_language == 'tspl' && !station?
      end

      def validate_station_device
        unless station?
          errors.add(:print_station_device, :present) if print_station_device_id.present?
          return
        end

        device = print_station_device
        return errors.add(:print_station_device, :blank) if device.nil?

        # A revoked station must not trap its printer: disabling it stays possible.
        live = device.status == 'active' || disabled?
        valid = device.store_id == store_id && device.branch_id == branch_id && device.mode == 'print_station' && live
        errors.add(:print_station_device, :invalid) unless valid
      end

      def validate_address
        unless ADDRESSED_CONNECTIONS.include?(connection)
          errors.add(:address, :present) if address.present?
          return
        end

        match = ADDRESS.match(address.to_s)
        port = match && match[:port]&.to_i
        errors.add(:address, :invalid) unless address.to_s.length <= 255 && match && (port.nil? || port.between?(1, 65_535))
      end

      # The counter routes a document to the register's printer holding its
      # role, so two active printers on one register cannot share a role.
      def one_default_per_register_role
        return if register_id.nil? || status != 'active' || !roles.is_a?(Array) || roles.empty?

        clash = self.class.active.where(register_id: register_id).where.not(id: id).where('roles && ARRAY[?]::text[]', roles).exists?
        errors.add(:roles, :taken) if clash
      end
    end
  end
end
