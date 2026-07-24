# frozen_string_literal: true

class CpfUtils
  # Nested package module — same object as +::CpfVal+ (helpers, errors, types).
  CpfVal = ::CpfVal

  CpfValidator = CpfVal::CpfValidator
  CpfValidatorError = CpfVal::Error
end
