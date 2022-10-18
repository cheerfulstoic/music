module Music
  class Note
    NOTES = ['C', 'C#/Db', 'D', 'D#/Eb', 'E', 'F', 'F#/Gb', 'G', 'G#/Ab', 'A', 'A#/Bb', 'B']
    NOTE_STRINGS = ['Ab', 'A', 'A#', 'Bb', 'B', 'C', 'C#', 'Db', 'D', 'D#', 'Eb', 'E', 'F', 'Gb', 'G', 'G#']
    ENHARMONICS = {'E#' => 'F', 'Fb' => 'E', 'B#' => 'C', 'Cb' => 'B'}

    attr_accessor :frequency

    include Comparable
    def <=>(other)
      self.frequency <=> other.frequency
    end

    def hash
      self.frequency.hash
    end

    def eql?(other)
      self.frequency == other.frequency
    end

    def to_s
      self.note_string
    end

    # Creates a new note
    #
    # @param [String, Numeric] descriptor Either a string describing the note (e.g. 'C#4') or a number giving the note's frequency (e.g. 440)
    # @param [Numeric, nil] assumed_octave If no octive is given in the descriptor, use this
    # @returns [Note] Note specified
    def initialize(descriptor, assumed_octave = nil)
      self.frequency = if descriptor.is_a? Numeric
                         Note.nearest_note_frequency(descriptor)
                       else
                         Note.calculate_frequency(descriptor, assumed_octave)
                       end
    end

    # Returns string representing note with letter, accidental, and octave number
    # e.g. 'C#5'
    #
    # @param [boolean] give_flat Should the result give a flat? (defults to giving a sharp)
    # @return [String] The resulting note string
    def note_string(give_flat = false)
      Note.calculate_note(self.frequency, give_flat).join
    end

    # Returns the letter portion of the note
    # e.g. 'C'
    #
    # @param [boolean] give_flat Should the result be based on giving a flat? (defaults to giving a sharp)
    # @return [String] The resulting note letter
    def letter(give_flat = false)
      Note.calculate_note(self.frequency, give_flat)[0]
    end

    # Returns the accidental portion of the note
    # e.g. '#' or 'b'
    #
    # @param [boolean] give_flat Should the result give a flat? (defaults to giving a sharp)
    # @return [String] The resulting accidental
    def accidental(give_flat = false)
      Note.calculate_note(self.frequency, give_flat)[1]
    end

    # Returns the octive number of the note
    # e.g. 4
    #
    # @return [Fixnum] The resulting octive number
    def octave
      Note.calculate_note(self.frequency)[2]
    end

    # Return the previous note (adjusted by one semitone down)
    #
    # @return [Note] The previous note
    def prev
      Note.new(Note.frequency_adjustment(self.frequency, -1))
    end

    # Return the next note (adjusted by one semitone up)
    #
    # @return [Note] The next note
    def succ
      Note.new(Note.frequency_adjustment(self.frequency, 1))
    end
    alias_method :next, :succ

    # Return the distance (in semitones) to a note
    #
    # @return [Fixnum] Number of semitones
    def distance_to(note)
      Note.note_distance(self.note_string, note.note_string)
    end

    # Return another note adjusted by a given interval
    #
    # @param [Fixnum] interval Number of semitones to adjust by
    # @return [Note] Resulting note after adjustment
    def adjust_by_semitones(interval)
      Note.new(Note.frequency_adjustment(self.frequency, interval))
    end

    {
      minor_second: 1,
      major_second: 2,

      minor_third: 3,
      major_third: 4,

      perfect_fourth: 5,

      tritone: 6, diminished_fifth: 6, flat_fifth: 6, augmented_fourth: 6,
      perfect_fifth: 7,
      augmented_fifth: 8, minor_sixth: 8,

      major_sixth: 9, diminished_seventh: 9,
      minor_seventh: 10,
      major_seventh: 11
    }.each do |interval, semitones_count|
      define_method interval do
        adjust_by_semitones(semitones_count)
      end
    end

    # Uses note as key to give major scale
    #
    # @returns [Array<Note>] Notes in major scale
    def major_scale
      [self,
       self.major_second,
       self.major_third,
       self.perfect_fourth,
       self.perfect_fifth,
       self.major_sixth,
       self.major_seventh
      ]
    end

    # Uses note as key to give minor scale
    #
    # @returns [Array<Note>] Notes in minor scale
    def minor_scale
      [self,
       self.major_second,
       self.minor_third,
       self.perfect_fourth,
       self.perfect_fifth,
       self.minor_sixth,
       self.minor_seventh
      ]
    end

    CHORD_INTERVALS = {
      minor: [:minor_third, :perfect_fifth],
      major: [:major_third, :perfect_fifth],
      fifth: [:perfect_fifth],
      diminished: [:minor_third, :diminished_fifth],
      augmented: [:major_third, :augmented_fifth],
      major_seventh: [:major_third, :perfect_fifth, :major_seventh],
      minor_seventh: [:minor_third, :perfect_fifth, :minor_seventh],
      diminished_seventh: [:minor_third, :diminished_fifth, :diminished_seventh],
      augmented_seventh: [:major_third, :augmented_fifth, :minor_seventh],
      half_diminished_seventh: [:minor_third, :diminished_fifth, :minor_seventh]
    }

    CHORD_ALIASES = {
      :min => :minor,
      :m => :minor,
      :maj => :major,
      :M => :major,
      :p => :fifth,
      :pow => :fifth,
      :power => :fifth,
      :'5' => :fifth,
      :'5th' => :fifth,
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
      :half_dim7th => :half_diminished_seventh
    }

    def chord(description)
      description = :major if description.to_s.empty?

      description = description.to_s
      description.downcase! unless %w(M M7).include?(description)
      description.gsub!(/[\s\-]+/, '_')
      description = description.to_sym

      intervals = CHORD_INTERVALS[description] || CHORD_INTERVALS[CHORD_ALIASES[description]]

      if intervals
        Chord.new([self] + intervals.collect { |interval| self.send(interval) })
      end
    end

    (CHORD_INTERVALS.keys + CHORD_ALIASES.keys).each do |chord_description|
      define_method "#{chord_description}_chord" do
        self.chord(chord_description)
      end
    end

    class << self
      def parse_note_string(note_string, assumed_octave = nil, convert_enharmonics = nil)
        match = note_string.match(/^([A-Ga-g])([#b]?)([0-8]?)$/)

        fail ArgumentError, "Did not recognize note string: #{note_string}" if !match
        fail ArgumentError, 'No octave found or specified' if match[3].empty? && assumed_octave.nil?
        fail ArgumentError if match[3].to_i > 8 || (assumed_octave && !(0..8).include?(assumed_octave))

        octave = match[3].empty? ? assumed_octave : match[3]
        note_parts = [match[1].upcase, match[2] == '' ? nil : match[2], octave.to_i]
        convert_enharmonics ? convert_enharmonics(*note_parts) : note_parts
      end

      def convert_enharmonics(note, accidental, octave)
        full_note = [note, accidental].join
        enharmonic_equivalent = ENHARMONICS[full_note]
        return [note, accidental, octave] unless enharmonic_equivalent

        [enharmonic_equivalent, nil, octave]
      end

      def note_distance(note_string1, note_string2)
        letter1, accidental1, octave1 = parse_note_string(note_string1, nil, true)
        letter2, accidental2, octave2 = parse_note_string(note_string2, nil, true)

        get_index = proc do |letter, accidental|
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
        result = (start_frequency * (2.0**(distance.to_f / NOTES.size)))

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
          fail ArgumentError, 'Invalid octave of arguments'
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

        note_parts = note.split('')
        note_parts + (note_parts.size == 1 ? [nil] : []) + [octave.to_i]
      end

      def nearest_note_frequency(frequency)
        Note.calculate_frequency(Note.calculate_note(frequency).join)
      end
    end
  end
end
