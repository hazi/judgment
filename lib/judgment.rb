# frozen_string_literal: true

require 'judgment/version'
require 'active_support'
require 'active_support/core_ext'

# Judgment は判定基準と、判定基準に合わなかった場合の理由を登録することで、
# その結果をまとめて出力ができる機能を追加します。
#
# @example
#   class SampleModel
#     include Judgment
#
#     def initialize
#       @status = 1
#       @price = nil
#     end
#
#     judge_for :publishable do
#       judge -> { @status == 1 }, 'status is not `1`'
#       judge_not -> { @price.nil? }, 'price is nil'
#     end
#
#     def publish!
#       fail unless publishable?
#       publish
#     end
#   end
#
#   sample_model = SampleModel.new
#   sample_model.publishable? #=> false
#   sample_model.judgment_message(:publishable) #=> ['price is nil']
module Judgment
  extend ActiveSupport::Concern

  included do
    class_attribute :_judges
    class_attribute :_judge_name
  end

  class_methods do
    # @example
    #   judge_for :publishable do
    #     judge -> { @status == 1 }, 'status is not `1`'
    #   end
    #
    # @param name [Symbol]
    def judge_for(name)
      name = name.to_sym

      self._judge_name = name
      yield
      define_method("#{name}?") { instance_exec { judgment_result(name) } }
      self._judge_name = nil
    end

    # @private
    # use only `judge_for` yield
    def judge(proc, objection)
      self._judges ||= []
      self._judges << { proc: proc, objection: objection, reversal: false, name: _judge_name }
    end

    # @private
    # use only `judge_for` yield
    def judge_not(proc, objection)
      self._judges ||= []
      self._judges << { proc: proc, objection: objection, reversal: true, name: _judge_name }
    end
  end

  # Returns the judgment result
  #
  # @example
  #   object.judgment_result(:publishable)
  #   or
  #   object.publishable?
  def judgment_result(name)
    judge_rules(name).each do |judge|
      return false unless judge_run(proc: judge[:proc], reversal: judge[:reversal])
    end
    true
  end

  # @return [Array<String>] return an objection messages
  def judgment_message(name)
    judge_rules(name).each_with_object([]) do |judge, result|
      next if judge_run(proc: judge[:proc], reversal: judge[:reversal])
      result << judge[:objection]
    end
  end

  private

  def judge_names
    _judges.map { |v| v[:name] }.uniq
  end

  def judge_run(proc:, reversal:)
    run_result = instance_exec(&proc)
    unless [true, false, nil].include?(run_result)
      fail ResultError, "result of judgment is other than true, false, nil, it can't be determined (#{run_result})"
    end

    return !run_result if reversal
    run_result
  end

  def judge_rules(name)
    name = name.to_sym
    fail ArgumentError, "`#{name}` is a name without registration" unless judge_names.include?(name)
    _judges.select { |judge| judge[:name] == name }
  end

  class ResultError < StandardError; end
end
