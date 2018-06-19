RSpec.describe Judgment do
  let(:klass) do
    klass = Class.new
    klass.class_exec { include Judgment }

    klass
  end

  let(:instance) { klass.new }

  context 'value が 1 であることを判定する juge が :key に登録されている場合' do
    before do
      klass.class_exec do
        judge_for :key do
          judge(-> { @value == 1 }, 'value is not `1`')
        end
      end
    end

    describe '#judge' do
      it 'judge が1つ登録されていること' do
        expect(klass._judges.size).to eq(1)
      end

      it 'judge の reversal が false であること' do
        expect(klass._judges.first[:reversal]).to eq(false)
      end
    end

    describe '#judgment_result' do
      context '存在しない名前 :no_name を引数に指定して実行した場合' do
        it do
          expect { instance.instance_eval { judgment_result(:no_name) } }
            .to raise_error('`no_name` is a name without registration')
        end
      end

      describe '引数 :key を指定して実行した場合' do
        subject { instance.instance_eval { judgment_result(:key) } }

        context 'instance `@value` 変数が 1 の場合' do
          before do
            instance.instance_variable_set(:@value, 1)
          end

          it { is_expected.to eq(true) }
        end

        context 'instance `@value` 変数が 2 の場合' do
          before do
            instance.instance_variable_set(:@value, 2)
          end

          it { is_expected.to eq(false) }
        end
      end

      describe '#key?' do
        subject { instance.instance_eval { key? } }

        context 'instance `@value` 変数が 1 の場合' do
          before do
            instance.instance_variable_set(:@value, 1)
          end

          it { is_expected.to eq(true) }
        end

        context 'instance `@value` 変数が 2 の場合' do
          before do
            instance.instance_variable_set(:@value, 2)
          end

          it { is_expected.to eq(false) }
        end
      end
    end

    describe '#judgment_message' do
      context '存在しない名前 :no_name を引数に指定して実行した場合' do
        it do
          expect { instance.instance_eval { judgment_message(:no_name) } }
            .to raise_error('`no_name` is a name without registration')
        end
      end

      context '引数 :key を指定して実行した場合' do
        subject { instance.instance_eval { judgment_message(:key) } }

        context 'instance `@value` 変数が 1 の場合' do
          before do
            instance.instance_variable_set(:@value, 1)
          end

          it { is_expected.to be_empty }
        end

        context 'instance `@value` 変数が 2 の場合' do
          before do
            instance.instance_variable_set(:@value, 2)
          end

          it { is_expected.to eq(['value is not `1`']) }
        end
      end
    end
  end

  context 'value が 1 ではないことを判定する juge が :key に登録されている場合' do
    before do
      klass.class_exec do
        judge_for :key do
          judge_not(-> { @value == 1 }, 'value is `1`')
        end
      end
    end

    describe '#judge_not' do
      it 'judge が1つ登録されていること' do
        expect(klass._judges.size).to eq(1)
      end

      it 'judge の reversal が true であること' do
        expect(klass._judges.first[:reversal]).to eq(true)
      end
    end

    describe '#judgment_result' do
      describe '引数 :key を指定して実行した場合' do
        subject { instance.instance_eval { judgment_result(:key) } }

        context 'instance `@value` 変数が 1 の場合' do
          before do
            instance.instance_variable_set(:@value, 1)
          end

          it { is_expected.to eq(false) }
        end

        context 'instance `@value` 変数が 2 の場合' do
          before do
            instance.instance_variable_set(:@value, 2)
          end

          it { is_expected.to eq(true) }
        end
      end
    end
  end

  context '戻り値が nil な judge が :key に登録されている場合' do
    before do
      klass.class_exec do
        judge_for :key do
          judge(-> { nil }, 'nil')
        end
      end
    end

    describe '#judge_not' do
      it 'judge が1つ登録されていること' do
        expect(klass._judges.size).to eq(1)
      end
    end

    describe '#judgment_result' do
      describe '引数 :key を指定して実行した場合' do
        subject { instance.instance_eval { judgment_result(:key) } }

        it { is_expected.to eq(false) }
      end
    end
  end

  context '戻り値が 1 な judge が :key に登録されている場合' do
    before do
      klass.class_exec do
        judge_for :key do
          judge(-> { 1 }, '1')
        end
      end
    end

    describe '#judge_not' do
      it 'judge が1つ登録されていること' do
        expect(klass._judges.size).to eq(1)
      end
    end

    describe '#judgment_result' do
      describe '引数 :key を指定して実行した場合' do
        subject { instance.instance_eval { judgment_result(:key) } }

        it do
          expect { subject }.to raise_error(
            Judgment::ResultError,
            "result of judgment is other than true, false, nil, it can't be determined (1)"
          )
        end
      end
    end
  end
end
