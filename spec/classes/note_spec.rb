require 'spec_helper'
include Music

describe Music::Note do

  describe "#new" do
    it "should allow note strings to initalize notes" do
      Note.new('E0').frequency.should == 20.60
      Note.new('Bb3').frequency.should == 233.08
    end

    it "should allow frequencies to initalize notes" do
      Note.new(698.46).note_string.should == 'F5'
      Note.new(1975.53).note_string.should == 'B6'
    end
  end

  describe "Comparing notes" do
    it "should compare notes by their frequencies" do
      Note.new(698.46).should < Note.new(1975.53)
      Note.new('B5').should > Note.new('B2')
      Note.new(698.46).should == Note.new('F5')
    end
  end

  describe '#note_string' do
    it 'Should return the letter, accidental, and octave as a string' do
      Note.new(698.46).note_string.should == 'F5'
      Note.new('C#6').note_string.should == 'C#6'
    end

    it 'Should return the flat version if asked' do
      Note.new('C#6').note_string(true).should == 'Db6'
    end
  end

  describe '#letter' do
    it 'Should return just the letter' do
      Note.new('E0').letter.should == 'E'
      Note.new(698.46).letter.should == 'F'
      Note.new(1975.53).letter.should == 'B'
    end

    it 'Should return the letter based on if asked for the flat' do
      Note.new('Bb3').letter.should == 'A'
      Note.new('Bb3').letter(true).should == 'B'
    end
  end

  describe '#accidental' do
    it 'Should return just the accidental' do
      Note.new('A#4').accidental.should == '#'
    end

    it 'Should return the flat if asked for' do
      Note.new('Bb3').accidental.should == '#'
      Note.new('Bb3').accidental(true).should == 'b'
    end

    it 'Should return nil for no accidental' do
      Note.new('B2').accidental.should == nil
      Note.new('G2').accidental.should == nil
    end
  end

  describe '#octave' do
    it 'Should return the octave' do
      Note.new('A#4').octave.should == 4
      Note.new('B7').octave.should == 7
      Note.new('Gb1').octave.should == 1
      Note.new('E0').octave.should == 0
    end
  end

  describe ".parse_note_string(note_string)" do
    it "Should split note letter, accidental, and octave" do
      Note.parse_note_string('A#1').should == ['A', '#', 1]
      Note.parse_note_string('Cb4').should == ['C', 'b', 4]
    end

    it "Should allow for lower case notes" do
      Note.parse_note_string('g#1').should == ['G', '#', 1]
    end

    it "Should allow for an assumed octave" do
      Note.parse_note_string('A', 4).should == ['A', nil, 4]
      Note.parse_note_string('C#', 6).should == ['C', '#', 6]
    end

    it "Should ignore the assumed octave if there is a octave" do
      Note.parse_note_string('B3', 4).should == ['B', nil, 3]
      Note.parse_note_string('Gb6', 2).should == ['G', 'b', 6]
    end

    it "Should not allow notes above G" do
      expect { Note.parse_note_string('HB1') }.to raise_error ArgumentError
    end

    it "Should not allow extraneous characters" do
      expect { Note.parse_note_string(' Ab1') }.to raise_error ArgumentError
      expect { Note.parse_note_string('%Hb1') }.to raise_error ArgumentError
      expect { Note.parse_note_string('Hb1-') }.to raise_error ArgumentError
    end

    it "Should not allow for upper case flats" do
      expect { Note.parse_note_string('AB1') }.to raise_error ArgumentError
      expect { Note.parse_note_string('aB1') }.to raise_error ArgumentError
    end

    it "Should return nil when there is no accidental" do
      Note.parse_note_string('C4').should == ['C', nil, 4]
    end

    it "Should not allow note above octave 8" do
      Note.parse_note_string('G#8').should == ['G', '#', 8]
      expect { Note.parse_note_string('Ab9') }.to raise_error ArgumentError
      expect { Note.parse_note_string('Ab', 9) }.to raise_error ArgumentError
    end
  end

  describe ".note_distance(note_string1, note_string2)" do
    {
      ['A4', 'A#4'] => 1,
      ['A4', 'Ab4'] => -1,
      ['B0', 'B0'] => 0,
      ['G#1', 'Ab1'] => 0,
      ['Bb1', 'A#1'] => 0,
      ['A3', 'A4'] => 12,
      ['a3', 'A4'] => 12,
      ['B1', 'F1'] => -6,
      ['B1', 'f1'] => -6,
      ['A4', 'Eb0'] => -54,
      ['a4', 'eb0'] => -54,
      ['A2', 'C4'] => 15
    }.each do |notes, distance|
      it "Should return #{distance} between #{notes[0]} and #{notes[1]}" do
        Note.note_distance(*notes).should == distance
      end
    end

    it "Should not allow invalid note strings" do
      expect { Note.note_distance('H0', 'A0') }.to raise_error ArgumentError
      expect { Note.note_distance('A0', 'I#0') }.to raise_error ArgumentError
      expect { Note.note_distance('A%0', 'A0') }.to raise_error ArgumentError
    end
  end

  describe '#distance_to(note)' do
    it 'Should find the distance between the subject note object and the note passed in' do
      Note.new('A2').distance_to(Note.new('C4')).should == 15
    end
  end

  describe 'interval descriptions' do
    describe '#minor_third' do
      Note.new('C4').minor_third.note_string.should == 'D#4'
      Note.new('B4').minor_third.note_string.should == 'D5'
    end

    describe '#major_third' do
      Note.new('C4').major_third.note_string.should == 'E4'
      Note.new('B4').major_third.note_string.should == 'D#5'
    end

    describe '#diminished_fifth' do
      Note.new('C4').diminished_fifth.note_string.should == 'F#4'
      Note.new('B4').diminished_fifth.note_string.should == 'F5'
    end

    describe '#perfect_fifth' do
      Note.new('C4').perfect_fifth.note_string.should == 'G4'
      Note.new('B4').perfect_fifth.note_string.should == 'F#5'
    end

    describe '#augmented_fifth' do
      Note.new('C4').augmented_fifth.note_string.should == 'G#4'
      Note.new('B4').augmented_fifth.note_string.should == 'G5'
    end

    describe '#diminished_seventh' do
      Note.new('C4').diminished_seventh.note_string.should == 'A4'
      Note.new('B4').diminished_seventh.note_string.should == 'G#5'
    end

    describe '#minor_seventh' do
      Note.new('C4').minor_seventh.note_string.should == 'A#4'
      Note.new('B4').minor_seventh.note_string.should == 'A5'
    end

    describe '#major_seventh' do
      Note.new('C4').major_seventh.note_string.should == 'B4'
      Note.new('B4').major_seventh.note_string.should == 'A#5'
    end
  end

  describe ".calculate_frequency(letter, accidental, octave)" do
    {
      ['C', nil, 0] => 16.35,
      ['E', 'b', 0] => 19.45,
      ['A', '#', 1] => 58.27,
      ['B', 'b', 1] => 58.27,
      ['A', 'b', 4] => 415.30,
      ['A', nil, 4] => 440.00,
      ['A', '#', 4] => 466.16,
      ['B', nil, 6] => 1975.53,
      ['C', nil, 7] => 2093.00,
      ['E', 'b', 8] => 4978.03
    }.each do |note_array, frequency|
      it "Should return #{frequency} for #{note_array.join}" do
        Note.calculate_frequency(*note_array).should == frequency
      end
    end

    it "Should take note strings as an argument" do
      Note.calculate_frequency('A#1').should == 58.27
      Note.calculate_frequency('A4').should == 440.00
      Note.calculate_frequency('C7').should == 2093.00
    end

    it "Should allow lower case notes" do
      Note.calculate_frequency('a#1').should == 58.27
      Note.calculate_frequency('db2').should == 69.3
      Note.calculate_frequency('e', nil, 3).should == 164.81
    end

    it "Should not take argument lengths above 3" do
      expect { Note.calculate_frequency('A', nil, 0, 0) }.to raise_error ArgumentError
    end

    it "Should not allow invalid notes" do
      expect { Note.calculate_frequency('H', nil, 0) }.to raise_error ArgumentError
      expect { Note.calculate_frequency('I', nil, 0) }.to raise_error ArgumentError
    end

    it "Should not allow invalid accidentals" do
      expect { Note.calculate_frequency('A', 5, 0) }.to raise_error ArgumentError
      expect { Note.calculate_frequency('A', '&', 0) }.to raise_error ArgumentError
    end

    it "Should not allow invalid octaves" do
      expect { Note.calculate_frequency('A', nil, -1) }.to raise_error ArgumentError
      expect { Note.calculate_frequency('A', nil, 9) }.to raise_error ArgumentError
    end
  end

  describe ".calculate_note(frequency)" do
    test_frequencies = {
      [16.35] => ['C', nil, 0],
      [19.45, true] => ['E', 'b', 0],
      [58.27] => ['A', '#', 1],
      [58.27, true] => ['B', 'b', 1],
      [415.30, true] => ['A', 'b', 4],
      [440.00] => ['A', nil, 4],
      [466.16] => ['A', '#', 4],
      [1975.53] => ['B', nil, 6],
      [2093.00] => ['C', nil, 7],
      [4978.03, true] => ['E', 'b', 8]
    }

    test_frequencies.each do |args, note_string|
      it "Should return #{note_string} for #{args[0]}#{args[1] && ' (giving flat)'}" do
        Note.calculate_note(*args).should == note_string
      end
    end

    it "Should calculate the closest note near to a frequency" do
      Note.calculate_note(420, true).should == ['A', 'b', 4]
      Note.calculate_note(430).should == ['A', nil, 4]
    end
  end

  describe ".nearest_note_frequency(frequency)" do
    it 'should return the frequency if it is the frequency of a note' do
      Note.nearest_note_frequency(2093.00).should == 2093.00
    end

    it 'should return the nearest frequency which matches a note' do
      Note.nearest_note_frequency(41.00).should == 41.20
      Note.nearest_note_frequency(40.50).should == 41.20
      Note.nearest_note_frequency(40.00).should == 38.89
      Note.nearest_note_frequency(39.00).should == 38.89
    end
  end

  describe ".frequency_adjustment(start_frequency, distance)" do
    it "Should find frequencies based on start frequency and distance" do
      Note.frequency_adjustment(440.0, 0).should == 440.0
      Note.frequency_adjustment(440.0, 15).should == 1046.50
      Note.frequency_adjustment(440.0, -10).should == 246.94

      Note.frequency_adjustment(1479.98, -6).should == 1046.50
      Note.frequency_adjustment(1479.98, 7).should == 2217.46
    end
  end

  describe "Getting adjacent notes" do
    it "should allow getting of next note" do
      Note.new(698.46).next.should == Note.new(739.99)
      Note.new(698.46).succ.should == Note.new(739.99)
    end

    it "should allow getting of previous note" do
      Note.new(739.99).pred.should == Note.new(698.46)
    end
  end
end
