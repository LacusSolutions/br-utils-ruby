# frozen_string_literal: true

class CpfUtils
  # Nested package module — same object as +::CpfGen+ (Options, helpers, errors, types).
  CpfGen = ::CpfGen

  CpfGenerator = CpfGen::CpfGenerator
  CpfGeneratorOptions = CpfGen::CpfGeneratorOptions
  CpfGeneratorError = CpfGen::Error
end
