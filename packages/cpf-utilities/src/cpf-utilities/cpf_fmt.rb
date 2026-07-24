# frozen_string_literal: true

class CpfUtils
  # Nested package module — same object as +::CpfFmt+ (Options, helpers, errors, types).
  CpfFmt = ::CpfFmt

  CpfFormatter = CpfFmt::CpfFormatter
  CpfFormatterOptions = CpfFmt::CpfFormatterOptions
  CpfFormatterError = CpfFmt::Error
end
