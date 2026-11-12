# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Changes the quantity of a table order's line the kitchen has not been
      # told about, without a lease. The line's own version is checked
      # instead of the order's revision, so people working on other lines
      # never block each other. A sent line is voided (Kitchen::VoidSent),
      # not edited.
      module EditUnsentLine
        module_function

        # placement changes the line's course, hold and seat (keys present
        # only). Moving a dish to another seat changes no money and no
        # kitchen ticket, so a seat alone may change on a sent line too.
        def call(workspace:, staff:, key:, sale_line_id:, row_version:, quantity: nil, placement: {})
          place = placement!(placement)
          raise Conflict.new('Nothing to change.', reason: 'line_change_empty') if quantity.nil? && place.empty?

          payload = { 'command' => 'edit_unsent_line', 'sale_line_id' => sale_line_id.to_s, 'row_version' => row_version.to_s,
                      'quantity' => quantity, 'placement' => place }
          seat_only = quantity.nil? && place.keys == ['seat']
          AppendItems.run(workspace: workspace, staff: staff, key: key, payload: payload) do
            AppendItems.validate_append!(workspace, snapshot: !seat_only)
            sale_line = seat_only ? current_line!(workspace, sale_line_id, row_version) : unsent_line!(workspace, sale_line_id, row_version)
            base_quantity = quantity.nil? ? nil : ManageLineItem.change_quantity!(workspace, sale_line, quantity, nil)
            place!(sale_line, place) if place.any?
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.item.update', subject: workspace,
                               metadata: { sale_line_id: sale_line.prefixed_id, quantity: base_quantity, placement: place,
                                           row_version: sale_line.row_version })
            workspace.to_pos
          end
        end

        def placement!(placement)
          raw = (placement.respond_to?(:to_unsafe_h) ? placement.to_unsafe_h : placement.to_h).stringify_keys.slice('course', 'seat', 'hold')
          raw.to_h do |key, value|
            next [key, [true, 'true'].include?(value)] if key == 'hold'
            next [key, nil] if value.blank?

            [key, TableLines.small!(value, 1, key == 'course' ? CourseLabel::MAX : 99, "#{key}_invalid")]
          end
        end

        def place!(sale_line, place)
          sale_line.seat = place['seat'] if place.key?('seat')
          sale_line.course = place['course'] if place.key?('course')
          held = place.key?('hold') ? place['hold'] : sale_line.course_status == 'held'
          raise Conflict.new('Only a dish with a course can be held.', reason: 'course_invalid') if held && sale_line.course.nil?

          sale_line.course_status = held ? 'held' : 'none' if place.key?('hold') || place.key?('course')
          sale_line.save!
        end

        # The line as the client saw it, sent or not.
        def current_line!(workspace, sale_line_id, row_version)
          sale_line = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id)
          sale_line&.lock!
          Timed::Guard.not_timed!(sale_line, workspace)
          return sale_line if sale_line && sale_line.row_version.to_s == row_version.to_s

          raise Conflict.new('Someone else just changed this line.', revision: workspace.revision, reason: 'line_changed',
                                                                       details: { sale_line: sale_line && current(sale_line) })
        end

        # The line as the client saw it: still there, at the same version,
        # and not sent to the kitchen.
        def unsent_line!(workspace, sale_line_id, row_version)
          sale_line = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id)
          sale_line&.lock!
          Timed::Guard.not_timed!(sale_line, workspace)
          if sale_line.nil? || sale_line.row_version.to_s != row_version.to_s
            raise Conflict.new('Someone else just changed this line.', revision: workspace.revision, reason: 'line_changed',
                                                                         details: { sale_line: sale_line && current(sale_line) })
          end
          if sale_line.kitchen_sent_quantity.positive?
            raise Conflict.new('This line was already sent to the kitchen; void the sent part instead.',
                               revision: workspace.revision, reason: 'line_sent', details: { sale_line: current(sale_line) })
          end

          sale_line
        end

        def current(sale_line)
          { sale_line_id: sale_line.prefixed_id, row_version: sale_line.row_version, sale_quantity: sale_line.sale_quantity.to_s('F'),
            kitchen_sent_quantity: sale_line.kitchen_sent_quantity.to_s('F') }
        end
      end
    end
  end
end
