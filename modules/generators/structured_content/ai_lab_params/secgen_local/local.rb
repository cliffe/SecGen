#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'json'
require 'securerandom'

# Picks the random values for one lab. Every value the student has to work with
# or could share differs between builds.
class AiLabParams < StringEncoder
  attr_accessor :lab

  def initialize
    super
    self.module_name = 'AI lab parameters'
    self.lab = 'model_stealing'
  end

  # A shuffle of 0-9 with no value left in place, so no class keeps its digit.
  def derangement
    loop do
      map = (0..9).to_a.shuffle(random: SecureRandom)
      return map if map.each_with_index.none? { |v, i| v == i }
    end
  end

  def model_stealing
    budget = SecureRandom.random_number(3001..4500)
    {
      'label_map' => derangement,
      'query_budget' => budget,
      'tight_budget' => SecureRandom.random_number(350..500),
      'agreement_threshold' => 0.94,
      'tight_threshold' => 0.87,
      'check_sample' => 1000,
      'pool_size' => 12_000,
      'gradient_endpoint' => false,
      'api' => true
    }
  end

  def backdoor
    source, target = (0..9).to_a.sample(2, random: SecureRandom)
    size = SecureRandom.random_number(3..5)
    margin = 27 - size
    # A corner of the image, where digits rarely reach.
    x = [0, 1, margin - 1, margin].sample(random: SecureRandom)
    y = [0, 1, margin - 1, margin].sample(random: SecureRandom)
    poison_limit = SecureRandom.random_number(450..600)
    {
      'flip_source' => source,
      'flip_target' => target,
      'flip_limit' => SecureRandom.random_number(1500..1700),
      'flip_threshold' => 0.85,
      'other_accuracy_floor' => 0.95,
      'trigger_size' => size,
      'trigger_x' => x,
      'trigger_y' => y,
      'trigger_target' => (0..9).to_a.sample(random: SecureRandom),
      'poison_limit' => poison_limit,
      'stealth_limit' => poison_limit / 2,
      'asr_threshold' => 0.90,
      'stealth_asr_threshold' => 0.80,
      'clean_accuracy_floor' => 0.95,
      'train_size' => 20_000,
      'api' => false
    }
  end

  def evasion
    {
      'fgsm_epsilon' => (SecureRandom.random_number(15..25) / 100.0).round(2),
      'pgd_epsilon' => (SecureRandom.random_number(25..30) / 100.0).round(2),
      'max_angle' => 30,
      'max_shift' => 4,
      'query_budget' => 1_000_000,
      'gradient_endpoint' => true,
      'api' => true
    }
  end

  def encode_all
    params = { 'lab' => lab, 'seed' => SecureRandom.random_number(1..2_000_000_000) }
    params.merge!(send(lab))
    outputs << params.to_json
  end

  def process_options(opt, arg)
    super
    self.lab = arg if opt == '--lab'
  end

  def get_options_array
    super + [['--lab', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def encoding_print_string
    "lab: #{lab}"
  end
end

AiLabParams.new.run
