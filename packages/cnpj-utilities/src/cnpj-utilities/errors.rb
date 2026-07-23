# frozen_string_literal: true

class CnpjUtils
  # Marker module mixed into every custom error raised by this library.
  #
  # Use +rescue CnpjUtils::Error+ to catch every library error regardless of
  # native ancestry. Component packages raise their own error hierarchies;
  # this gem only defines the misuse errors it raises itself.
  module Error; end

  # API misuse error raised when the combination of provided arguments does not
  # match any valid overload-style signature (for example, a settings/options
  # Hash together with keyword overrides).
  class InvalidArgumentCombinationError < ArgumentError
    include Error
  end
end
