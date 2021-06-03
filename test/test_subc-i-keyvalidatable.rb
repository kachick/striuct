# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Instance_KeyVallidatable < Test::Unit::TestCase

  Sth = Striuct.new :foo, :bar

  def test_valid_keys?
    sth = Sth.new
    assert(sth.valid_keys?(must: [:foo, :bar]))
    assert(sth.valid_keys?(let: [:foo, :bar]))
    assert(sth.valid_keys?(must: [:foo], let: [:bar]))
    assert(sth.valid_keys?(let: [:foo, :bar, :hoge]))
    assert_same(false, sth.valid_keys?(must: [:foo, :bar, :hoge]))
  end

  def test_valid_autonyms?
    sth = Sth.new
    assert(sth.valid_autonyms?(must: [:foo, :bar]))
    assert(sth.valid_autonyms?(let: [:foo, :bar]))
    assert(sth.valid_autonyms?(must: [:foo], let: [:bar]))
    assert(sth.valid_autonyms?(let: [:foo, :bar, :hoge]))
    assert_same(false, sth.valid_autonyms?(must: [:foo, :bar, :hoge]))
  end

end
