# frozen_string_literal: true

# essentially, this is for converting a string with a potentially
# broken or unknown encoding into a valid UTF-8 string
# @todo: consider using charlock_holmes for this in the future
module TidyBytes
  UNICODE_REPLACEMENT_CHARACTER = "�"

  # common encodings to try for best multilingual compatibility
  COMMON_ENCODINGS = [
    Encoding::UTF_8,
    Encoding::Windows_1251, # Cyrillic/Russian legacy
    Encoding::GB18030,      # Simplified Chinese
    Encoding::Shift_JIS,    # Japanese
    Encoding::EUC_KR,       # Korean
    Encoding::ISO_8859_1,   # Western European
    Encoding::Windows_1252  # Western European/Latin1 superset
  ].select { |enc| Encoding.name_list.include?(enc.name) }

  # returns true if the string appears to be binary (has null bytes)
  def binary_data?
    self.include?("\x00".b)
  end

  # attempts to return a valid UTF-8 version of the string
  def tidy_bytes
    return self if self.encoding == Encoding::UTF_8 && self.valid_encoding?
    return self.dup.force_encoding("BINARY") if binary_data?

    str = self.dup
    COMMON_ENCODINGS.each do |enc|
      str.force_encoding(enc)
      begin
        utf8 = str.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: UNICODE_REPLACEMENT_CHARACTER)
        return utf8 if utf8.valid_encoding? && !utf8.include?(UNICODE_REPLACEMENT_CHARACTER)
      rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
        # try next encoding
      end
    end

    # if no clean conversion found, try again but accept replacement characters
    str = self.dup
    COMMON_ENCODINGS.each do |enc|
      str.force_encoding(enc)
      begin
        utf8 = str.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: UNICODE_REPLACEMENT_CHARACTER)
        return utf8 if utf8.valid_encoding?
      rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
        # try next encoding
      end
    end

    # fallback: replace all invalid/undefined bytes
    str.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: UNICODE_REPLACEMENT_CHARACTER)
  end

  def tidy_bytes!
    replace(self.tidy_bytes)
  end

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def tidy_bytes
      TidyBytes.instance_method(:tidy_bytes).bind(self).call
    end

    def tidy_bytes!
      TidyBytes.instance_method(:tidy_bytes!).bind(self).call
    end
  end
end

class String
  include TidyBytes
end