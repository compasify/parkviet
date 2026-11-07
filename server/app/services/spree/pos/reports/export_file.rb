# frozen_string_literal: true

require 'csv'

module Spree
  module Pos
    module Reports
      # CSV for a report, safe to open in a spreadsheet: any text cell that
      # starts (after optional leading whitespace) with =, +, -, @, or starts
      # with a tab or carriage return is prefixed with an apostrophe so it is
      # never evaluated as a formula. Plain numbers (amounts like -100000.0)
      # are data, not formulas, and stay numeric. The file starts with a UTF-8
      # BOM so spreadsheet apps read Vietnamese text correctly.
      module ExportFile
        FORMULA_START = /\A(?:[\t\r]|\s*[=+\-@])/
        NUMBER = /\A-?\d+(\.\d+)?\z/
        MAX_ROWS = 100_000
        BOM = "﻿"

        # Raised when the filtered report is too large for one file.
        class TooLarge < StandardError; end

        module_function

        # Streams rows into `io` (a Tempfile) and returns the row count.
        def write(report, io)
          columns = report.columns
          count = 0
          io.write(BOM)
          csv = ::CSV.new(io)
          csv << columns
          report.each_row do |row|
            count += 1
            raise TooLarge, "More than #{MAX_ROWS} rows; narrow the filters." if count > MAX_ROWS

            csv << columns.map { |column| cell(row[column.to_sym]) }
          end
          count
        end

        def cell(value)
          text = value.nil? ? '' : value.to_s
          return text if text.match?(NUMBER)

          text.match?(FORMULA_START) ? "'#{text}" : text
        end
      end
    end
  end
end
