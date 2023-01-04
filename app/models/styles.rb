module Styles
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def styles
    data["basic_information"]["styles"]
  end

  module ClassMethods
    def filtered_by_style(value)
      where(id: all.select { |release| release.styles.include? value })
    end

    def most_collected_styles
      styles = all.map(&:styles)
      h = {}
      styles.each do |array|
        array.each do |style|
          h[style].nil? ? h[style] = 1 : h[style] += 1
        end
      end
      return h.sort_by { |_k, v| v }.reverse.to_h
    end
  end
end
