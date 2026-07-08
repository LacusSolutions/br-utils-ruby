# frozen_string_literal: true

require 'securerandom'

module LacusUtils
  NUMERIC_CHARACTERS = '0123456789'
  ALPHABETIC_CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  ALPHANUMERIC_CHARACTERS = (NUMERIC_CHARACTERS + ALPHABETIC_CHARACTERS).freeze

  SEQUENCE_CHARACTER_SETS = {
    numeric: NUMERIC_CHARACTERS,
    alphabetic: ALPHABETIC_CHARACTERS,
    alphanumeric: ALPHANUMERIC_CHARACTERS
  }.freeze

  # Generates a random character sequence of the given length and type (numeric,
  # alphabetic, or alphanumeric), drawn using a cryptographically secure RNG.
  #
  # @param size [Integer] length of the sequence
  # @param type [Symbol] character set to draw from; one of +:numeric+ (+0-9+),
  #   +:alphabetic+ (+A-Z+), or +:alphanumeric+ (+0-9A-Z+). Defaults to
  #   +:alphanumeric+.
  # @return [String] a random string of the requested length using uppercase
  #   letters and/or digits, depending on +type+
  # @raise [ArgumentError] if +size+ is negative
  # @raise [ArgumentError] if +type+ is not one of the known kinds
  #
  # @example
  #   LacusUtils.generate_random_sequence(10, :numeric)      # => e.g. '9956000611'
  #   LacusUtils.generate_random_sequence(6, :alphabetic)    # => e.g. 'AXQMZB'
  #   LacusUtils.generate_random_sequence(8, :alphanumeric)  # => e.g. '8ZFB2K09'
  #   LacusUtils.generate_random_sequence(8)                 # => e.g. '8ZFB2K09' (alphanumeric)
  def self.generate_random_sequence(size, type = :alphanumeric)
    raise ArgumentError, "size must be non-negative, got #{size}" if size.negative?

    characters = SEQUENCE_CHARACTER_SETS[type.to_sym]

    raise ArgumentError, "unknown sequence type: #{type.inspect}" if characters.nil?

    length = characters.length

    Array.new(size) { characters[SecureRandom.random_number(length)] }.join
  end
end
