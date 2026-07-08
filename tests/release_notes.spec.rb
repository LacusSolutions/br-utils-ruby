# frozen_string_literal: true

require 'spec_helper'
require 'release_notes'

RSpec.describe ReleaseNotes do
  describe '.extract_bodies' do
    subject(:bodies) { described_class.extract_bodies(markdown) }

    context 'with multiple version sections' do
      let(:markdown) do
        <<~MARKDOWN
          # cpf-dv

          ## 1.1.0

          ### New features

          - **Batch**: add `CpfDv.batch`.

          ## 1.0.0

          ### 🚀 Stable Version Released!

          - Initial release.
        MARKDOWN
      end

      it 'keeps the latest section first' do
        expect(bodies.keys).to eq(['1.1.0', '1.0.0'])
      end

      it 'captures the body of the latest section' do
        expect(bodies['1.1.0']).to eq("### New features\n\n- **Batch**: add `CpfDv.batch`.")
      end

      it 'captures the body of an older section' do
        expect(bodies['1.0.0']).to eq("### 🚀 Stable Version Released!\n\n- Initial release.")
      end
    end

    context 'with a prerelease heading' do
      let(:markdown) { "# pkg\n\n## 2.0.0.rc1\n\n- Release candidate.\n" }

      it 'recognizes the prerelease version' do
        expect(bodies.keys).to eq(['2.0.0.rc1'])
      end
    end

    context 'when a sub-heading looks like a version' do
      let(:markdown) { "# pkg\n\n## 1.0.0\n\n### 1.0.0 details\n\n- Note.\n" }

      it 'does not treat "###" sub-headings as version sections' do
        expect(bodies.keys).to eq(['1.0.0'])
      end

      it 'keeps the sub-heading inside the body' do
        expect(bodies['1.0.0']).to eq("### 1.0.0 details\n\n- Note.")
      end
    end

    context 'without any version heading' do
      let(:markdown) { "# pkg\n\nNo releases yet.\n" }

      it { is_expected.to be_empty }
    end
  end

  describe '.select_version' do
    let(:bodies) { { '1.1.0' => 'newer', '1.0.0' => 'older' } }

    context 'without a requested version' do
      it 'returns the latest version' do
        expect(described_class.select_version(bodies, nil)).to eq('1.1.0')
      end
    end

    context 'with a requested version present in the changelog' do
      it 'returns that version' do
        expect(described_class.select_version(bodies, '1.0.0')).to eq('1.0.0')
      end
    end

    context 'with a requested version missing from the changelog' do
      it 'raises with the available versions listed' do
        expect { described_class.select_version(bodies, '9.9.9') }
          .to raise_error(described_class::Error, /Available versions: 1\.1\.0, 1\.0\.0/)
      end
    end
  end

  describe '.prepare' do
    context 'with a malformed requested version' do
      it 'raises before touching the filesystem' do
        expect { described_class.prepare('lacus-utils', 'not-a-version') }
          .to raise_error(described_class::Error, /Invalid version format/)
      end
    end

    context 'with a package that has no changelog' do
      it 'raises a not-found error' do
        expect { described_class.prepare('does-not-exist') }
          .to raise_error(described_class::Error, /Changelog not found/)
      end
    end
  end
end
