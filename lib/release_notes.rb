# frozen_string_literal: true

require 'fileutils'
require 'pathname'

# Extracts a single version's notes from a package CHANGELOG.md, mirroring the
# Python sibling's `run release` helper. Given a package directory name and an
# optional version, it writes the matching CHANGELOG section to
# `.release/<package>@<version>.md` and returns that path. When no version is
# supplied, the top-most (latest) section in the changelog is used.
#
# Pure Ruby, no external dependencies, so it behaves identically when invoked
# locally (`bin/release-notes`) and from CI (the Release workflow).
module ReleaseNotes
  ROOT = Pathname(File.expand_path('..', __dir__))
  PACKAGES_DIR = ROOT.join('packages')
  RELEASE_DIR = ROOT.join('.release')

  # A changelog version heading, e.g. "## 1.2.3" or "## 1.2.3.rc1".
  VERSION_HEADING = /\A\#\#[ \t]+(\d+\.\d+\.\d+(?:[.-][0-9A-Za-z.-]+)?)[ \t]*\z/
  # A valid explicitly-requested version string.
  VERSION_FORMAT = /\A\d+\.\d+\.\d+(?:[.-][0-9A-Za-z.-]+)?\z/

  class Error < StandardError; end

  module_function

  # Write the release notes file for +package+ and return its Pathname.
  # +version+ may be nil/blank to select the latest changelog section.
  def prepare(package, version = nil)
    version = nil if version.is_a?(String) && version.strip.empty?
    validate_version!(version)

    bodies = changelog_bodies(package)
    selected = select_version(bodies, version)

    FileUtils.mkdir_p(RELEASE_DIR)
    output = RELEASE_DIR.join("#{package}@#{selected}.md")
    output.write("#{bodies[selected]}\n")
    output
  end

  # Ordered Hash of version => body (top-most heading first) for a package.
  def changelog_bodies(package)
    path = PACKAGES_DIR.join(package, 'CHANGELOG.md')
    raise Error, "Changelog not found: #{path}" unless path.file?

    bodies = extract_bodies(path.read)
    raise Error, "No version sections found in changelog: #{path}" if bodies.empty?

    bodies
  end

  # Parse changelog markdown into an ordered Hash of version => trimmed body.
  def extract_bodies(markdown)
    sections = markdown.lines.slice_before { |line| line.chomp.match?(VERSION_HEADING) }

    sections.each_with_object({}) do |lines, bodies|
      heading = lines.first.chomp.match(VERSION_HEADING)
      next unless heading

      bodies[heading[1]] = lines.drop(1).join.strip
    end
  end

  def select_version(bodies, version)
    return bodies.keys.first if version.nil?
    return version if bodies.key?(version)

    available = bodies.keys.join(', ')
    raise Error, "Version not found in changelog: #{version}. Available versions: #{available}"
  end

  def validate_version!(version)
    return if version.nil? || VERSION_FORMAT.match?(version)

    raise Error, "Invalid version format: #{version}. Expected X.Y.Z or X.Y.Z with a prerelease suffix"
  end
end
