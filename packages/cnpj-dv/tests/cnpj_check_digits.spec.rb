# frozen_string_literal: true

require 'spec_helper'

# Shared conformance fixtures: [12-char base, expected 14-char CNPJ].
CNPJ_DV_TEST_CASES = [
  %w[313124260006 31312426000619],
  %w[MGKGMJ9X0001 MGKGMJ9X000168],
  %w[1EY6WPPN0001 1EY6WPPN000164],
  %w[Y7ELKY990001 Y7ELKY99000137],
  %w[AGPRASLP0001 AGPRASLP000123],
  %w[017205400003 01720540000374],
  %w[615208400003 61520840000331],
  %w[ABDYZVE90001 ABDYZVE9000144],
  %w[050532360008 05053236000886],
  %w[CCLW1PDP0001 CCLW1PDP000131],
  %w[JLNC9SM70001 JLNC9SM7000118],
  %w[51GLNYMV0001 51GLNYMV000138],
  %w[003579820002 00357982000254],
  %w[573669460004 57366946000436],
  %w[412851460002 41285146000299],
  %w[159833710006 15983371000612],
  %w[R39X6CAD0001 R39X6CAD000118],
  %w[LA031XPE0001 LA031XPE000171],
  %w[8CRCX4G90001 8CRCX4G9000145],
  %w[002439100008 00243910000871],
  %w[570635620003 57063562000363],
  %w[210890360007 21089036000759],
  %w[483494070001 48349407000155],
  %w[871056390003 87105639000381],
  %w[ZP64G0G50001 ZP64G0G5000169],
  %w[RTCR3YKJ0001 RTCR3YKJ000139],
  %w[914157320007 91415732000793],
  %w[167805610002 16780561000271],
  %w[4SGW7L2V0001 4SGW7L2V000192],
  %w[51CGZ6CE0001 51CGZ6CE000166],
  %w[4TD25XEB0001 4TD25XEB000186],
  %w[C892RYMB0001 C892RYMB000166],
  %w[006645070002 00664507000220],
  %w[711081470005 71108147000571],
  %w[410302000007 41030200000760],
  %w[863940890002 86394089000214],
  %w[CCBHVLD70001 CCBHVLD7000109],
  %w[Y8E3T0H20001 Y8E3T0H2000127],
  %w[015206300003 01520630000311],
  %w[4LHTLHRR0001 4LHTLHRR000129],
  %w[669041680003 66904168000300],
  %w[470076350005 47007635000508],
  %w[DSX3851R0001 DSX3851R000123],
  %w[517503930003 51750393000353],
  %w[456189710004 45618971000480],
  %w[SVAERM5X0001 SVAERM5X000180],
  %w[479281750001 47928175000127],
  %w[TVHW9KYC0001 TVHW9KYC000168],
  %w[982882590009 98288259000931],
  %w[648275500008 64827550000838],
  %w[023543810003 02354381000302],
  %w[HPC6L9ZB0001 HPC6L9ZB000101],
  %w[822313180002 82231318000229],
  %w[W7SJP7J10001 W7SJP7J1000104],
  %w[784153420007 78415342000755],
  %w[451264770004 45126477000407],
  %w[HHVRZ7860001 HHVRZ786000190],
  %w[4BB2CZY00001 4BB2CZY0000107],
  %w[YYWVGRDP0001 YYWVGRDP000103],
  %w[005792660004 00579266000483],
  %w[2V802ATH0001 2V802ATH000108],
  %w[HVWA2TC40001 HVWA2TC4000139],
  %w[J4LR5KNM0001 J4LR5KNM000119],
  %w[KL46HEJ50001 KL46HEJ5000106],
  %w[SZS0X62H0001 SZS0X62H000177],
  %w[JM6VWMAZ0001 JM6VWMAZ000126],
  %w[885435950009 88543595000920],
  %w[1DYMEV6W0001 1DYMEV6W000188],
  %w[758805710006 75880571000671],
  %w[NK78LS4Z0001 NK78LS4Z000127],
  %w[238857260004 23885726000405],
  %w[723362430001 72336243000106],
  %w[JG3TE2X30001 JG3TE2X3000167],
  %w[782152520001 78215252000125],
  %w[283366280009 28336628000939],
  %w[E6SN8JC40001 E6SN8JC4000149],
  %w[79YJNKHZ0001 79YJNKHZ000110],
  %w[47GZ4GL10001 47GZ4GL1000127],
  %w[069523030004 06952303000433],
  %w[474080600006 47408060000616],
  %w[040693560006 04069356000647],
  %w[THTV6BM20001 THTV6BM2000157],
  %w[TPY675ZN0001 TPY675ZN000119],
  %w[KS4E7SAA0001 KS4E7SAA000176],
  %w[NMPEHEVB0001 NMPEHEVB000129],
  %w[1M917XTB0001 1M917XTB000176],
  %w[J9M0ZD510001 J9M0ZD51000123],
  %w[P0G334BY0001 P0G334BY000136],
  %w[076394320005 07639432000510],
  %w[992040290001 99204029000152],
  %w[2D56RWZP0001 2D56RWZP000195],
  %w[M68N7W6L0001 M68N7W6L000175],
  %w[LH9B5RXK0001 LH9B5RXK000171],
  %w[495517490003 49551749000388],
  %w[307168390003 30716839000353],
  %w[Y0EBSBLT0001 Y0EBSBLT000105],
  %w[C9DASM460001 C9DASM46000190],
  %w[ZZ0172HG0001 ZZ0172HG000130],
  %w[6DYLY5060001 6DYLY506000113],
  %w[JE5TKSJ80001 JE5TKSJ8000109],
  %w[TRPYT31P0001 TRPYT31P000124],
  %w[144863760009 14486376000910],
  %w[KZEWGKT60001 KZEWGKT6000198],
  %w[S28361BX0001 S28361BX000165],
  %w[6VK1VBLW0001 6VK1VBLW000154],
  %w[KJT4XC490001 KJT4XC49000165],
  %w[H8SS5ZTT0001 H8SS5ZTT000104],
  %w[5PYHBL870001 5PYHBL87000149],
  %w[ZAB6JG9E0001 ZAB6JG9E000148],
  %w[354946770003 35494677000370],
  %w[J0EHJEXT0001 J0EHJEXT000130],
  %w[539MLKGS0001 539MLKGS000154],
  %w[319476190003 31947619000301],
  %w[ZWW4XY8X0001 ZWW4XY8X000183],
  %w[D83TW2JG0001 D83TW2JG000100],
  %w[KPJR04DT0001 KPJR04DT000143],
  %w[301272110005 30127211000584],
  %w[G4T4BTDR0001 G4T4BTDR000120],
  %w[509053950004 50905395000492],
  %w[W95P9DKV0001 W95P9DKV000194]
].freeze

