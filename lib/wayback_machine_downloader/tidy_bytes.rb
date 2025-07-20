# frozen_string_literal: true

module TidyBytes
  # precomputing CP1252 to UTF-8 mappings for bytes 128-159
  CP1252_MAP = (128..159).map do |byte|
    case byte
    when 128 then [226, 130, 172]  # EURO SIGN
    when 130 then [226, 128, 154]  # SINGLE LOW-9 QUOTATION MARK
    when 131 then [198, 146]       # LATIN SMALL LETTER F WITH HOOK
    when 132 then [226, 128, 158]  # DOUBLE LOW-9 QUOTATION MARK
    when 133 then [226, 128, 166]  # HORIZONTAL ELLIPSIS
    when 134 then [226, 128, 160]  # DAGGER
    when 135 then [226, 128, 161]  # DOUBLE DAGGER
    when 136 then [203, 134]       # MODIFIER LETTER CIRCUMFLEX ACCENT
    when 137 then [226, 128, 176]  # PER MILLE SIGN
    when 138 then [197, 160]       # LATIN CAPITAL LETTER S WITH CARON
    when 139 then [226, 128, 185]  # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    when 140 then [197, 146]       # LATIN CAPITAL LIGATURE OE
    when 142 then [197, 189]       # LATIN CAPITAL LETTER Z WITH CARON
    when 145 then [226, 128, 152]  # LEFT SINGLE QUOTATION MARK
    when 146 then [226, 128, 153]  # RIGHT SINGLE QUOTATION MARK
    when 147 then [226, 128, 156]  # LEFT DOUBLE QUOTATION MARK
    when 148 then [226, 128, 157]  # RIGHT DOUBLE QUOTATION MARK
    when 149 then [226, 128, 162]  # BULLET
    when 150 then [226, 128, 147]  # EN DASH
    when 151 then [226, 128, 148]  # EM DASH
    when 152 then [203, 156]       # SMALL TILDE
    when 153 then [226, 132, 162]  # TRADE MARK SIGN
    when 154 then [197, 161]       # LATIN SMALL LETTER S WITH CARON
    when 155 then [226, 128, 186]  # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    when 156 then [197, 147]       # LATIN SMALL LIGATURE OE
    when 158 then [197, 190]       # LATIN SMALL LETTER Z WITH CARON
    when 159 then [197, 184]       # LATIN SMALL LETTER Y WITH DIAERESIS
    else nil                       # ANYTHING ELSE...
    end
  end.freeze

  # precomputing all possible byte conversions 
  CP1252_TO_UTF8 = Array.new(256) do |b|
    if (128..159).cover?(b)
      CP1252_MAP[b - 128]&.pack('C*')
    elsif b < 128
      b.chr
    else
      b < 192 ? [194, b].pack('C*') : [195, b - 64].pack('C*')
    end
  end.freeze

  def self.included(base)
    base.class_eval do
      def tidy_bytes(force = false)
        return nil if empty?
        
        if force
          buffer = String.new(capacity: bytesize)
          each_byte { |b| buffer << CP1252_TO_UTF8[b] }
          return buffer.force_encoding(Encoding::UTF_8)
        end

        begin
          encode('UTF-8')
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
          buffer = String.new(capacity: bytesize)
          scrub { |b| CP1252_TO_UTF8[b.ord] }
        end
      end

      def tidy_bytes!(force = false)
        result = tidy_bytes(force)
        result ? replace(result) : self
      end
    end
  end
end

class String
  include TidyBytes
end