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
      @notes = Set.new(notes) do |note|
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
      Set.new(@notes.collect(&:note_string))
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

    def first_inversion
      note_array = @notes.to_a.sort
      note = note_array.shift
      Chord.new([note.adjust_by_semitones(12)] + note_array)
    end

    class << self
      def parse_chord_string(chord_string, assumed_octave = nil)
        if note_string_match = chord_string.match(/^([A-Ga-g])([#b]?)([^\d]*)(\d*)$/)
          full_string, note, accidental, interval, octave = note_string_match.to_a

          raise ArgumentError, 'No octave found and no octave assumed' if note.blank? && assumed_octave.nil?

          Note.new(note + accidental + octave, assumed_octave).chord(interval)
        end
      end
    end
  end
end