CNPJ_DV_REPEATED_DIGIT_INPUTS = [
  '111111111111',
  '222222222222',
  '333333333333',
  '444444444444',
  '555555555555',
  '666666666666',
  '777777777777',
  '888888888888',
  '999999999999',
  %w[111111111111],
  %w[222222222222],
  %w[333333333333],
  %w[444444444444],
  %w[555555555555],
  %w[666666666666],
  %w[777777777777],
  %w[888888888888],
  %w[999999999999],
  %w[11 111 111 1111],
  %w[22 222 222 2222],
  %w[33 333 333 3333],
  %w[44 444 444 4444],
  %w[55 555 555 5555],
  %w[66 666 666 6666],
  %w[77 777 777 7777],
  %w[88 888 888 8888],
  %w[99 999 999 9999],
  %w[1 1 1 1 1 1 1 1 1 1 1 1],
  %w[2 2 2 2 2 2 2 2 2 2 2 2],
  %w[3 3 3 3 3 3 3 3 3 3 3 3],
  %w[4 4 4 4 4 4 4 4 4 4 4 4],
  %w[5 5 5 5 5 5 5 5 5 5 5 5],
  %w[6 6 6 6 6 6 6 6 6 6 6 6],
  %w[7 7 7 7 7 7 7 7 7 7 7 7],
  %w[8 8 8 8 8 8 8 8 8 8 8 8],
  %w[9 9 9 9 9 9 9 9 9 9 9 9]
].freeze

