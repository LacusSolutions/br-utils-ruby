# frozen_string_literal: true

class CpfUtils
  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CpfUtils::Error+ to catch every library error regardless of
  # native ancestry. Component packages raise their own error hierarchies;
  # this gem only defines the misuse errors it raises itself.
  module Error; end

  # API misuse error raised when an argument's runtime type does not match the
  # type required by the API contract (for example, a non-Hash +settings+ value).
  class TypeMismatchError < TypeError
    include Error
  end

  # API misuse error raised when the combination of provided arguments does not
  # match any valid overload-style signature (for example, a settings/options
  # Hash together with keyword overrides).
  class InvalidArgumentCombinationError < ArgumentError
    include Error
  end
end
