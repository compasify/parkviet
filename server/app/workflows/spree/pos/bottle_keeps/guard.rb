# frozen_string_literal: true

module Spree
  module Pos
    module BottleKeeps
      # Shared rules of the bottle-keeping book (module `fnb.bottle_keep`):
      # who keeps it, finding a bottle, levels and photos.
      module Guard
        MODULE = 'fnb.bottle_keep'
        CODE_ALPHABET = %w[A B C D E F G H J K L M N P Q R S T U V W X Y Z 2 3 4 5 6 7 8 9].freeze
        CODE_LENGTH = 6

        module_function

        # The bar staff: sellers and the people serving tables.
        def keep!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          allowed = policy.allows?(branch, Capabilities::OPEN_SHIFT) || policy.allows?(branch, Capabilities::TABLE_SERVE)
          raise CanCan::AccessDenied if branch.disabled? || !allowed
        end

        def read!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise ActiveRecord::RecordNotFound unless policy.membership_for(branch)&.status == 'active' || policy.permission?('read_pos_orders')
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def keep_record!(store, keep_id)
          BottleKeep.locate(BottleKeep.where(store_id: store.id), keep_id) || raise(ActiveRecord::RecordNotFound)
        end

        def level!(value)
          level = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) rescue nil) # rubocop:disable Style/RescueModifier
          raise Conflict.new('The level is a percentage from 0 to 100.', reason: 'bottle_level_invalid') unless level&.between?(0, 100)

          level
        end

        def ml!(value)
          return nil if value.blank?

          ml = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) rescue nil) # rubocop:disable Style/RescueModifier
          raise Conflict.new('The poured ml is invalid.', reason: 'bottle_ml_invalid') unless ml&.between?(1, OpenBottle::MAX_ML)

          ml
        end

        def kept!(keep)
          return if keep.kept?

          raise Conflict.new('This bottle is no longer kept.', reason: 'bottle_keep_closed', details: { status: keep.status })
        end

        # A photo of the bottle as uploaded: a small JPEG, PNG or WebP.
        def photo!(upload)
          return nil if upload.blank?

          valid = upload.respond_to?(:read) && BottleKeep::PHOTO_TYPES.include?(upload.content_type.to_s) &&
                  upload.size.to_i.between?(1, BottleKeep::PHOTO_MAX_BYTES)
          raise Conflict.new('The photo must be a JPEG, PNG or WebP image of at most 2 MB.', reason: 'bottle_photo_invalid') unless valid

          upload
        end

        def photo_digest(upload)
          return nil if upload.nil?

          digest = Digest::SHA256.hexdigest(upload.read)
          upload.rewind
          digest
        end

        def attach!(keep, upload)
          return if upload.nil?

          keep.photo.attach(io: upload, filename: "bottle-#{keep.code.downcase}#{File.extname(upload.original_filename.to_s).first(5)}",
                            content_type: upload.content_type)
        end

        def new_code(branch)
          20.times do
            code = Array.new(CODE_LENGTH) { CODE_ALPHABET.sample(random: SecureRandom) }.join
            return code unless BottleKeep.exists?(branch_id: branch.id, code: code)
          end
          raise Conflict, 'Could not pick a free bottle code.'
        end

        def event!(keep, kind:, actor:, level_before:, level_after:, ml: nil, workspace: nil, approval: nil, note: nil)
          keep.events.create!(kind: kind, actor: actor, level_before: level_before, level_after: level_after, ml: ml,
                              workspace: workspace, approval: approval, note: note.to_s.squish.first(200).presence,
                              created_at: Time.current)
        end

        def audit!(keep, staff, action, metadata = {})
          AuditEntry.record!(store: keep.store, actor: staff, action: action, subject: keep,
                             metadata: { code: keep.code, level_percent: keep.level_percent, status: keep.status }.merge(metadata))
        end
      end
    end
  end
end