CNPJ_DV_REPEATED_LETTER_INPUTS = [
  'AAAAAAAAAAAA',
  'BBBBBBBBBBBB',
  'CCCCCCCCCCCC',
  'JJJJJJJJJJJJ',
  'KKKKKKKKKKKK',
  'LLLLLLLLLLLL',
  'XXXXXXXXXXXX',
  'YYYYYYYYYYYY',
  'ZZZZZZZZZZZZ',
  %w[AAAAAAAAAAAA],
  %w[BBBBBBBBBBBB],
  %w[CCCCCCCCCCCC],
  %w[JJJJJJJJJJJJ],
  %w[KKKKKKKKKKKK],
  %w[LLLLLLLLLLLL],
  %w[XXXXXXXXXXXX],
  %w[YYYYYYYYYYYY],
  %w[ZZZZZZZZZZZZ],
  %w[A A A A A A A A A A A A],
  %w[B B B B B B B B B B B B],
  %w[C C C C C C C C C C C C],
  %w[J J J J J J J J J J J J],
  %w[K K K K K K K K K K K K],
  %w[L L L L L L L L L L L L],
  %w[X X X X X X X X X X X X],
  %w[Y Y Y Y Y Y Y Y Y Y Y Y],
  %w[Z Z Z Z Z Z Z Z Z Z Z Z]
].freeze

CNPJ_DV_INVALID_BASE_ID_INPUTS = [
  '000000000001',
  '00.000.000/0001',
  %w[00 000 000 0001],
  %w[0 0 0 0 0 0 0 0 0 0 0 1]
].freeze

CNPJ_DV_INVALID_BRANCH_ID_INPUTS = [
  '123456780000',
  '12345678/0000',
  %w[12 345 678 0000],
  %w[1 2 3 4 5 6 7 8 0 0 0 0]
].freeze

CNPJ_DV_INVALID_LENGTH_INPUTS = [
  '',
  [],
  '12345678910',
  '123456789101112',
  %w[1 2 3 4 5 6 7 8 9 10],
  %w[0 0 1 1 1 2 2 2 0 0 0 4 5 6 7]
].freeze

CNPJ_DV_INVALID_TYPE_INPUTS = [
  12_345_678_901,
  nil,
  { cnpj: '12345678901' },
  [1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, '2', 3, '4', 5]
].freeze

# Spy subclass that counts modulo-11 calculator invocations (caching assertions).
class CnpjCheckDigitsWithCalculateSpy < CnpjDV::CnpjCheckDigits
  attr_reader :calculate_call_count

  def initialize(cnpj_input)
    @calculate_call_count = 0
    super
  end

  def _calculate(cnpj_sequence)
    @calculate_call_count += 1
    super
  end
end

