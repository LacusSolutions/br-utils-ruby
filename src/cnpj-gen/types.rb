# frozen_string_literal: true

module CnpjGen
  # Allowed values for the generator +type+ option.
  #
  # Character type for the generated CNPJ sequence:
  #
  # - +alphabetic+ — generates a sequence of alphabetic characters (+A-Z+).
  # - +alphanumeric+ (default) — generates a sequence of alphanumeric characters
  #   (+0-9A-Z+).
  # - +numeric+ — generates a sequence of numbers-only characters (+0-9+).
  CNPJ_TYPE_VALUES = %w[alphabetic alphanumeric numeric].freeze

  # Order used in invalid-type error messages.
  CNPJ_TYPE_OPTIONS_ORDER = CNPJ_TYPE_VALUES.freeze

  # Options input accepted by constructors and merge helpers.
  #
  # May be a {CnpjGeneratorOptions} instance, a {Hash} of option keys, or +nil+.
  #
  # Resolved options contain:
  #
  # - +format+ [Boolean] — whether to format the generated CNPJ string as
  #   +00.000.000/0000-00+ (default: +false+).
  # - +prefix+ [String] — a partial string containing 0 to 12 alphanumeric
  #   characters to use as the start of the generated CNPJ. Only alphanumeric
  #   characters are kept; the rest is stripped. If provided, only the missing
  #   characters are generated randomly. For example, if the +prefix+ +"AAABBB"+
  #   (6 characters) is given, only the next 8 characters are randomly generated
  #   and concatenated to the +prefix+.
  #
  #   A common use case is to provide a base ID (first 8 characters) and let the
  #   library generate the branch ID (characters 9 to 12) for multiple runs. This
  #   way you can generate multiple CNPJs under the same "business umbrella".
  #
  #   Note: If the evaluated +prefix+ (after stripping non-alphanumeric
  #   characters) is longer than 12 characters, the extra characters are ignored,
  #   because a CNPJ has 12 base characters followed by 2 calculated check digits.
  # - +type+ [String] — the character +type+ for random CNPJ segments (see
  #   {CNPJ_TYPE_VALUES}). If a +prefix+ is provided, only the remaining
  #   characters (those generated randomly) use this +type+.
  #
  # @see CnpjGeneratorOptions
  CnpjGeneratorOptionsInput = Object
end
