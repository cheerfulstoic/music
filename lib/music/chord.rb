require 'set'

module Music
  class Chord

    def eql?(other_chord)
      @notes == other_chord.notes
    end
    def hash
      @notes.hash
    end
    def ==(other_chord)
      self.eql?(other_chord)
    end

    attr_reader :notes

    def initialize(notes)
      raise ArgumentError, 'Chords must have at least two notes' if notes.size < 2
      @notes = ::Set.new(notes) do |note|
        if note.is_a?(Note)
          note
        else
          Note.new(note)
        end
      end
    end

    # Spec and implement
    # def to_i

    def note_strings
      ::Set.new(@notes.collect(&:note_string))
    end

    def describe
      note_array = @notes.to_a.sort
      distances = (1...note_array.size).collect do |i|
        note_array[0].distance_to(note_array[i])
      end

      quality = case distances
      when [4, 7]
        :major
      when [3, 7]
        :minor
      when [3, 6]
        :diminished
      when [4, 8]
        :augmented
      when [4, 7, 11]
        :major_7
      when [3, 7, 10]
        :minor_7
      when [3, 6, 9]
        :diminished_7
      when [3, 6, 10]
        :half_diminished_7
      when [4, 8, 10]
        :augmented_7
      end

      [note_array.first.letter, quality]
    end

    def to_s
      @notes.to_a.sort.collect(&:to_s).join(' / ')
    end

    # Give the Nth inversion of the chord which simply adjusts the lowest N notes up by one octive
    #
    # @returns [Chord] The specified inversion of chord
    def inversion(amount)
      raise ArgumentError, "Inversion amount must be greater than or equal to 1" if amount < 1
      raise ArgumentError, "Not enough notes in chord for inversion" if amount >= @notes.size

      note_array = @notes.to_a.sort
      notes = (0...amount).collect { note_array.shift.adjust_by_semitones(12) }
      Chord.new(notes + note_array)
    end

    # Calls inversion(1)
    def first_inversion
      self.inversion(1)
    end

    # Calls inversion(2)
    def second_inversion
      self.inversion(2)
    end

    # Calls inversion(3)
    def third_inversion
      self.inversion(3)
    end

    class << self
      def parse_chord_string(chord_string, assumed_octave = nil)
        if note_string_match = chord_string.match(/^([A-Ga-g])([#b]?)([^\d]*)(\d*)$/)
          full_string, note, accidental, interval, octave = note_string_match.to_a

          raise ArgumentError, 'No octave found and no octave assumed' if note.empty? && assumed_octave.nil?

          Note.new(note + accidental + octave, assumed_octave).chord(interval)
        end
      end
    end
  end
end