RSpec.describe CnpjDV::CnpjCheckDigits do
  describe '#initialize' do
    context 'when given invalid input type' do
      CNPJ_DV_INVALID_TYPE_INPUTS.each do |cnpj_input|
        it 'raises TypeMismatchError' do
          expect { described_class.new(cnpj_input) }
            .to raise_error(CnpjDV::TypeMismatchError)
        end
      end

      it 'is rescuable as CnpjDV::Error' do
        expect { described_class.new(12_345) }
          .to raise_error(CnpjDV::Error)
      end
    end

    context 'when given invalid input length' do
      CNPJ_DV_INVALID_LENGTH_INPUTS.each do |cnpj_input|
        it 'raises InvalidLengthError' do
          expect { described_class.new(cnpj_input) }
            .to raise_error(CnpjDV::InvalidLengthError)
        end
      end

      it 'is rescuable as CnpjDV::DomainError and CnpjDV::Error' do
        expect { described_class.new('12345678901') }
          .to raise_error(CnpjDV::DomainError)
        expect { described_class.new('12345678901') }
          .to raise_error(CnpjDV::Error)
      end
    end

    context 'when given invalid CNPJ base ID' do
      CNPJ_DV_INVALID_BASE_ID_INPUTS.each do |cnpj_input|
        it 'raises ValidationError' do
          expect { described_class.new(cnpj_input) }
            .to raise_error(CnpjDV::ValidationError, /base id/i)
        end
      end

      it 'is rescuable as CnpjDV::DomainError and CnpjDV::Error' do
        expect { described_class.new('000000000001') }
          .to raise_error(CnpjDV::ValidationError) { |error|
            expect(error).to be_a(CnpjDV::DomainError)
            expect(error).to be_a(CnpjDV::Error)
          }
      end
    end

    context 'when given invalid CNPJ branch ID' do
      CNPJ_DV_INVALID_BRANCH_ID_INPUTS.each do |cnpj_input|
        it 'raises ValidationError' do
          expect { described_class.new(cnpj_input) }
            .to raise_error(CnpjDV::ValidationError, /branch id/i)
        end
      end
    end

    context 'when given repeated numeric characters' do
      CNPJ_DV_REPEATED_DIGIT_INPUTS.each do |cnpj_input|
        it 'raises ValidationError' do
          expect { described_class.new(cnpj_input) }
            .to raise_error(CnpjDV::ValidationError, /repeated digits/i)
        end
      end
    end

    context 'when given repeated non-numeric characters' do
      CNPJ_DV_REPEATED_LETTER_INPUTS.each do |cnpj_input|
        it 'accepts and computes digits' do
          stringified = cnpj_input.is_a?(Array) ? cnpj_input.join : cnpj_input
          result = described_class.new(cnpj_input)

          aggregate_failures do
            expect(result.cnpj.length).to eq(14)
            expect(result.cnpj).to start_with(stringified)
          end
        end
      end
    end
  end

  describe '#first' do
    context 'when input is a string' do
      CNPJ_DV_TEST_CASES.each do |base, full|
        it "returns first digit for #{base}" do
          expect(described_class.new(base).first).to eq(full[-2])
        end
      end
    end

    context 'when input is an array of strings' do
      CNPJ_DV_TEST_CASES.each do |base, full|
        it "returns first digit for #{base}" do
          expect(described_class.new(base.chars).first).to eq(full[-2])
        end
      end
    end

    context 'when accessing digits multiple times' do
      subject(:check_digits) { CnpjCheckDigitsWithCalculateSpy.new('914157320007') }

      it 'caches the calculator result' do
        3.times { check_digits.first }

        expect(check_digits.calculate_call_count).to eq(1)
      end
    end
  end

  describe '#second' do
    context 'when input is a string' do
      CNPJ_DV_TEST_CASES.each do |base, full|
        it "returns second digit for #{base}" do
          expect(described_class.new(base).second).to eq(full[-1])
        end
      end
    end

    context 'when input is an array of strings' do
      CNPJ_DV_TEST_CASES.each do |base, full|
        it "returns second digit for #{base}" do
          expect(described_class.new(base.chars).second).to eq(full[-1])
        end
      end
    end

    context 'when accessing digits multiple times' do
      subject(:check_digits) { CnpjCheckDigitsWithCalculateSpy.new('914157320007') }

      it 'caches both digit calculations' do
        3.times { check_digits.second }

        expect(check_digits.calculate_call_count).to eq(2)
      end
    end
  end

  describe '#both' do
    context 'when input is a string' do
      CNPJ_DV_TEST_CASES.each do |base, full|
        it "returns both digits for #{base}" do
          expect(described_class.new(base).both).to eq(full[-2, 2])
        end
      end
    end

    context 'when input is an array of strings' do
      CNPJ_DV_TEST_CASES.each do |base, full|
        it "returns both digits for #{base}" do
          expect(described_class.new(base.chars).both).to eq(full[-2, 2])
        end
      end
    end
  end

  describe '#cnpj' do
    context 'when input is a string' do
      it 'returns the 14-character CNPJ' do
        expect(described_class.new('914157320007').cnpj).to eq('91415732000793')
      end
    end

    context 'when input is an array of grouped characters' do
      it 'returns the 14-character CNPJ' do
        expect(described_class.new(%w[9141 5732 0007]).cnpj).to eq('91415732000793')
      end
    end

    context 'when input is an array of individual characters' do
      it 'returns the 14-character CNPJ' do
        expect(described_class.new(%w[9 1 4 1 5 7 3 2 0 0 0 7]).cnpj)
          .to eq('91415732000793')
      end
    end

    context 'when validating all test cases' do
      CNPJ_DV_TEST_CASES.each do |base, full|
        it "returns #{full} for #{base}" do
          expect(described_class.new(base).cnpj).to eq(full)
        end
      end
    end
  end

  describe 'edge cases' do
    context 'when input is a formatted CNPJ string' do
      it 'parses and calculates digits' do
        expect(described_class.new('91.415.732/0007').cnpj).to eq('91415732000793')
      end
    end

    context 'when input is a formatted alphanumeric CNPJ' do
      [
        'MG.KGM.J9X/0001-68',
        'mg.kgm.j9x/0001-68'
      ].each do |cnpj_input|
        it 'parses and calculates digits' do
          expect(described_class.new(cnpj_input).cnpj).to eq('MGKGMJ9X000168')
        end
      end
    end

    context 'when input already contains check digits' do
      subject(:check_digits) { described_class.new('91415732000700') }

      it 'ignores provided digits and recomputes' do
        aggregate_failures do
          expect(check_digits.first).to eq('9')
          expect(check_digits.second).to eq('3')
          expect(check_digits.cnpj).to eq('91415732000793')
        end
      end
    end
  end
end
