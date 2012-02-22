require 'csv'
require 'delegate'

module CloudApp
  class DropPresenter
    def initialize(io, format, waiting, columns, action)
      @io      = io
      @format  = format
      @waiting = waiting
      @columns = columns
      @action  = action
    end

    def self.print(options, &action)
      new(options.fetch(:on),
          options.fetch(:format, :pretty),
          options.fetch(:waiting, nil),
          options.fetch(:columns, nil),
          action).print
    end

    def pretty?() @format == :pretty end
    def csv?()    @format == :csv    end

    def print
      @io.print @waiting if pretty?
      @io.puts  lines
    end

  protected

    def lines
      if not @columns
        response
      else
        headings = @columns.values
        lines    = response.inject([ headings ]) do |lines, item|
          lines << extract_values(item)
        end

        if csv?
          csv = CSV.generate do |csv|
            lines.each do |line|
              csv << line
            end
          end
        else
          column_widths = lines.transpose.map do |column|
            column.map(&:size).max
          end

          lines.map do |line|
            line.each_with_index.map do |value, i|
              value.ljust column_widths[i]
            end.join '  '
          end
        end
      end
    end

    def extract_values(item)
      value_methods.map do |method|
        item.send(method).to_s
      end
    end

    def value_methods
      @columns.keys
    end

    def response
      @response ||= @action.call

      case @response
      when Hash then @response.fetch(@format, @response)
      else @response
      end
    end
  end
end
