# frozen_string_literal: true

module CpfGen
  # Options input accepted by constructors and merge helpers.
  #
  # May be a {CpfGeneratorOptions} instance, a {Hash} of option keys, or +nil+.
  #
  # Resolved options contain:
  #
  # - +format+ [Boolean] — whether to format the generated CPF string as
  #   +000.000.000-00+ (default: +false+).
  # - +prefix+ [String] — a partial string containing 0 to 9 digits to use as the
  #   start of the generated CPF. Only digits are kept; the rest is stripped. If
  #   provided, only the missing digits are generated randomly. For example, if
  #   the +prefix+ +"123456"+ (6 digits) is given, only the next 3 digits are
  #   randomly generated and concatenated to the +prefix+.
  #
  #   Note: If the evaluated +prefix+ (after stripping non-digit characters) is
  #   longer than 9 digits, the extra digits are ignored, because a CPF has 9
  #   base digits followed by 2 calculated check digits.
  #
  # @see CpfGeneratorOptions
  CpfGeneratorOptionsInput = Object
end
