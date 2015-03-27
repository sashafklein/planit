module SuperBase
  def to_yaml
    to_normal.to_yaml.gsub(/([\s|^]*):(\S+:)([\s|$]+)/){ "#{$1}#{$2}#{$3}" }.gsub("---\n", '') #.gsub('  ', ' ').gsub(/(\s+)-/){ "#{$1} -" }.gsub(/^(\s+)/){ "#{$1.length.odd? ? $1 + ' ' : $1}" }
  end

  def to_normal
    is_a?(Hash) ? to_h : to_a
  end

  def deep_compact(allow_blank: true)
    new_el = is_a?(Hash) ? {} : []
    if is_a?(Hash)
      each_pair do |k, v|
        compacted = compactify(v: v, allow_blank: allow_blank)
        new_el[k] = compacted if compacted
      end
    else
      each_with_index do |v, i|
        compacted = compactify(v: v, allow_blank: allow_blank)
        new_el[i] = compacted if compacted
      end
    end
    new_el
  end

  private

  def compactify(v:, allow_blank: true)
    if v.is_a_or_h?
      v.deep_compact(allow_blank: allow_blank)
    elsif !v.send( allow_blank ? :nil? : :blank? )
      v
    end
  end
end