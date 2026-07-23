# frozen_string_literal: true

class CnpjUtils
  # Nested package module — same object as +::CnpjFmt+ (Options, helpers, errors, types).
  CnpjFmt = ::CnpjFmt

  CnpjFormatter = CnpjFmt::CnpjFormatter
  CnpjFormatterOptions = CnpjFmt::CnpjFormatterOptions
  CnpjFormatterError = CnpjFmt::Error
end
