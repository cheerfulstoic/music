require 'active_model'
require 'music/patches/hash'

module Music
  class Note
    include ActiveModel::Validations

    NOTES = ['C', 'C#/Db', 'D', 'D#/Eb', 'E', 'F', 'F#/Gb', 'G', 'G#/Ab', 'A', 'A#/Bb', 'B']
    NOTE_STRINGS = ['Ab', 'A', 'A#', 'Bb', 'B', 'C', 'C#', 'Db', 'D', 'D#', 'Eb', 'E', 'F', 'Gb', 'G', 'G#']

    attr_accessor :frequency

    validates_presence_of :frequency

    include Comparable
    def <=>(other_note)
      self.frequency <=> other_note.frequency
    end

    def initialize(descriptor, assumed_octave = nil)
      self.frequency = if descriptor.is_a? Numeric
        Note.nearest_note_frequency(descriptor)
      else
        Note.calculate_frequency(descriptor, assumed_octave)
      end
    end

    def note_string(give_flat = false)
      Note.calculate_note(self.frequency, give_flat).join
    end

    def letter(give_flat = false)
      Note.calculate_note(self.frequency, give_flat)[0]
    end

    def accidental(give_flat = false)
      Note.calculate_note(self.frequency, give_flat)[1]
    end

    def octave
      Note.calculate_note(self.frequency)[2]
    end

    def pred
      Note.new(Note.frequency_adjustment(self.frequency, -1))
    end

    def succ
      Note.new(Note.frequency_adjustment(self.frequency, 1))
    end
    alias :next :succ

    def distance_to(note)
      Note.note_distance(self.note_string, note.note_string)
    end

    def adjust_by_semitones(interval)
      Note.new(Note.frequency_adjustment(self.frequency, interval))
    end

    {
      :minor_third => 3,
      :major_third => 4,

      :diminished_fifth => 6,
      :perfect_fifth => 7,
      :augmented_fifth => 8,

      :diminished_seventh => 9,
      :minor_seventh => 10,
      :major_seventh => 11
    }.each do |interval, semitones_count|
      define_method interval do
        adjust_by_semitones(semitones_count)
      end
    end

    CHORD_INTERVALS = {
      :minor => [:minor_third, :perfect_fifth],
      :major => [:major_third, :perfect_fifth],
      :diminished => [:minor_third, :diminished_fifth],
      :augmented => [:major_third, :augmented_fifth],
      :major_seventh => [:major_third, :perfect_fifth, :major_seventh],
      :minor_seventh => [:minor_third, :perfect_fifth, :minor_seventh],
      :diminished_seventh => [:minor_third, :diminished_fifth, :diminished_seventh],
      :augmented_seventh => [:major_third, :augmented_fifth, :minor_seventh],
      :half_diminished_seventh => [:minor_third, :diminished_fifth, :minor_seventh]
    }

    CHORD_ALIASES = {
      :min => :minor,
      :m => :minor,
      :maj => :major,
      :M => :major,
      :dim => :diminished,
      :aug => :augmented,
      :'+' => :augmented,

      :maj_seventh => :major_seventh,
      :major_7 => :major_seventh,
      :major_7th => :major_seventh,
      :maj_7 => :major_seventh,
      :maj_7th => :major_seventh,
      :maj7 => :major_seventh,
      :maj7th => :major_seventh,
      :M7 => :major_seventh,

      :min_seventh => :minor_seventh,
      :minor_7 => :minor_seventh,
      :minor_7th => :minor_seventh,
      :min_7 => :minor_seventh,
      :min_7th => :minor_seventh,
      :min7 => :minor_seventh,
      :min7th => :minor_seventh,
      :m7 => :minor_seventh,

      :dim_seventh => :diminished_seventh,
      :diminished_7 => :diminished_seventh,
      :diminished_7th => :diminished_seventh,
      :dim_7 => :diminished_seventh,
      :dim_7th => :diminished_seventh,
      :dim7 => :diminished_seventh,
      :dim7th => :diminished_seventh,
      :d7 => :diminished_seventh,

      :aug_seventh => :augmented_seventh,
      :augmented_7 => :augmented_seventh,
      :augmented_7th => :augmented_seventh,
      :aug_7 => :augmented_seventh,
      :aug_7th => :augmented_seventh,
      :aug7 => :augmented_seventh,
      :aug7th => :augmented_seventh,
      :'+7' => :augmented_seventh,

      :half_dim_seventh => :half_diminished_seventh,
      :half_diminished_7 => :half_diminished_seventh,
      :half_diminished_7th => :half_diminished_seventh,
      :half_dim_7 => :half_diminished_seventh,
      :half_dim_7th => :half_diminished_seventh,
      :half_dim7 => :half_diminished_seventh,
      :half_dim7th => :half_diminished_seventh,
    }

    def chord(description)
      description = :major if description.blank?

      description = description.to_s
      description.downcase! unless ['M', 'M7'].include?(description)
      description.gsub!(/[\s\-]+/, '_')
      description = description.to_sym

      intervals = CHORD_INTERVALS[description] || CHORD_INTERVALS[CHORD_ALIASES[description]]

      if intervals
        Chord.new([self] + intervals.collect {|interval| self.send(interval) })
      end
    end

    (CHORD_INTERVALS.keys + CHORD_ALIASES.keys).each do |chord_description|
      define_method "#{chord_description}_chord" do
        self.chord(chord_description)
      end
    end

    class << self
      extend ActiveSupport::Memoizable

      def parse_note_string(note_string, assumed_octave = nil)
        match = note_string.match(/^([A-Ga-g])([#b]?)([0-8]?)$/)

        raise ArgumentError, "Did not recognize note string: #{note_string}" if !match
        raise ArgumentError, "No octave found or specified" if match[3].blank? && assumed_octave.nil?
        raise ArgumentError if match[3].to_i > 8 || (assumed_octave && !(0..8).include?(assumed_octave))

        octave = match[3].present? ? match[3] : assumed_octave
        [match[1].upcase, match[2] == '' ? nil : match[2], octave.to_i]
      end

      def note_distance(note_string1, note_string2)
        letter1, accidental1, octave1 = parse_note_string(note_string1)
        letter2, accidental2, octave2 = parse_note_string(note_string2)

        get_index = Proc.new do |letter, accidental|
          NOTES.index do |note|
            regex = case accidental
            when '#' then
              /^#{letter}#/
            when 'b' then
              /#{letter}b$/
            else
              /^#{letter}$/
            end
            note.match(regex)
          end
        end

        index1 = get_index.call(letter1, accidental1)
        index2 = get_index.call(letter2, accidental2)

        (index2 - index1) + ((octave2.to_i - octave1.to_i) * NOTES.size)
      end

      def frequency_adjustment(start_frequency, distance)
        result = (start_frequency * (2.0 ** (distance.to_f / NOTES.size)))

        # Would like to use #round(2), but want to support Ruby 1.8
        (result * 100.0).round / 100.0
      end

      def calculate_frequency(*args)
        case args.size
        when 1
          letter, accidental, octave = parse_note_string(args[0])
        when 2
          letter, accidental, octave = parse_note_string(args[0], args[1])
        when 3
          letter, accidental, octave = args
        else
          raise ArgumentError, "Invalid octave of arguments"
        end

        distance = note_distance('A4', "#{letter}#{accidental}#{octave}")

        frequency_adjustment(440.0, distance)
      end

      def calculate_note(frequency, give_flat = false)
        # Would like to use #log(frequency / 440.0, 2), but would like to support Ruby 1.8
        frequency_log_base_2 = Math.log(frequency / 440.0) / Math.log(2)

        distance = (NOTES.size * frequency_log_base_2).round

        index = 9 + distance # 9 is index for A

        octave = 4 + (index / NOTES.size) # 4 is because we're using A4
        index = (index % NOTES.size)

        parts = "#{NOTES[index]}".split('/')
        note = if give_flat
          parts.last
        else
          parts.first
        end

        "#{note}#{octave}"
        note_parts = note.split('')
        note_parts + (note_parts.size == 1 ? [nil] : []) + [octave.to_i]
      end

      def nearest_note_frequency(frequency)
        Note.calculate_frequency(Note.calculate_note(frequency).join)
      end

    end
  end
end
