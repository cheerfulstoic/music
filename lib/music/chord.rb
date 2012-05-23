module Music
  class Chord

    def ==(other_chord)
      return false if @notes.size != other_chord.notes.size

      @notes.each_with_index do |note, i|
        return false if note != other_chord.notes[i]
      end

      return true
    end

    attr_reader :notes

    def initialize(notes)
      @notes = notes.collect do |note|
        if note.is_a?(Note)
          note
        else
          Note.new(note)
        end
      end.sort
    end

    def note_strings
      @notes.collect(&:note_string)
    end

    def describe
      distances = (1...@notes.size).collect do |i|
        @notes[0].distance_to(@notes[i])
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

      [@notes.first.letter, quality]
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
