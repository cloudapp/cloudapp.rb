module CloudApp
  class DropListPresenter
    def initialize(drops)
      @drops = drops
    end

    def present
      pretty
    end

    protected

    def headers
      [ 'Name', 'Views', 'Href' ]
    end

    def pretty
      lines.map {|line|
        line.
          each_with_index.
          map {|value, i| value.ljust(column_widths[i]) }.
          join('  ')
      }.join("\n")
    end

    def lines
      @lines ||= @drops.map {|drop| [ drop.name, drop.views.to_s, drop.href ] }.unshift(headers)
    end

    def column_widths
      @column_widths ||= lines.transpose.map {|column| column.map(&:size).max }
    end
  end
end
